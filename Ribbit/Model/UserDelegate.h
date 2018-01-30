//
//  UserDelegate.h
//  Ribbit
//
//  Created by Max Ramirez on 1/30/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class App;
@protocol UserDelegate <NSObject>
@optional
-(void)didLoginWithUser:(App *)user;
@end
