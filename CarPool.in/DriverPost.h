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
@property (strong, nonatomic) NSString *isDriver;
@property (strong, nonatomic) NSString *drivePostID;
@property (strong, nonatomic) NSString *carColor;
@property (strong, nonatomic) NSString *carModel;

//Initializer methods
- (instancetype)initWithDict:(NSDictionary *)driverPostDict;
- (instancetype)initWithDict:(NSDictionary *)driverPostDict andKey:(NSString *)key;
@end
