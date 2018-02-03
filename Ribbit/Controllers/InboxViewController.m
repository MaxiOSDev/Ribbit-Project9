//
//  InboxViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "Message.h"
#import "App.h"
#import "File.h"
#import "RibbitUser.h"
#import "UserCell.h"

@import Firebase;

@interface InboxViewController ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *messagesDictionary;

@end

@implementation InboxViewController

static NSString * const resuseIdentifier = @"UserCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    self.moviePlayer = [[AVPlayerViewController alloc] init];
    [self setupNavBar];
}
 
-(void)setupNavBar {
    RibbitUser *currentUser = [RibbitUser currentRibitUser];
    
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.name);
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self checkIfUserIsLoggedIn];
    [self observeUserMessages];
}

- (void)observeUserMessages {
    

    
    NSString *uid = [[FIRAuth.auth currentUser] uid];
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"user-messages"] child:uid];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSString *userId = snapshot.key;
        [[[[[FIRDatabase.database reference] child:@"user-messages"] child:uid] child:userId] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *messageId = snapshot.key;
            [self fetchMessageWithMessageId:messageId];
        } withCancelBlock:nil];
   
    } withCancelBlock:nil];
}

- (void)fetchMessageWithMessageId:(NSString *)messageId {
    
    self.messages = [NSMutableArray array];
    
    FIRDatabaseReference *messagesReference = [[[FIRDatabase.database reference] child:@"messages"] child:messageId];
    [messagesReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
     //   Message *message = [Message initWithDict:dict];
        
        Message *message = [[Message alloc] initWithDictionary:dict];
        
        NSString *chatPartnerId = message.chatPartnerId;
        
        self.messagesDictionary[chatPartnerId] = message;
        
        [self.messages addObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } withCancelBlock:nil];
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
 //   return [self.messages count];
    NSLog(@"AMOUNT IN MESSAGES %lu", (unsigned long)self.messages.count);
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifier forIndexPath:indexPath];
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    cell.message = message;
    [cell setMessage:message];
    
    //    NSString *fileType = message.fileType;
    //    if ([fileType isEqualToString:@"image"]) {
    //        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    //    }
    //    else {
    //        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    //    }
    
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = self.selectedMessage.fileType;
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    NSString *chatPartnerId = message.chatPartnerId;
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:chatPartnerId];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
        user.id = chatPartnerId;
        NSLog(@"%@", message.imageUrl);
        NSLog(@"%@%@%@", user.id, user.name, user.email);
        [self performSegueWithIdentifier:@"showImage" sender:self];
    } withCancelBlock:nil];
    
    
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        // File type is video
        File *videoFile = self.selectedMessage.file;
        self.moviePlayer.player = [AVPlayer playerWithURL:videoFile.fileURL];
     //   self.moviePlayer.contentURL = videoFile.fileURL;
      //  [self.moviePlayer prepareToPlay];
        [self.moviePlayer.player play];
      //  [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoFile.fileURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        _thumbnail = one;
        // Add it to the view controller so we can see it
        [self.view addSubview:self.moviePlayer.view];
        
    //    [self.moviePlayer setFullscreen:YES animated:YES];
        [self goFullScreen];
    }
    
    // Delete it!
    [[App currentApp] deleteMessage:self.selectedMessage];
}

- (void)goFullScreen {
    NSString *selectorForFullscreen = @"_transitionToFullScreenViewControllerAnimated:completionHandler:";
    if (@available(iOS 11.0, *)) {
        selectorForFullscreen = @"_transitionToFullScreenAnimated:completionHandler:";
    }
    SEL fsSelector = NSSelectorFromString(selectorForFullscreen);
    if ([self respondsToSelector:fsSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:fsSelector]];
        [inv setSelector:fsSelector];
        [inv setTarget:self];
        BOOL animated = YES;
        id completionBlock = nil;
        [inv setArgument:&(animated) atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [inv setArgument:&(completionBlock) atIndex:3];
        [inv invoke];
    }
}

- (IBAction)logout:(id)sender {
    
    [self handleLogout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkIfUserIsLoggedIn {
    if ([[FIRAuth.auth currentUser] uid] == nil) {
        [self performSelector:@selector(handleLogout) withObject:nil afterDelay:0];
    } else {
        NSString *uid = [[FIRAuth.auth currentUser] uid];
        [[[[FIRDatabase.database reference] child:@"users"] child:uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *postDict = snapshot.value;
            self.navigationItem.title = [postDict objectForKey:@"name"];
            
        } withCancelBlock:nil];
    }
}

- (void)handleLogout {
    NSError *signoutError;
    BOOL status = [[FIRAuth auth] signOut:&signoutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signoutError);
    } else {
        NSLog(@"Successful Signout");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if ([segue.identifier isEqualToString:@"showImage"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}

@end
