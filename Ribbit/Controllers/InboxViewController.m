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

@interface InboxViewController ()

@end

@implementation InboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    User *currentUser = [User currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
      //  [self performSegueWithIdentifier:@"showLogin" sender:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSArray *)messages {
  return [[App currentApp] messages];
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
    return [[self messages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Message *message = [[self messages] objectAtIndex:indexPath.row];
    cell.textLabel.text = message.senderName;
    
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
        self.moviePlayer.contentURL = videoFile.fileURL;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        // Add it to the view controller so we can see it
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    // Delete it!
    [[App currentApp] deleteMessage:self.selectedMessage];
}

- (IBAction)logout:(id)sender {
//    [User logOut];
    
  //  [self performSegueWithIdentifier:@"showLogin" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil]; // This isn't sufficient because in instagram it modally presents the login screen yet again with the credentials from before... It does not dismiss the modally presented view controller, an idea that I am having is to programmatically create a segue and then present it modally. But I get that crash when I try to segue to the sign up VC.. and thats a problem. Can't have that..
    
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
