//
//  SelectViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/1/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "SelectViewController.h"
#import "MapKit/Mapkit.h"
#import "CoreLocation/CoreLocation.h"
#import "DataService.h"
#import "DriverPostTableViewCell.h"
#import "DriverPost.h"
#import "UserDestination.h"

@interface SelectViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *carpoolPostsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLocation *userLocation;
@end

@implementation SelectViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize properties
    self.carpoolPostsArray = [[NSMutableArray alloc] init];
    self.userLocation = [[CLLocation alloc] initWithLatitude:41.9048757 longitude:-88.33587759999999];
    
    //Unhide Navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    //Delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.mapView.delegate = self;
    
    //Setup annotation for center point
    MKPointAnnotation *centerPin = [[MKPointAnnotation alloc] init];
    centerPin.title = @"User Location";
    centerPin.coordinate = self.userLocation.coordinate;
    [self.mapView addAnnotation:centerPin];
    
    //Set up viewing of map view
    MKCoordinateRegion region = self.mapView.region;
    region.center = self.userLocation.coordinate;
    region.span.latitudeDelta = 0.2;
    region.span.longitudeDelta = 0.2;
    [self.mapView setRegion:region animated:YES];
    
    //Call Geoquery
    [self loadAllDriversPostsUsingGeofireWithLocation:self.userLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table View Delegate Functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DriverPost *currentDriverPost = self.carpoolPostsArray[indexPath.row];
    static NSString *cellIdentifier = @"CarpoolPostCell";
    DriverPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithDriverPost:currentDriverPost];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.carpoolPostsArray.count;
}

#pragma mark - Geofire Query

- (void)loadAllDriversPostsUsingGeofireWithLocation:(CLLocation *)userLocation {
    
    //Clear all objects
    [self.carpoolPostsArray removeAllObjects];
    
    //Setup Location and Geoquery
    FIRDatabaseReference *endingLocationReference = [[DataService ds] endingLocationsReference];
    GeoFire *endingLocationGeofire = [[GeoFire alloc] initWithFirebaseRef:endingLocationReference];
    
    GFCircleQuery *circleQuery = [endingLocationGeofire queryAtLocation:userLocation withRadius:20.0];
    [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Circle Query - Key '%@' entered the search area and is at location '%@'", key, location);
        
        [[[[DataService ds] driverPostsReference]child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            //Convert snapshot value to dictionary
            NSMutableDictionary *driverPostDictionary = snapshot.value;
            double metersToMilesConverter = 0.000621371;
            driverPostDictionary[@"miles"] = [NSString stringWithFormat:@"%.2f miles",[userLocation distanceFromLocation:location] * metersToMilesConverter];
            
            NSLog(@"Distance from Location in meters %f", [userLocation distanceFromLocation:location]);
            NSLog(@"Driver Post - %@", driverPostDictionary);
            DriverPost *driverPost = [[[DriverPost alloc] init] initWithDict:driverPostDictionary andKey:snapshot.key];
            
            if (self.isSelectingRiders) {
                //Add all the riders to array
                if ([driverPost.isDriver isEqualToString:@"NO"]) {
                    [self.carpoolPostsArray addObject:driverPost];
                }
            }else{
                //Add all drivers to array
                if ([driverPost.isDriver isEqualToString:@"YES"]) {
                    [self.carpoolPostsArray addObject:driverPost];
                }
            }
            [self.tableView reloadData];
            [self reloadLocations];
        }];
    }];
}

#pragma mark - MapKit Functions

- (void)reloadLocations {
//    for (id<MKAnnotation> annotation in self.mapView.annotations) {
//        [self.mapView removeAnnotation:annotation];
//    }
    
    FIRDatabaseReference *endingLocationReference = [[DataService ds] endingLocationsReference];
    GeoFire *endingLocationsGeofire = [[GeoFire alloc] initWithFirebaseRef:endingLocationReference];
    
    for (DriverPost *post in self.carpoolPostsArray) {
        
        [endingLocationsGeofire getLocationForKey:post.drivePostID withCallback:^(CLLocation *location, NSError *error) {
            if (error != nil) {
                NSLog(@"An error occurred getting the location for \"firebase-hq\": %@", [error localizedDescription]);
            } else if (location != nil) {
                NSLog(@"Location for \"%@\" is [%f, %f]",
                      post.drivePostID,
                      location.coordinate.latitude,
                      location.coordinate.longitude);
                NSString * endingAddress = post.endingAddress;
                NSString * distance = post.milesInDistanceString;
                UserDestination *annotation = [[UserDestination alloc] initWithName:endingAddress address:distance coordinate:location.coordinate];
                [self.mapView addAnnotation:annotation];
            } else {
                NSLog(@"GeoFire does not contain a location for \"firebase-hq\"");
            }
        }];
    }
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSLog(@"Did we get here");
    
    static NSString *identifer = @"MKMapView";
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifer];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifer];
            
        }else{
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.image = [UIImage imageNamed:@"userLocationPin"];
        annotationView.canShowCallout = YES;
        
        
        return annotationView;
    }
    return nil;
}
@end
