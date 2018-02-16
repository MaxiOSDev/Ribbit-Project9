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
    // All textfields delegates is self so return button dismisses after pressing return.
    self.usernameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    // Yes, hid that back button!
    self.navigationItem.hidesBackButton = YES;
    [self setupNavBar];
}

- (IBAction)signup:(id)sender {
    // String representations
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Checks for if no text is entered in signup textfields
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a username, password, and email address!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        [self handleRegister]; // Helper method to handle the register
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRegister {
    // String textfields text
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Creating the user into the database via email and password. Username gets stored too
    [FIRAuth.auth createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error);
        }
        self.ref = [[FIRDatabase database] reference];
        NSDictionary *dict = @{ @"name" : username, @"email" : email}; // Magnifico
        NSString *uid = user.uid; // Users special id
        
        FIRDatabaseReference *usersReference = [[self.ref child:@"users"] child:uid]; // Boom JSON Tree
        
        [usersReference updateChildValues:dict withCompletionBlock:^(NSError * _Nullable err, FIRDatabaseReference * _Nonnull ref) {
            if (err != nil) {
                NSLog(@"%@", err);
            }
            
            [self registerUserIntoDatabaseWithUID:uid :dict];
            
            [[FIRAuth.auth currentUser] sendEmailVerificationWithCompletion:^(NSError * _Nullable error) { // Need to send that email verification!
                if (error != nil) {
                    NSLog(@"%@", error);
                }
            }];
            
            NSLog(@"Saved user successfully into Firebase Database");// All is well
        }];
    }];

}
// Helper method to register use into database with very own unique id
-(void)registerUserIntoDatabaseWithUID:(NSString *)uid :(NSDictionary *)dict {
    FIRDatabaseReference *ref = [FIRDatabase.database reference];
    FIRDatabaseReference *usersReference = [[ref child:@"users"] child:uid];
    [usersReference updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error != nil) {
            NSLog(@"%@", error);
        }

    }];
}
// Some UI improvements
- (void)setupNavBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
}
// Dimisses keyboard when pressing return
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
