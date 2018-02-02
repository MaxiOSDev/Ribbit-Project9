//
//  InboxViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "Message.h"
#import "User.h"
#import "App.h"
#import "File.h"
#import "RibbitUser.h"
@import Firebase;

@interface InboxViewController ()
@property (strong, nonatomic) NSMutableArray *messages;
@end

@implementation InboxViewController

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
        //  [self performSegueWithIdentifier:@"showLogin" sender:self];
        NSLog(@"Testing: %@", currentUser.name);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self checkIfUserIsLoggedIn];
    [self observeUserMessages];
}

- (void)observeUserMessages {
    
    NSString *uid = [[FIRAuth.auth currentUser] uid];
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"user-messages"] child:uid];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSString *messagesId = snapshot.key;
        FIRDatabaseReference *messagesRef = [[[FIRDatabase.database reference] child:@"messages"] child:messagesId];
        
        [messagesRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            Message *message = [[Message alloc] init];
            [message setValuesForKeysWithDictionary:dict];
            NSString *toId = message.toId;
            
            
            
        } withCancelBlock:nil];
        
    } withCancelBlock:nil];
}

- (void)observeMessages {
    FIRDatabaseReference *ref = [[FIRDatabase.database reference] child:@"messages"];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        Message *message = [[Message alloc] init];
        [message setValuesForKeysWithDictionary:dict];
        [self.messages addObject:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } withCancelBlock:nil];
}

//- (NSArray *)messages {
//  return [[App currentApp] messages];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self messages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Message *message = [[self messages] objectAtIndex:indexPath.row];
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"users"] child:message.toId];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
       
        NSDictionary *dict = snapshot.value;
        cell.textLabel.text = [dict objectForKey:@"name"];
        
    } withCancelBlock:nil];
    
    
    NSString *fileType = message.fileType;
    if ([fileType isEqualToString:@"image"]) {
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
    self.selectedMessage = [[self messages] objectAtIndex:indexPath.row];
    NSString *fileType = self.selectedMessage.fileType;
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
//    [User logOut];
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    } else {
        NSLog(@"Successful Signout");
    }
    
  //  [self performSegueWithIdentifier:@"showLogin" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil]; // This isn't sufficient because in instagram it modally presents the login screen yet again with the credentials from before... It does not dismiss the modally presented view controller, an idea that I am having is to programmatically create a segue and then present it modally. But I get that crash when I try to segue to the sign up VC.. and thats a problem. Can't have that..
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
