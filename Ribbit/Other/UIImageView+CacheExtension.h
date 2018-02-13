//
//  UIImageView+CacheExtension.h
//  Ribbit
//
//  Created by Max Ramirez on 2/2/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CacheExtension)
- (UIImageView *)loadImageUsingCacheWithUrlString:(NSString *)urlString;
@end
