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

@property (strong, nonatomic) NSMutableArray *mutableMessages;
@property (strong, nonatomic) NSMutableDictionary *messagesDictionary;

@property(strong, nonatomic) NSString *friendName;

@end

@implementation InboxViewController

static NSString * const resuseIdentifier = @"UserCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkIfUserIsLoggedIn]; // So it doubles the users if this method is moved to viewWillAppear.. That's not good at all. So until then leave this for last.
   // self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer = [[AVPlayerViewController alloc] init];
}

- (NSMutableArray *)messages {
    self.mutableMessages = [[Message currentApp] messages];
    return self.mutableMessages;
}

- (void)observeUserMessages {

    NSString *uid = [[FIRAuth.auth currentUser] uid];
    NSLog(@"CurrentUser: %@", uid);
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"user-messages"] child:uid];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        NSString *userId = snapshot.key;
        
        NSLog(@"User ID: %@", userId);
        [[[[[FIRDatabase.database reference] child:@"user-messages"] child:uid] child:userId] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *messageId = snapshot.key;
            [self fetchMessageWithMessageId:messageId];
            
        } withCancelBlock:nil];

    } withCancelBlock:nil];
}

- (void)fetchMessageWithMessageId:(NSString *)messageId {
    
    FIRDatabaseReference *messagesReference = [[[FIRDatabase.database reference] child:@"messages"] child:messageId];
    [messagesReference  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
       
        NSDictionary *dict = snapshot.value;
        NSLog(@"%@", dict);
        
        if ([dict[@"toId"] isEqualToString:FIRAuth.auth.currentUser.uid]) {
            
            Message *message = [[[Message alloc] initWithDictionary:dict] initWithVideoMessageDictionary:dict];
            
            [[Message currentApp] addMessage:message];
        } else {
            NSLog(@"Not a message to me: %@", dict[@"fromId"]);
        }

        NSLog(@"MutableArray amount3: %lu", (unsigned long)self.messages.count);
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

    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifier forIndexPath:indexPath];
    
        Message *message = [self.messages objectAtIndex:indexPath.row];
        cell.message = message;
        [cell setMessage:message];
    
    cell.layer.borderWidth = 4.0f;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     NSLog(@"MutableArray amount4: %lu", (unsigned long)self.messages.count);
    
        NSString *fileType = message.contentType;
        if ([fileType isEqualToString:@"application/octet-stream"]) {
            cell.imageView.image = [UIImage imageNamed:@"icon_image"];
        }

        else {
            cell.imageView.image = [UIImage imageNamed:@"icon_video"];
        }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   self.selectedMessage = [self.messages objectAtIndex:indexPath.row];

    Message *message = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = message.contentType;
    NSString *chatPartnerId = message.chatPartnerId;
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:chatPartnerId];
    
    NSLog(@"File Type: %@", fileType);
    
    if ([fileType isEqualToString:@"application/octet-stream"]) {

        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dict = snapshot.value;
            RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
            user.id = chatPartnerId;
            self.friendName = user.name;
            NSLog(@"%@", message.imageUrl);
            NSLog(@"%@%@%@", user.id, user.name, user.email);
        } withCancelBlock:nil];
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
    if ([[FIRAuth.auth currentUser] uid] != nil) {
        NSString *uid = [[FIRAuth.auth currentUser] uid];
        [[[[FIRDatabase.database reference] child:@"users"] child:uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *postDict = snapshot.value;
            NSLog(@"postDict: %@", postDict);
            self.navigationItem.title = [postDict objectForKey:@"name"];
            NSLog(@"logged in");
            [self.messages removeAllObjects];
            [self observeUserMessages];
            
        } withCancelBlock:nil];
    } else {
        NSLog(@"Not Logged In");
        [self performSelector:@selector(handleLogout) withObject:nil afterDelay:0];
    }
}

- (void)handleLogout {

    NSError *error;
    if ([FIRAuth.auth currentUser] != nil) {
        [FIRAuth.auth signOut:&error];
    } else {
        [self.messages removeAllObjects];
        NSLog(@"MutableMEssages after Log Out: %lu", (unsigned long)self.mutableMessages.count);
        [self performSegueWithIdentifier:@"showLogin" sender:self];

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
        imageViewController.senderName = self.friendName;
    }
}

@end
