//
//  CameraViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "User.h"
#import "RibbitUser.h"
#import "File.h"
#import "Message.h"

@interface CameraViewController ()
@property (strong, nonatomic) RibbitUser *user;
@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recipients = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
 //   self.friends = [[User currentUser] friends];
    self.friends = [[RibbitUser currentRibitUser] friends];
    [self.tableView reloadData];
  
    if (self.image == nil && [self.videoFilePath length] == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
  //  User *user = [self.friends objectAtIndex:indexPath.row];
    RibbitUser *user = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.name;
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
 //   User *user = [self.friends objectAtIndex:indexPath.row];
    RibbitUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:user.objectId];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user.objectId];
    }

    NSLog(@"%@", self.recipients);
}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // A photo was taken/selected!
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the image!
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    
    else {
        // A video was taken/selected!
        self.videoFilePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the video!
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)send:(id)sender {
    if (self.image == nil && [self.videoFilePath length] == 0) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try again!" message:@"Please capture or select a photo or video to share!" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    else {
        
        
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (void)handleSend {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = [ref childByAutoId];
    NSString *toId = self.user.id;
    NSString *fromId = [[FIRAuth.auth currentUser] uid];
    NSDictionary *dict = @{ @"toId" : toId, @"fromId" : fromId};
    
    [childRef updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil) {
            NSLog(@"Error: %@", error);
        }
    }];
    
    FIRDatabaseReference *userMessagesRef = [[[FIRDatabase.database reference] child:@"user-messages"] child:fromId];
    NSString *messageId = childRef.key;
    [userMessagesRef updateChildValues: @{ messageId : @1 } ];
    
    FIRDatabaseReference *recipientUserMessageRef = [[[FIRDatabase.database reference] child:@"user-messages"] child:toId];
    [recipientUserMessageRef updateChildValues:@{ messageId: @1 }];
    
    
}

#pragma mark - Helper methods

- (void)uploadMessage {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (self.image != nil) {
        UIImage *newImage = self.image;
       // fileData = UIImagePNGRepresentation(newImage);
        fileData = UIImageJPEGRepresentation(newImage, 0.1);
        fileName = [NSString stringWithFormat:@"%f.jpg",[NSDate timeIntervalSinceReferenceDate]];
        fileType = @"image";
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = [NSString stringWithFormat:@"%f.mov",[NSDate timeIntervalSinceReferenceDate]];
        fileType = @"video";
    }
    
    NSString *imageName = [NSUUID.UUID UUIDString];
    NSString *childImageString = [NSString stringWithFormat:@"%@.jpg", imageName];
    FIRStorageReference *storageRef = [[[FIRStorage.storage reference] child:@"message_images"] child:childImageString];
    
    [storageRef putData:fileData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Storage Error: %@", error);
        }
        
        NSString *imageUrl = metadata.downloadURL.absoluteString;
        [self sendMessagwWithImageUrl:imageUrl];
        
        NSLog(@"Metadata Here: %@", metadata);
    }];
    
    File *file = [File fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error occured!" message:@"Please try sending your message again" preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else {
            Message *message = [[Message alloc] init];
            message.file = file;
            message.fileType = fileType;
            message.recipients = self.recipients;
         //   message.senderId = [[User currentUser] objectId];
            message.senderId = [[RibbitUser currentRibitUser] objectId];
         //   message.senderName = [[User currentUser] username];
            message.senderName = [[RibbitUser currentRibitUser] name];
            
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error occured!" message:@"Please try sending your message again" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    // Everything was successful!
                    [self reset];
                }
                
            }];
        }
    }];
}

- (void)sendMessagwWithImageUrl:(NSString *)imageUrl {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = ref.childByAutoId;
    
    NSString *toId = self.user.id;
    NSString *fromId = [[FIRAuth.auth currentUser] uid];
    
    NSDictionary *values = @{ @"imageUrl": imageUrl, @"toId": toId, @"fromId": fromId }; //to id is nil. Because never selected a recipient anyway
    
    [childRef updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil) {
            NSLog(@"%@", error);
        }
        
        FIRDatabaseReference *userMessageRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:fromId] child:toId];
        
        NSString *messageId = childRef.key;
        [userMessageRef updateChildValues:@{ messageId: @1 }];
        FIRDatabaseReference *recipientUserMessagesRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:toId] child:fromId];
        [recipientUserMessagesRef updateChildValues:@{ messageId: @1 }];
        
    }];
}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
