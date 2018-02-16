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
    self.usernameField.delegate = self; // So I could dismiss my keyboards when pressing return
    self.passwordField.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    [self setupNavBar];
}

- (IBAction)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // Username aka email address.
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // email and password as a string
    
    if ([username length] == 0 || [password length] == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a username and password" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okayButton];
        
        [self presentViewController:alert animated:YES completion:nil]; // Presents alert in case no text added in textfields
    }
    else {
        
        [self handleLogin];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (IBAction)passwordRest:(id)sender {
    [self handlePasswordReset];
}

// Helpers

- (void)handlePasswordReset { // Resets password, well sends an email to reset password.
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Password" message:@"Enter email for password reset" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *emailField = textFields[0];
        [FIRAuth.auth sendPasswordResetWithEmail:emailField.text completion:^(NSError * _Nullable error) { // Firebase is awesome
            if (error != nil) {
                NSLog(@"Password Reset Error: %@", error); // All log statements are for the project reviewer, if this were an actual app, I would have alerted the user.
            } else {
                NSLog(@"Password Reset Email Sent");
            }
        }];
        
    }];
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleLogin { // The handle login helper method.
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // String representations
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Alert in case of invalid email address or password
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Make sure you enter a valid username and password" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okayButton];

    // Where the magic happens and signs the user in via real email and password from gmail, or teamtreehouse.com.
    [FIRAuth.auth signInWithEmail:username password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        user = [FIRAuth.auth currentUser];
        // Checking if email is verified from the email verification sent to user's actual email. Thus fake emails won't be able to log in.
        if (user.isEmailVerified) {
            NSLog(@"user verified");
            [self performSegueWithIdentifier:@"showInbox" sender:self]; // If user is verified proceed to the inbox of user.
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login Denied" message:@"Email not verified, please veify email" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okayButton];
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"user Not verified"); // User not verified, and again, just alerting the reviewer of the project.
            // In case user is not verified, and automatic resend of the email verification will occur.
            [user sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"%@", error);
                } else {
                    NSLog(@"Verification email sent."); // Checks
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault]; // Had to work some magic with a transparent Nav bar and back button
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
}
// So my keyboard can dismiss after pressing return.
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end



