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

@property (weak, nonatomic) File *file;
@property (strong, nonatomic) NSArray *recipients;

@property (weak, nonatomic) NSString *fileType; // Solved Bug Issue #5 // before Firebase. Came back still after Firebase
@property (nonatomic, copy) NSString *contentType;

@property (copy, nonatomic) NSString *senderName;

// New Messages Properties
@property (strong, nonatomic) NSString *fromId;
@property (strong, nonatomic) NSNumber *timeStamp;
@property (strong, nonatomic) NSString *toId;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) NSMutableArray *messages;

- (void) deleteMessage:(Message*)message;
- (void) addMessage:(Message*)message;

+ (instancetype) currentApp;
- (NSMutableArray*)messages;

- (NSString *)chatPartnerId;
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithVideoMessageDictionary:(NSDictionary *)dict;
@end
