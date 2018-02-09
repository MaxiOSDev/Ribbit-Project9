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

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *usersArray;
@end

@implementation EditFriendsViewController
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated {
    
    self.usersArray = [NSMutableArray array];
    
    for (NSMutableArray *array in self.users) {
        self.usersArray = array;
        NSLog(@"Users inside numberOfRows: %@", self.usersArray);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    return self.usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    NSLog(@"%@", self.users);
    
    for (NSMutableArray *array in self.users) {
        NSLog(@"Array: %@", array);
        RibbitUser *user = [array objectAtIndex:indexPath.row];
        NSLog(@"User Name: %@", user.name);
        cell.textLabel.text = user.name;
        
        if ( [self isFriend:user]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

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
        [userRef updateChildValues:@{ @"friendName": friendName, @"friendId": friendId}];
    }

}

#pragma mark - Helper methods

- (BOOL)isFriend:(RibbitUser *)user {
    Boolean isAdded = false;
    for (RibbitUser *tempUser in self.friends) {
        if (tempUser.friendId == user.id) {
            isAdded = true;
        }
    }
    return isAdded;
}

@end









