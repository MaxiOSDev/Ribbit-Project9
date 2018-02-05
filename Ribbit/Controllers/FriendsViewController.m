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
@property (strong, nonatomic) NSMutableDictionary *friendsDictionary;
@end

@implementation FriendsViewController

static NSString * const resuseIdentifier = @"FriendCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Amount in friendsMutable: %lu", (unsigned long)self.friendsMutable.count);
    [self observeUserFriends];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    cell.friend = friend;
    [cell setFriend:friend];
    
    return cell;
}

- (void) didMarkAsFriendDelegate:(RibbitUser *)user {
    NSMutableArray *mutableArray2 = [[NSMutableArray alloc] init];
    
    NSLog(@"Friend here: %@", user);
    
    [mutableArray2 addObject:user];
    self.friendsMutable = mutableArray2;
    
    [self.tableView reloadData];
}

- (void)observeUserFriends {
    NSString *uid = [[FIRAuth.auth currentUser] uid];
    
    FIRDatabaseReference *ref = [[[FIRDatabase.database reference] child:@"user-friends"] child:uid];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *userId = snapshot.key;
        NSLog(@"UserID: %@", userId);
        [self fetchFriendWithFriendId:userId];
    } withCancelBlock:nil];
}

- (void)fetchFriendWithFriendId:(NSString *)friendId {
    self.friendsMutable = [NSMutableArray array];
    
    FIRDatabaseReference *friendsReference = [[[FIRDatabase.database reference] child:@"friends"] child:friendId];
    [friendsReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
        
        RibbitUser *friend = [[RibbitUser alloc] initWithFriendDictionary:dict];
        
        NSString *ribbitFriendId = friend.ribbitFriendId;
        
        self.friendsDictionary[ribbitFriendId] = friend;
        
        [self.friendsMutable addObject:friend];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } withCancelBlock:nil];
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







