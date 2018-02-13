//
//  CameraViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "RibbitUser.h"
#import "File.h"
#import "Message.h"
#import <Photos/Photos.h>

@interface CameraViewController ()
@property (strong, nonatomic) RibbitUser *user;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *friendsMutable;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"PHAuthorizationStatusDenied");
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.friends = [[RibbitUser currentRibitUser] friends];
    [self observeUserFriends];
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

        [self presentViewController:self.imagePicker animated:YES completion:nil];
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
    return [self.friendsMutable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RibbitUser *user = [self.friendsMutable objectAtIndex:indexPath.row];
    cell.textLabel.text = user.friendName;
    cell.textLabel.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:241.0/255.0 blue:251.0/255.0 alpha:1.0];
    cell.layer.borderWidth = 4.0f;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    
    return cell;
}

- (void)observeUserFriends {
    
    self.friendsMutable = [NSMutableArray array];
    NSString *currentUser = [FIRAuth.auth currentUser].uid;
    FIRDatabaseReference *usersRef = [[[[FIRDatabase.database reference] child:@"users"] child:currentUser] child:@"friends"];
    
    [usersRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        RibbitUser *friendUser = [[RibbitUser alloc] initWithFriendDictionary:dict];
        friendUser.id = snapshot.key;
        friendUser.friendName = dict[@"friendName"];
        [self.friendsMutable addObject:friendUser];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } withCancelBlock:nil];
}

#pragma mark - Table view delegate
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    RibbitUser *friendUser = [self.friendsMutable objectAtIndex:indexPath.row];
    self.uid = friendUser.id;
    self.sendButton.enabled = YES;
}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
       UIImage *newImage = [self resizeImage:self.image toWidth:200 andHeight:200];
        
        self.image = newImage;
        
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // A video was taken/selected!
        
        NSURL *videoUrl = info[UIImagePickerControllerMediaURL];
        self.movieUrl = videoUrl;
        
        self.videoFilePath = videoUrl.absoluteString;
        
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
        [self reset];
    }
}

#pragma mark - Helper methods

- (void)uploadMessage {
    
    NSData *fileData;
    NSString *fileName;
    Message *message = [[Message alloc] init];
    if (self.image != nil) {
        UIImage *newImage = [[UIImage alloc] init];
        newImage = self.image;
       // fileData = UIImagePNGRepresentation(newImage);
        fileData = UIImageJPEGRepresentation(newImage, 0.1);
        fileName = [NSString stringWithFormat:@"%f.jpg",[NSDate timeIntervalSinceReferenceDate]];

        
        NSString *imageName = [[NSString alloc] init]; //[[NSProcessInfo processInfo] globallyUniqueString];//[[NSUUID UUID] UUIDString];
        imageName = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *childImageString = [NSString stringWithFormat:@"%@.jpg", imageName];
        FIRStorageReference *storageRef = [[[FIRStorage.storage reference] child:@"message_images"] child:childImageString];
        
        [storageRef putData:fileData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Storage Error: %@", error);
            }
            
            NSLog(@"Metadata type: %@", metadata.contentType); // application/octet-stream
            NSString *imageUrl = metadata.downloadURL.absoluteString;

            Message *message = [[Message alloc] init];
            
            message.contentType = metadata.contentType;
            NSLog(@"Message Content Type: %@", message.contentType);
            NSLog(@"Metadata Here: %@", metadata);
            [self sendMessagwWithImageUrl:imageUrl];
        }];
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = [NSString stringWithFormat:@"%f.mov",[NSDate timeIntervalSinceReferenceDate]];
        message.contentType = @"video/quicktime";
        [self handleVideoSelectedForUrl:self.movieUrl];
    }

}

- (void)sendMessagwWithImageUrl:(NSString *)imageUrl {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = ref.childByAutoId;

    NSString *toId = self.uid;
    NSString *fromId = [[FIRAuth.auth currentUser] uid];
    Message *message = [[Message alloc] init];
    NSLog(@"Inside SendMessage: %@", message.contentType);
    NSDictionary *values = @{ @"imageUrl": imageUrl, @"toId": toId, @"fromId": fromId, @"contentType": @"application/octet-stream" }; //to id is nil. Because never selected a recipient anyway

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

- (void)sendMessageWithVideoUrl:(NSString *)videoUrl {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = ref.childByAutoId;
    
    NSString *toId = self.uid;
    NSString *fromId = [[FIRAuth.auth currentUser] uid];
    
    NSDictionary *values = @{ @"videoUrl": videoUrl, @"toId": toId, @"fromId": fromId, @"contentType": @"video/quicktime"};
    
    [childRef updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil)  {
            NSLog(@"%@", error);
        }
        
        FIRDatabaseReference *userMessageRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:fromId] child:toId];
        
        NSString *messageId = childRef.key;
        [userMessageRef updateChildValues:@{ messageId: @1 }];
        FIRDatabaseReference *recipientUserMessageRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:toId] child:fromId];
        [recipientUserMessageRef updateChildValues:@{ messageId: @1}];
    }];
}

- (void)handleVideoSelectedForUrl:(NSURL *)url {
    
    NSString *fileName = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
  FIRStorageUploadTask *uploadTask = [[[[FIRStorage.storage reference] child:@"message_movies"] child:fileName] putFile:url metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed upload of video: %@", error);
        }

        NSString *storageUrl = metadata.downloadURL.absoluteString;

      
        [self sendMessageWithVideoUrl:storageUrl];
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
        NSLog(@"Upload Progress: %lld", snapshot.progress.completedUnitCount);
        // Activity indicator is loading unil message sent. Once completed then it will allow me to log out? I feel like that is highly effective.
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
        NSLog(@"Succesful Video Upload");
        [self.tabBarController setSelectedIndex:0];
    }];
    
}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    self.sendButton.enabled = NO;
}


- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    NSLog(@"New Size Width: %f, NewSize Height: %f", newSize.height, newSize.width);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"Resized Image: %f, %f", resizedImage.size.width, resizedImage.size.height);
    return resizedImage;
}

@end
