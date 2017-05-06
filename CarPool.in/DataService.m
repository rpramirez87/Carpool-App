//
//  DataService.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/29/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "DataService.h"
static DataService *ds;

@implementation DataService

+ (DataService *)ds {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ds = [[DataService alloc]init];
        
        //Firebase Database
        ds.rootReference = [[FIRDatabase database] reference];
        ds.publicUserReference = [ds.rootReference child:@"publicUsers"];
        ds.userReference = [ds.rootReference child:@"users"];
        ds.driverPostsReference = [ds.rootReference child:@"carpoolPost"];
        
        //Geofire Databases
        ds.startingLocationsReference = [ds.rootReference child:@"startingLocations"];
        ds.endingLocationsReference = [ds.rootReference child:@"endingLocations"];
        
        //Push Notifications
        ds.pushNotificationsReference = [ds.rootReference child:@"notificationRequests"];
        ds.notificationsReference = [ds.rootReference child:@"notifications"];
    
        
       
        //Firebase Storage
        ds.storageRefence = [[FIRStorage storage] reference];
        
    });
    return ds;
}

@end
