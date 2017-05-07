//
//  RequestRideViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/1/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "RequestRideViewController.h"

//Get the current location
#import "CoreLocation/CoreLocation.h"
#import "DataService.h"
#import "SelectViewController.h"
#import "FCAlertView.h"

@interface RequestRideViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startingAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *endingAddressTextField;
@property (strong, nonatomic) CLLocation *startingLocation;
@property (strong, nonatomic) CLLocation *endingLocation;
@end

@implementation RequestRideViewController
#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.startingAddressTextField.delegate = self;
    self.endingAddressTextField.delegate = self;
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Location Manager Functions

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
    
    return center;
}

- (void)calculateAddressInMap {
    
    //Starting Address
    NSString *startingAddress = self.startingAddressTextField.text;
    CLLocationCoordinate2D startingAddressLocation = [self getLocationFromAddressString:startingAddress];
    
    double latFrom = startingAddressLocation.latitude;
    double lonFrom = startingAddressLocation.longitude;
    NSLog(@"Starting Address Location - %f,%f", latFrom, lonFrom);
    self.startingLocation = [[CLLocation alloc] initWithLatitude:latFrom longitude:lonFrom];
    
    //Ending Address
    NSString *endingAddress = self.endingAddressTextField.text;
    CLLocationCoordinate2D endingAddressLocation = [self getLocationFromAddressString:endingAddress];
    
    latFrom = endingAddressLocation.latitude;
    lonFrom = endingAddressLocation.longitude;
    self.endingLocation = [[CLLocation alloc] initWithLatitude:latFrom longitude:lonFrom];
    NSLog(@"Ending Address Location - %f,%f", latFrom, lonFrom);
    
}

#pragma mark - Firebase Database Functions

- (void)saveStartingLocationToFirebase:(CLLocation *)startingLocation andEndingLocation:(CLLocation *)endingLocation {
    
    //SAVE TO CURRENT USER ID
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    FIRDatabaseReference *driverRef = [[[[[DataService ds] publicUserReference] child:currentUID] child:@"driverPosts"] childByAutoId];
    [driverRef setValue:@YES];
    
    NSString *driverPostID = driverRef.key;
    
    //SAVE TO DRIVERS POSTS
    
    //Date formatter with current date
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Current Time
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    //Driver Post Dictionary to save
    NSDictionary *driverPostDict = @{@"ownerKey": currentUID,
                                     @"startingAddress": self.startingAddressTextField.text,
                                     @"endingAddress": self.endingAddressTextField.text,
                                     @"time" : dateString,
                                     @"isDriver" : @"NO"
                                     };
    
    [[[[DataService ds] driverPostsReference] child:driverPostID] updateChildValues:driverPostDict];
    
    //Save to Firebase staring locations
    FIRDatabaseReference *startingLocationReference = [[DataService ds] startingLocationsReference];
    GeoFire *startingLocationGeofire = [[GeoFire alloc] initWithFirebaseRef:startingLocationReference];
    
    [startingLocationGeofire setLocation:[[CLLocation alloc] initWithLatitude:startingLocation.coordinate.latitude longitude:startingLocation.coordinate.longitude]
                                  forKey:driverPostID
                     withCompletionBlock:^(NSError *error) {
                         if (error != nil) {
                             NSLog(@"An error occurred: %@", error);
                         } else {
                             NSLog(@"Saved staring location successfully!");
                         }
                     }];
    
    //Save to Firebase ending locations
    FIRDatabaseReference *endingLocationReference = [[DataService ds] endingLocationsReference];
    GeoFire *endingLocationGeofire = [[GeoFire alloc] initWithFirebaseRef:endingLocationReference];
    
    //CLLocation is a structure - Use Pointers not dot notation.
    [endingLocationGeofire setLocation:[[CLLocation alloc] initWithLatitude:endingLocation.coordinate.latitude longitude:endingLocation.coordinate.longitude]
                                forKey:driverPostID
                   withCompletionBlock:^(NSError *error) {
                       if (error != nil) {
                           NSLog(@"An error occurred: %@", error);
                       } else {
                           NSLog(@"Saved ending location successfully!");
                       }
                   }];
}

#pragma mark - IBAction
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)requestButtonPressed:(UIButton *)sender {
    if (![self.endingAddressTextField.text isEqualToString:@""] && ![self.startingAddressTextField.text isEqualToString:@""]) {
        
        //TODO Handle Situation if query returns 0
        SelectViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectVC"];
        [controller setIsSelectingRiders:NO];
        [controller setUserLocation:self.endingLocation];
        [self.navigationController pushViewController:controller animated:YES];
        //Save to Firebase
        [self saveStartingLocationToFirebase:self.startingLocation andEndingLocation:self.endingLocation];
        

    }else {
        //Create an alert
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeWarning];
        
        [alert showAlertInView:self
                     withTitle:@"Warning"
                  withSubtitle:[NSString stringWithFormat:@"Please fill in all fields before requesting"]
               withCustomImage:nil
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    //Check if starting end ending textfield is not empty
    if (![self.endingAddressTextField.text isEqualToString:@""] && ![self.startingAddressTextField.text isEqualToString:@""]) {
        NSLog(@"Run the code");
        
        //Set up Address
        [self calculateAddressInMap];
        
    }
    return YES;
}

@end
