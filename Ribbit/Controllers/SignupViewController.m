//
//  SignupViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#import "SignupViewController.h"
#import "User.h"
#import "RibbitUser.h"

@import Firebase;


@interface SignupViewController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    [self setupNavBar];
}

- (IBAction)signup:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
//                                                            message:@"Make sure you enter a username, password, and email address!"
//                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a username, password, and email address!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        User *newUser = [User currentUser];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        [self handleRegister];
//        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
//                                                                    message:[error.userInfo objectForKey:@"error"]
//                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alertView show];
//            }
//            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
//            }
//        }];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRegister {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [FIRAuth.auth createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error);
        }
        self.ref = [[FIRDatabase database] referenceFromURL:@"https://ribbit-c31a4.firebaseio.com/"];
        NSDictionary *dict = @{ @"name" : username, @"email" : email};
        NSString *uid = user.uid;
        
        FIRDatabaseReference *usersReference = [[self.ref child:@"users"] child:uid];
        
        [usersReference updateChildValues:dict withCompletionBlock:^(NSError * _Nullable err, FIRDatabaseReference * _Nonnull ref) {
            if (err != nil) {
                NSLog(@"%@", err);
            }
            
            [self registerUserIntoDatabaseWithUID:uid :dict];
            NSLog(@"Saved user successfully into Firebase Database");
        }];
    }];

}

-(void)registerUserIntoDatabaseWithUID:(NSString *)uid :(NSDictionary *)dict {
    FIRDatabaseReference *ref = [FIRDatabase.database reference];
    FIRDatabaseReference *usersReference = [[ref child:@"users"] child:uid];
    [usersReference updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil) {
            NSLog(@"%@", error);
        }
        
    //    RibbitUser *user = [RibbitUser initWithDict:dict];
        
        
        
    }];
}

- (void)setupNavBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
}

@end
