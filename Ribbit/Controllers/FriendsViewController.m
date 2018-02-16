//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "RibbitUser.h"
#import "FriendCell.h"

@interface FriendsViewController ()
// Stored properties
@property (strong, nonatomic) NSMutableArray *friendsMutable;
@property (strong, nonatomic) NSArray *images;
@end

@implementation FriendsViewController

static NSString * const resuseIdentifier = @"FriendCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Demo images so the app could resemble mockups. In an actual app I would have handled this with a way a user could place a their own profile picture.
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
// Observes User friends each time in view will Appear
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
    
      cell.imageView.image = [self.images objectAtIndex:indexPath.row];
    return cell;
}


- (void)observeUserFriends {
    // Retrieve user friends from database
    self.friendsMutable = [NSMutableArray array];
    NSString *currentUser = [FIRAuth.auth currentUser].uid;
    FIRDatabaseReference *usersRef = [[[[FIRDatabase.database reference] child:@"users"] child:currentUser] child:@"friends"];
    
    
    [usersRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dict = snapshot.value;
       
        RibbitUser *friendUser = [[RibbitUser alloc] initWithFriendDictionary:dict];
        friendUser.id = snapshot.key;
        friendUser.friendName = dict[@"friendName"];
        friendUser.friendId = dict[@"friendId"];
        [self.friendsMutable addObject:friendUser];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } withCancelBlock:nil];
}
// Sends data of who is a friend already so user knows which users are already their friends
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEditFriends"]) {
        EditFriendsViewController *editFriendsVC = [segue destinationViewController];
        editFriendsVC.currentRibbitUser = [self currentUser];
        editFriendsVC.friends = [self friendsMutable];
        editFriendsVC.mutableFriendsArray = [self friendsMutable];
        editFriendsVC.delegate = self;
        editFriendsVC.users = self.users;
    }
}

@end







