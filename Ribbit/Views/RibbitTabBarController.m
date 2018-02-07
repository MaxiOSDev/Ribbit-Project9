//
//  RibbitTabBarController.m
//  Ribbit
//
//  Created by Max Ramirez on 2/7/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import "RibbitTabBarController.h"

@interface RibbitTabBarController ()

@end

@implementation RibbitTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
