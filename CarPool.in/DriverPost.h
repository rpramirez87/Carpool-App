//
//  DriverPost.h
//  CarPool.in
//
//  Created by Ron Ramirez on 4/30/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverPost : NSObject
@property (strong, nonatomic) NSString *startingAddress;
@property (strong, nonatomic) NSString *endingAddress;
@property (strong, nonatomic) NSString *ownerKey;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *milesInDistanceString;

//Initializer methods
- (instancetype)initWithDict:(NSDictionary *)driverPostDict;
@end
