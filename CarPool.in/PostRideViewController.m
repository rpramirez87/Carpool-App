//
//  PostRideViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/29/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "PostRideViewController.h"

//Access maps in Apple
#import "MapKit/Mapkit.h"

//Get the current location
#import "CoreLocation/CoreLocation.h"

@interface PostRideViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *mapFillerImageView;
@property (weak, nonatomic) IBOutlet UITextField *startingAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *endingAddressTextField;
@end

@implementation PostRideViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
//    NSLog(@"View Controller get Location Logitute : %f", center.latitude);
//    NSLog(@"View Controller get Location Latitute : %f", center.longitude);
    return center;
}

- (void)calculateAddressInMap {
    
    //NSString *addressString = @"1935 Wessel Ct";
    //NSString *addressString = @"3809 Illinois Ave. Suite 100";
    
    //Starting Address
    NSString *startingAddress = self.startingAddressTextField.text;
    CLLocationCoordinate2D startingAddressLocation = [self getLocationFromAddressString:startingAddress];
                                                      
    double latFrom = startingAddressLocation.latitude;
    double lonFrom = startingAddressLocation.longitude;
    NSLog(@"Starting Address Location - %f,%f", latFrom, lonFrom);
    
    //Setup annotation for ending address
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    mapPin.title = startingAddress;
    mapPin.coordinate = startingAddressLocation;
    [self.mapView addAnnotation:mapPin];
    

    //Ending Address
    NSString *endingAddress = self.endingAddressTextField.text;
    CLLocationCoordinate2D endingAddressLocation = [self getLocationFromAddressString:endingAddress];
    
    latFrom = endingAddressLocation.latitude;
    lonFrom = endingAddressLocation.longitude;
    NSLog(@"Ending Address Location - %f,%f", latFrom, lonFrom);
    
    //Setup annotation for ending address
    mapPin = [[MKPointAnnotation alloc] init];
    mapPin.title = endingAddress;
    mapPin.coordinate = endingAddressLocation;
    [self.mapView addAnnotation:mapPin];
    
    //Set up viewing of map view
    MKCoordinateRegion region = self.mapView.region;
    region.center = endingAddressLocation;
    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.1;
    [self.mapView setRegion:region animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (![self.endingAddressTextField.text isEqualToString:@""] && ![self.startingAddressTextField.text isEqualToString:@""]) {
        
        self.mapFillerImageView.hidden = YES;
        
        NSLog(@"Run the code");
        //Set up Address
        [self calculateAddressInMap];
        
    }
    return YES;
}


@end
