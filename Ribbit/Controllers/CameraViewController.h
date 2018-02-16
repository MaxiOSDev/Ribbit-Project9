//
//  CameraViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Stored properties and IBOutlets and Actions
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSURL *movieUrl;
- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
- (void)uploadMessage; // Method to upload message
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView; // Progress view!
@end
