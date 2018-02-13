//
//  InboxViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "Message.h"
#import "App.h"

#import "RibbitUser.h"
#import "UserCell.h"

@import Firebase;

@interface InboxViewController ()

@property (strong, nonatomic) NSMutableArray *mutableMessages;
@property (strong, nonatomic) NSMutableDictionary *messagesDictionary;
@property (strong, nonatomic) NSString *friendName;
@property (strong, nonatomic) NSMutableArray *inboxUsers;
@end

@implementation InboxViewController

static NSString * const resuseIdentifier = @"UserCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchUser];
    [self checkIfUserIsLoggedIn];

    self.moviePlayer = [[AVPlayerViewController alloc] init];
    self.tabBarController.delegate = self;
    self.users = [[NSMutableArray alloc] initWithObjects:self.inboxUsers, nil];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UIViewController *destView = [[self.tabBarController.viewControllers objectAtIndex:1] topViewController];
    if ([destView isKindOfClass:[FriendsViewController class]]){
        FriendsViewController *svc = (FriendsViewController *) destView;
        svc.users = self.users;
    }
    return TRUE;
}

- (NSMutableArray *)messages {
    self.mutableMessages = [[Message currentApp] messages];
    return self.mutableMessages;
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
    
    FIRDatabaseReference *messagesReference = [[[FIRDatabase.database reference] child:@"messages"] child:messageId];
    [messagesReference  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;

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
    
    if ([fileType isEqualToString:@"application/octet-stream"]) {

        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dict = snapshot.value;
            RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
            user.id = chatPartnerId;
            self.friendName = user.name;
        } withCancelBlock:nil];
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dict = snapshot.value;
            RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
            user.id = chatPartnerId;
            self.friendName = user.name;
        } withCancelBlock:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playVideo:message.videoUrl];
        });
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.mutableMessages removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSString *uid = [[FIRAuth.auth currentUser] uid];
        NSLog(@"CurrentUser: %@", uid);
        FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"user-messages"] child:uid];
        [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSString *userId = snapshot.key;
            
        FIRDatabaseReference *recipientRef = [[[[FIRDatabase.database reference] child:@"user-messages"] child:uid] child:userId];
          [recipientRef observeSingleEventOfType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *messageId = snapshot.key;

              [self deleteMessageWithMessageId:messageId];
              [self deleteUserMessageWithCurrentId:uid withRecipientId:userId withMessageId:messageId];
            } withCancelBlock:nil];
            
        } withCancelBlock:nil];
        
    }
}

- (void)deleteUserMessageWithCurrentId:(NSString *)uid withRecipientId:(NSString *)recipientId withMessageId:(NSString *)messageId {
    
    FIRDatabaseReference *ref = [[[[[FIRDatabase.database reference] child:@"user-messages"] child:uid] child:recipientId] child:messageId];
    FIRDatabaseReference *recipientRef = [[[[[FIRDatabase.database reference] child:@"user-messages"] child:recipientId] child:uid] child:messageId];
    [ref removeValue];
    [recipientRef removeValue];
}

- (void)deleteMessageWithMessageId:(NSString *)messageId {
    FIRDatabaseReference *userMessageRef = [[[FIRDatabase.database reference] child:@"messages"] child:messageId];
    [userMessageRef removeValue];
}


-(void)playVideo:(NSString *)videoUrl {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *videoURL = [NSURL URLWithString:videoUrl];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:^{
        [player play];
    }];
}

- (IBAction)logout:(id)sender {
    [self handleLogout];
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
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    } else {
        NSLog(@"SUCCESSFUL LOG OUT");
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)fetchUser {
    
    self.inboxUsers = [NSMutableArray array];
    
    [[[FIRDatabase.database reference] child:@"users"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
        user.id = snapshot.key;
        
        if (![user.id isEqualToString:[[FIRAuth.auth currentUser] uid]]) {
            [self.inboxUsers addObject:user];
            NSLog(@"Inbox users: %@", self.inboxUsers);
        } else {
            NSLog(@"Got you: %@", user.id);
        }
        
    } withCancelBlock:nil];
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
        imageViewController.imageUrlString = self.selectedMessage.imageUrl;
    }
}

@end
