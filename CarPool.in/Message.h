//
//  Message.h
//  CarPool.in
//
//  Created by Ron Ramirez on 5/6/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
@property (strong, nonatomic) NSString *senderID;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *message;

#pragma mark - Custom Initializers

- (instancetype)initWithDict:(NSDictionary *)messageDict;

@end
