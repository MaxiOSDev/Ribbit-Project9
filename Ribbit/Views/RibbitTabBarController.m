//
//  RibbitTabBarController.m
//  Ribbit
//
//  Created by Max Ramirez on 2/7/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "RibbitTabBarController.h"
#import "FriendsViewController.h"
#import "RibbitUser.h"
@import Firebase;

@interface RibbitTabBarController ()

@end

@implementation RibbitTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Custom UI for tab bar controller
    UITabBar *tabBar = self.tabBar;
    CGSize imgSize = CGSizeMake(tabBar.frame.size.width/tabBar.items.count,tabBar.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    UIBezierPath* p =
    [UIBezierPath bezierPathWithRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    [[UIColor colorWithRed:99.0/255.0 green:48.0/255.0 blue:146.0/255.0 alpha:1.0] setFill];
    [p fill];
    UIImage* finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [tabBar setSelectionIndicatorImage:finalImg];
    UIColor *color = [UIColor whiteColor];
    NSDictionary *dict = @{ NSForegroundColorAttributeName : color };
    [UITabBarItem.appearance setTitleTextAttributes:(dict) forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
