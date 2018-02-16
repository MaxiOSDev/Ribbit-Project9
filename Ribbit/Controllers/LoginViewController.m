//
//  LoginViewController.m
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

#import "LoginViewController.h"
@import Firebase;

@interface LoginViewController ()
@property (strong, nonatomic) NSString *email;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    [self setupNavBar];
}

- (IBAction)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a username and password" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okayButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        [self handleLogin];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (IBAction)passwordRest:(id)sender {
    [self handlePasswordReset];
}

- (void)handlePasswordReset {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Password" message:@"Enter Email for password reset" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *emailField = textFields[0];
        [FIRAuth.auth sendPasswordResetWithEmail:emailField.text completion:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Password Reset Error: %@", error);
            } else {
                NSLog(@"Password Reset Email Sent");
            }
        }];
        
    }];
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleLogin {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a valid username and password" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okayButton];

    
    [FIRAuth.auth signInWithEmail:username password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        user = [FIRAuth.auth currentUser];
        
        if (user.isEmailVerified) {
            NSLog(@"user verified");
            [self performSegueWithIdentifier:@"showInbox" sender:self];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login Denied" message:@"Email not verified, please veify email" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okayButton];
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"user Not verified");
            
            [user sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"%@", error);
                } else {
                    NSLog(@"Verification email sent.");
                }
            }];
        
        }
        
        if (error != nil) {
            [self presentViewController:alert animated:YES completion:nil];
            NSLog(@"Error here after attempting to sign in: %@", error);
        }
        
    }];
}

- (void)setupNavBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end



