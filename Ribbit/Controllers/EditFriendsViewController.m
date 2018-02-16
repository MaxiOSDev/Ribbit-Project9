//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"



@import Firebase;

@interface EditFriendsViewController ()
// Stored Properties
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSArray *images;
@end

@implementation EditFriendsViewController
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated {
    
    self.usersArray = [NSMutableArray array];
    
    for (NSMutableArray *array in self.users) {
        self.usersArray = array;
       
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // setting user images. Not going to be the same becasue of the demo app
    self.images = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"HarpreetSingh.png"],
                   [UIImage imageNamed:@"HumayunKhan.png"],
                   [UIImage imageNamed:@"AmandaCarpenter.png"],
                   [UIImage imageNamed:@"CandiceBunkley.png"],
                   [UIImage imageNamed:@"DariusGalloway.png"],
                   [UIImage imageNamed:@"GregoryHester.png"],
                   [UIImage imageNamed:@"JarrodStanford.png"],
                   [UIImage imageNamed:@"PeterWeng.png"],
                   [UIImage imageNamed:@"StephanieVelasquez.png"],
                   [UIImage imageNamed:@"TobiasRay.png"],
                   [UIImage imageNamed:@"VictoriaBrown.png"],
                   [UIImage imageNamed:@"AlissaMurashev.png"],
                   [UIImage imageNamed:@"AlaniKahale.png"],
                   [UIImage imageNamed:@"LisaJennings.png"],
                   nil];

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
    
    // Populating cells with each user from database. Now, each user here has been verified.
   
    NSString *currentUser = [[FIRAuth.auth currentUser] uid];
    RibbitUser *userID = [[RibbitUser alloc] init];
    for (NSMutableArray *array in self.users) {
        
        if ([userID.id isEqualToString:currentUser]) {
            NSLog(@"Got you: %@", currentUser);
        } else {
            RibbitUser *user = [array objectAtIndex:indexPath.row];

            cell.textLabel.text = user.name;
            cell.imageView.image = [self.images objectAtIndex:indexPath.row];
            if ( [self isFriend:user]) { // Places checkmark next to users who are already friends
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
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
    RibbitUser *user = [self.usersArray objectAtIndex:indexPath.row];
    NSString *currentUser = [[FIRAuth.auth currentUser] uid];
    
    if ([self isFriend:user]) {
        NSLog(@"User is friend"); // If user is friend, do nothing
    } else {
        // If user is not a friend, then a new friend is added to database, and also a check mark
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSString *friendId = user.id;
        NSString *friendName = user.name;
        FIRDatabaseReference *userRef = [[[[[FIRDatabase.database reference] child:@"users"] child:currentUser] child:@"friends"] child:friendId];
        [userRef updateChildValues:@{ @"friendName": friendName, @"friendId": friendId}];
    }

}

#pragma mark - Helper methods
// Helper that checks if user is friend via the id of the user, and friend id
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









