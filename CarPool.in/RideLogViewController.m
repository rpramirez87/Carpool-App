//
//  RideLogViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/28/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "RideLogViewController.h"
#import "DataService.h"
#import "DriverPost.h"
#import "DriverPostTableViewCell.h"
#import "CoreLocation/CoreLocation.h"
#import "ProfileViewController.h"
#import "JSBadgeView.h"

@interface RideLogViewController ()<UISearchResultsUpdating,UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *driverPostsArray;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation RideLogViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.driverPostsArray = [[NSMutableArray alloc] init];
    
    //Load all driverPosts for now
    [self loadAllDriverPostsFromFirebase];
    
    //Initialize Search Controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    //Implement when we have time
    //self.searchController.searchBar.scopeButtonTitles = @[@"Date", @"Distance"];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.placeholder = @"Enter destination";
    
    //Initialize Badge View
    // TODO: Add JSBadgeView
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory Warning");
    
}

#pragma mark - UITableView Delegate Functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get current carpool post
    DriverPost *currentDriverPost = self.driverPostsArray[indexPath.row];
    static NSString *cellIdentifier = @"CarpoolPostCell";
    DriverPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithDriverPost:currentDriverPost];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.driverPostsArray.count;
}

#pragma mark - IBActions

- (IBAction)profileButtonPressed:(UIBarButtonItem *)sender {
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
    [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - UISearchResultController/UISearchBarDelegate Delegate Functions
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchtext = searchController.searchBar.text;
    //    if (searchtext.length > 0) {
    //        [self.filteredArray removeAllObjects];
    //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(firstName contains[cd] %@) OR (lastName contains[cd] %@)", searchtext, searchtext];
    //
    //        self.filteredArray = [[self.plistEntries filteredArrayUsingPredicate:predicate] mutableCopy];
    //
    //        //        NSLog(@"%@", self.filteredArray);
    //    }
    //
    //    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"Selected Scoped %d", (int)selectedScope);
}




- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%@", searchBar.text);
    CLLocationCoordinate2D userDestinationLocation = [self getLocationFromAddressString:searchBar.text];
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:userDestinationLocation.latitude longitude:userDestinationLocation.longitude];
    [self loadAllDriversPostsUsingGeofireWithLocation:userLocation];
}


#pragma mark - Firebase Functionalities
- (void)loadAllDriverPostsFromFirebase {
    [[[DataService ds] driverPostsReference]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         //Clear Array
         [self.driverPostsArray removeAllObjects];
         
         // Loop over children
         NSEnumerator *children = [snapshot children];
         FIRDataSnapshot *child;
         while (child = [children nextObject]) {
             NSDictionary *driverPostDictionary = child.value;
             NSLog(@"Driver Post - %@", driverPostDictionary);
             DriverPost *driverPost = [[DriverPost alloc] initWithDict:driverPostDictionary];
             [self.driverPostsArray addObject:driverPost];
         }
         NSLog(@"Array Count %lu", (unsigned long)[self.driverPostsArray count]);
         [self.tableView reloadData];
     }];
}

- (void)loadAllDriversPostsUsingGeofireWithLocation:(CLLocation *)userLocation {
    
    //Clear all objects
    [self.driverPostsArray removeAllObjects];
    
    //Setup Location and Geoquery
    FIRDatabaseReference *endingLocationReference = [[DataService ds] endingLocationsReference];
    GeoFire *endingLocationGeofire = [[GeoFire alloc] initWithFirebaseRef:endingLocationReference];
    
   // CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:41.9048757 longitude:-88.33587759999999];
    // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
    
    GFCircleQuery *circleQuery = [endingLocationGeofire queryAtLocation:userLocation withRadius:6.1];
    [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        //NSLog(@"Circle Query - Key '%@' entered the search area and is at location '%@'", key, location);
        
        [[[[DataService ds] driverPostsReference]child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            //Convert snapshot value to dictionary
            NSMutableDictionary *driverPostDictionary = snapshot.value;
            double metersToMilesConverter = 0.000621371;
            driverPostDictionary[@"miles"] = [NSString stringWithFormat:@"%.2f miles",[userLocation distanceFromLocation:location] * metersToMilesConverter];
            //NSLog(@"Distance from Location in meters %f", [userLocation distanceFromLocation:location]);
            //NSLog(@"Driver Post - %@", driverPostDictionary);
            DriverPost *driverPost = [[DriverPost alloc] initWithDict:driverPostDictionary];
            [self.driverPostsArray addObject:driverPost];
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark - CLLocation Delegate methods

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSLog(@"Google Address - %@", req);
    
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    //    NSLog(@"View Controller get Location Logitute : %f", center.latitude);
    //    NSLog(@"View Controller get Location Latitute : %f", center.longitude);
    return center;
}
@end
