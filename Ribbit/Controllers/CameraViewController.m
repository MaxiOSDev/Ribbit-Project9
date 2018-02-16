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
#import "Message.h"
#import <Photos/Photos.h>

@interface CameraViewController ()
// Stored properties
@property (strong, nonatomic) RibbitUser *user;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *friendsMutable;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friends = [[RibbitUser currentRibitUser] friends];
    [self observeUserFriends]; // Observes friends because messages can only be sent to friends in this app not just any user.
    self.sendButton.enabled = NO;

    [self.tableView reloadData];
}

// Alot going on here.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        self.uid = nil;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"Authorized"); // Checking if App has access to user library
                if (self.image == nil && [self.videoFilePath length] == 0) {
                    // Image picker setup
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    imagePicker.allowsEditing = NO;
                    imagePicker.videoMaximumDuration = 10;
                    // Check to see if camera is avaliable, and if not then present photo libray
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    }
                    else {
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    }
                    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                    dispatch_async(dispatch_get_main_queue(), ^{
                          [self presentViewController:imagePicker animated:NO completion:nil];
                    });
                }
                
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"Restricted");
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            default:
                break;
        }
    }];
        [self.tableView reloadData];
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
// Populating the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RibbitUser *user = [self.friendsMutable objectAtIndex:indexPath.row];
    cell.textLabel.text = user.friendName;
    cell.textLabel.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:241.0/255.0 blue:251.0/255.0 alpha:1.0];
    cell.layer.borderWidth = 4.0f;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (self.image == nil) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
// Observing the users friends by friend name and id
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    RibbitUser *friendUser = [self.friendsMutable objectAtIndex:indexPath.row];
    // Some logic for sending message to recipient. App can only send 1 message at a time to 1 friend.
    if (self.uid == nil) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.sendButton.enabled = YES;
        self.uid = friendUser.id;
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.sendButton.enabled = NO;
        self.uid = nil;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) { // Checking if selected media is image
        
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage]; // And if it is the simulators photolibary then it assings the image to that selected image
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Saves to photo libray if camera is available
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) { // Checking if selected media is video
        // A video was taken/selected!
        
        NSURL *videoUrl = info[UIImagePickerControllerMediaURL];
        self.movieUrl = videoUrl;
        
        self.videoFilePath = videoUrl.absoluteString; // Getting that filepath by video url
        
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the video!
            // If camera is available then saves to photosAlbum with video file path
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismisses image picker after photo or video is selected or taken
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    [self.tabBarController setSelectedIndex:0];
}


- (IBAction)send:(id)sender {
    // Checks if image or videoFilePath is nil
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try again!" message:@"Please capture or select a photo or video to share!" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self presentViewController:imagePicker animated:NO completion:nil];
    }
    else {
        [self uploadMessage]; // If there is an image or video, then uploads message to database and also sends messsage
        [self reset]; // Resets afterwards for next message to be sent.
    }
}

#pragma mark - Helper methods

- (void)uploadMessage {
    // Logic to upload message
    NSData *fileData = [[NSData alloc] init];
    NSString *fileName = [[NSString alloc] init];
    Message *message = [[Message alloc] init];
    if (self.image != nil) {
        UIImage *newImage = [[UIImage alloc] init];
        newImage = self.image;
       // fileData = UIImagePNGRepresentation(newImage); // Took to much storage
        fileData = UIImageJPEGRepresentation(newImage, 0.1);
        fileName = [NSString stringWithFormat:@"%f.jpg",[NSDate timeIntervalSinceReferenceDate]];
        // The imageName is a unique name each time, so in storage in the database, one message wouldn't replace another
        NSString *imageName = [[NSString alloc] init]; //[[NSProcessInfo processInfo] globallyUniqueString];//[[NSUUID UUID] UUIDString];
        imageName = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *childImageString = [NSString stringWithFormat:@"%@.jpg", imageName];
        FIRStorageReference *storageRef = [[[FIRStorage.storage reference] child:@"message_images"] child:childImageString];
        // Upload task
     FIRStorageUploadTask *uploadTask = [storageRef putData:fileData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Storage Error: %@", error);
            }
            
            NSLog(@"Metadata type: %@", metadata.contentType); // application/octet-stream the message's content type
            NSString *imageUrl = metadata.downloadURL.absoluteString; // URL of image

            Message *message = [[Message alloc] init];
            
            message.contentType = metadata.contentType;
            NSLog(@"Message Content Type: %@", message.contentType);
          
            [self sendMessagwWithImageUrl:imageUrl]; //sends message with imageurl
        }];
        // Tracks upload progress
        [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            NSLog(@"Upload Progress: %lld", snapshot.progress.completedUnitCount);
            
            double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
            self.progressView.progress = percentComplete;
        }];
        
        [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            NSLog(@"Succesful Image Upload");
            [self.tabBarController setSelectedIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:0 animated:NO];
            });

        }];
        
    }
    else {
        // Logic for video
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = [NSString stringWithFormat:@"%f.mov",[NSDate timeIntervalSinceReferenceDate]];
        message.contentType = @"video/quicktime";
        [self handleVideoSelectedForUrl:self.movieUrl];
    }

}
// Helper method for message with image url
- (void)sendMessagwWithImageUrl:(NSString *)imageUrl {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = ref.childByAutoId;

    NSString *toId = self.uid; // There is a toID, which is the recipient
    NSString *fromId = [[FIRAuth.auth currentUser] uid]; // There is a fromId which is current user's id
    Message *message = [[Message alloc] init];
    NSLog(@"Inside SendMessage: %@", message.contentType);
    NSDictionary *values = @{ @"imageUrl": imageUrl, @"toId": toId, @"fromId": fromId, @"contentType": @"application/octet-stream" }; // Values for message in database

    [childRef updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil) {
            NSLog(@"%@", error);
        }

        FIRDatabaseReference *userMessageRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:fromId] child:toId];

        NSString *messageId = childRef.key; // The message id
        [userMessageRef updateChildValues:@{ messageId: @1 }];
        FIRDatabaseReference *recipientUserMessagesRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:toId] child:fromId];
        [recipientUserMessagesRef updateChildValues:@{ messageId: @1 }];

    }];
}

// Helper method to send video with the url of video, almost same logic as image message
- (void)sendMessageWithVideoUrl:(NSString *)videoUrl {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    FIRDatabaseReference *childRef = ref.childByAutoId;
    
    NSString *toId = self.uid;
    NSString *fromId = [[FIRAuth.auth currentUser] uid];
    
    NSDictionary *values = @{ @"videoUrl": videoUrl, @"toId": toId, @"fromId": fromId, @"contentType": @"video/quicktime"}; // Values for message in database
    
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
    // Handles video with the storage url
    NSString *fileName = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
  FIRStorageUploadTask *uploadTask = [[[[FIRStorage.storage reference] child:@"message_movies"] child:fileName] putFile:url metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed upload of video: %@", error);
        }

        NSString *storageUrl = metadata.downloadURL.absoluteString;
      
        [self sendMessageWithVideoUrl:storageUrl]; // Also sends it
    }];
    // Tracking progress of video. Also the progress view looks better when sending video rather than image
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
        NSLog(@"Upload Progress: %lld", snapshot.progress.completedUnitCount);

        double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
        self.progressView.progress = percentComplete;
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
        NSLog(@"Succesful Video Upload");
        [self.tabBarController setSelectedIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:0 animated:NO];
        });
    }];
}
// Resets everything for next message
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
