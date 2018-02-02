//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "App.h"

@import Firebase;

@interface EditFriendsViewController ()
@property (strong, nonatomic) NSMutableArray *users;
@end

@implementation EditFriendsViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchUser];

    self.currentRibbitUser = [RibbitUser currentRibitUser];
    self.friends = [[RibbitUser userWithUsername:_currentRibbitUser.name] friends];
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
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RibbitUser *user = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    
    if ([self isFriend:user]) {
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
    RibbitUser *user = [self.users objectAtIndex:indexPath.row];

    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.currentRibbitUser removeFriend:user];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.delegate didMarkAsFriendDelegate:user];
        [self.currentRibbitUser addFriend:user];
    }    
}

#pragma mark - Helper methods

- (BOOL)isFriend:(RibbitUser *)user {
    Boolean isAdded = false;
    for (RibbitUser *tempUser in self.currentRibbitUser.friends) {
        if (tempUser.name == user.name) {
            isAdded = true;
        }
    }
    return isAdded;
}

- (void)fetchUser {
    
    self.users = [NSMutableArray array];

    [[[FIRDatabase.database reference] child:@"users"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        RibbitUser *user = [RibbitUser initWithDict:dict];
        user.id = snapshot.key;
        
     //   [user setValuesForKeysWithDictionary:dict];
        
        [self.users addObject:user];
        
        NSLog(@"%@", user.name);
        NSLog(@"%@", user.email);
        NSLog(@"%@", user.id);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } withCancelBlock:nil];
}

@end









