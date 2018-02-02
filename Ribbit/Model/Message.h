//
//  Message.h
//  Ribbit
//
//  Created by Amit Bijlani on 8/25/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class File;

@interface Message : NSObject

@property (strong, nonatomic) File *file;
@property (strong, nonatomic) NSArray *recipients;

@property (weak, nonatomic) NSString *fileType; // Solbed Bug Issue #5
@property (copy, nonatomic) NSString *senderId;
@property (copy, nonatomic) NSString *senderName;

// New Messages Properties
@property (strong, nonatomic) NSString *fromId;
@property (strong, nonatomic) NSNumber *timeStamp;
@property (strong, nonatomic) NSString *toId;
@property (strong, nonatomic) NSString *imageUrl;

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block;

@end
