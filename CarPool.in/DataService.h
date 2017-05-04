//
//  DataService.h
//  CarPool.in
//
//  Created by Ron Ramirez on 4/29/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Geofire.h"
@import Firebase;
@import FirebaseStorage;


@interface DataService : NSObject

+(DataService *)ds;

//Database reference
@property (strong, nonatomic) FIRDatabaseReference *rootReference;
@property (strong, nonatomic) FIRDatabaseReference *publicUserReference;
@property (strong, nonatomic) FIRDatabaseReference *userReference;
@property (strong, nonatomic) FIRDatabaseReference *driverPostsReference;

//Geofire
@property (strong, nonatomic) FIRDatabaseReference *startingLocationsReference;
@property (strong, nonatomic) FIRDatabaseReference *endingLocationsReference;

//Push Notification Storage
@property (strong, nonatomic) FIRDatabaseReference *pushNotificationsReference;

//Database storage
@property (strong, nonatomic) FIRStorageReference *storageRefence;
@end
