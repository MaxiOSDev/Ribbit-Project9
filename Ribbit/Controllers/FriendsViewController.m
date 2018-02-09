//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "App.h"
#import "RibbitUser.h"
#import "FriendCell.h"

@interface FriendsViewController ()
@property (strong, nonatomic) NSMutableArray *friendsMutable;
@end

@implementation FriendsViewController

static NSString * const resuseIdentifier = @"FriendCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"Amount in friendsMutable: %lu", (unsigned long)self.friendsMutable.count);
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self observeUserFriends];
    self.friends = [[RibbitUser currentRibitUser] friends];

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
    return [self.friendsMutable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseIdentifier forIndexPath:indexPath];
    RibbitUser *friend = [self.friendsMutable objectAtIndex:indexPath.row];
    cell.nameLabel.text = friend.friendName;
    cell.layer.borderWidth = 4.0f;
    cell.layer.borderColor= [UIColor whiteColor].CGColor;
    
    return cell;
}


- (void)observeUserFriends {
    
    self.friendsMutable = [NSMutableArray array];
    NSString *currentUser = [FIRAuth.auth currentUser].uid;
    FIRDatabaseReference *usersRef = [[[[FIRDatabase.database reference] child:@"users"] child:currentUser] child:@"friends"];

    
    [usersRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        NSLog(@"%@", dict);
        RibbitUser *friendUser = [[RibbitUser alloc] initWithFriendDictionary:dict];
        friendUser.id = snapshot.key;
        friendUser.friendName = dict[@"friendName"];
        [self.friendsMutable addObject:friendUser];
        NSLog(@"%@", friendUser.id);
        NSLog(@"%@", friendUser.friendName);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } withCancelBlock:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEditFriends"]) {
        EditFriendsViewController *editFriendsVC = [segue destinationViewController];
        editFriendsVC.currentRibbitUser = [self currentUser];
        editFriendsVC.friends = [self friendsMutable];
        editFriendsVC.mutableFriendsArray = [self friendsMutable];
        editFriendsVC.delegate = self;
    }
}

@end







