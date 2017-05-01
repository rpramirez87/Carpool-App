//
//  DriverPost.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/30/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "DriverPost.h"

@implementation DriverPost


- (instancetype)initWithDict:(NSDictionary *)driverPostDict {
    if (self = [super init]) {
        self.startingAddress = [driverPostDict valueForKey:@"startingAddress"];
        self.endingAddress = [driverPostDict valueForKey:@"endingAddress"];
        self.ownerKey = [driverPostDict valueForKey:@"ownerKey"];
        self.time = [driverPostDict valueForKey:@"time"];
        self.milesInDistanceString = [driverPostDict valueForKey:@"miles"];
    }
    return self;
}
@end
