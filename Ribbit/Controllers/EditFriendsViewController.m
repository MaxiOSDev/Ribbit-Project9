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
@property (strong, nonatomic) NSString *uid;
@end

@implementation EditFriendsViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchUser];

    self.currentRibbitUser = [RibbitUser currentRibitUser];
    NSLog(@"Friend: %@", self.friends);
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

    
    NSLog(@"User.Name: %@\n", user.name);
    NSLog(@"User.FriendName: %@\n", user.friendName);
    
    for (RibbitUser *friendUser in self.friends ) {
        NSLog(@"Amount of friends: %lu", (unsigned long) self.friends.count);
        NSLog(@"Friend User With Friend Name: %@\n", user.friendName);
        if ([user.name isEqualToString:friendUser.friendName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    


    cell.textLabel.text = user.name;
    cell.textLabel.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:241.0/255.0 blue:251.0/255.0 alpha:1.0];
    cell.layer.borderWidth = 4.0f;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    RibbitUser *user = [self.users objectAtIndex:indexPath.row];
    NSString *currentUser = [[FIRAuth.auth currentUser] uid];
    if ([self.friends containsObject:user.id]) {
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSString *friendId = user.id;
        NSString *friendName = user.name;
        FIRDatabaseReference *userRef = [[[[[FIRDatabase.database reference] child:@"users"] child:currentUser] child:@"friends"] child:friendId];
        [userRef updateChildValues:@{ @"friendName": friendName}];
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
        RibbitUser *user = [[RibbitUser alloc] initWithDictionary:dict];
        user.id = snapshot.key;
        
        if (user.id != [FIRAuth.auth currentUser].uid) {
            [self.users addObject:user];
        } else {
            NSLog(@"Got you: %@", user.id);
        }


        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } withCancelBlock:nil];
}

@end









