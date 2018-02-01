//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "App.h"
#import "User.h"

@interface FriendsViewController ()
@property (strong, nonatomic) NSMutableArray *friendsMutable;
@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
  //  self.friends = [[User currentUser] friends];
   // self.friends = [[App currentApp] allUsers];
    self.friends = [[RibbitUser currentRibitUser] friends];
    
    [self.tableView reloadData];
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
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
  //  User *user = [self.friends objectAtIndex:indexPath.row];
    RibbitUser *user = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.name;
    
    return cell;
}


- (void) didMarkAsFriendDelegate:(RibbitUser *)user {
    NSMutableArray *mutableArray2 = [[NSMutableArray alloc] init];
    
    NSLog(@"Friend here: %@", user);
    
    [mutableArray2 addObject:user];
    self.friendsMutable = mutableArray2;
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEditFriends"]) {
        EditFriendsViewController *editFriendsVC = [segue destinationViewController];
        editFriendsVC.currentRibbitUser = [self currentUser];
        editFriendsVC.friends = [self friends];
        editFriendsVC.mutableFriendsArray = [self friendsMutable];
        editFriendsVC.delegate = self;
    }
}

@end







