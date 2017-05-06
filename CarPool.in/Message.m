//
//  Message.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/6/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithDict:(NSDictionary *)messageDict {
    if (self = [super init]) {
        //Initlaize message
        self.senderID = [messageDict valueForKey:@"senderID"];
        self.senderName = [messageDict valueForKey:@"senderName"];
        self.message = [messageDict valueForKey:@"message"];
    }
    return self;
}


@end
