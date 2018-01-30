//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "User.h"
#import "App.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
  
  [self.tableView reloadData];

    self.currentUser = [User currentUser];
    NSLog(@"%@", self.currentUser.friends);
 //   NSLog(@"Friends Mutable: %@", _friends);
 //   self.friends = [[User currentUser] friends];
    self.friends = [[User userWithUsername:_currentUser.username] friends];
}

- (NSArray *)allUsers {
  return [[App currentApp] allUsers];
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
    return [self.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    User *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
 //   NSLog(@"User ID and Name in cellForRow: %@%@", user.objectId, user.username);
    
    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSLog(@"Yes friend: %@", user.username);
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSLog(@"No friend: %@", user.username);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
    User *user = [self.allUsers objectAtIndex:indexPath.row];
 //   NSLog(@"User ID and name within didSelect: %@%@", user.objectId, user.username);
    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.currentUser removeFriend:user];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.delegate didMarkAsFriendDelegate:user];
        [self.currentUser addFriend:user];
    }    
}

#pragma mark - Helper methods

- (BOOL)isFriend:(User *)user {
    Boolean isAdded = false;
    for (User *tempUser in self.currentUser.friends) {
        if (tempUser.username == user.username) {
            isAdded = true;
        }
    }
    return isAdded;
}

@end
