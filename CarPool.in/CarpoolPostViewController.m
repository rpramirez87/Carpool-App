//
//  CarpoolPostViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/3/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "CarpoolPostViewController.h"
#import "DataService.h"
#import "FlatImageView.h"
#import "DataService.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FCAlertView.h"
#import "RideLogViewController.h"

@interface CarpoolPostViewController ()

//User Interface
@property (weak, nonatomic) IBOutlet FlatImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *startingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *endingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

//Driver Information

@property (strong, nonatomic) NSString *currentDriverName;
@property (strong, nonatomic) NSString *currentDriverPushID;

//Passenger Information
@property (strong, nonatomic) NSString *currentPassengerName;


@end

@implementation CarpoolPostViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Update Values based on model
    self.startingAddressLabel.text = self.currentDriverPost.startingAddress;
    self.endingAddressLabel.text = self.currentDriverPost.endingAddress;
    self.timeLabel.text = self.currentDriverPost.time;
    
    
    //Call Firebase
    [self loadCurrentUserInfo];
    [self loadCurrentDriversInfo];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"View will appear");
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBAction

- (IBAction)RequestButtonPressed:(id)sender {
    
    
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    //   NSString *sampleFireInstanceToken = @"fs97oPrvEDI:APA91bG71PzQOem2B4jRot9S5fQT0JL-4ta1cQ_pBzZBcKzc6NAhPGgLolQ8bwUTjNbdE4InArdKhgeagajeGag1YHCATgybGVsEBBy2a1jpDCdeub4vNQm-P6hD-J0PeCK1holw-qEk";
    
    NSLog(@"Notification Sent to %@", self.currentDriverPushID);
    
    NSDictionary *pushNotificationDict = @{
                                           @"username": self.currentDriverPushID,
                                           @"message" : [NSString stringWithFormat:@"%@ wants to ride with you!", self.currentDriverName],
                                           @"rideinfo" : self.currentDriverPost.drivePostID
                                           };
    
    //Send a notification using node
    [[[[DataService ds] pushNotificationsReference] childByAutoId] updateChildValues:pushNotificationDict];
    
    //TODO: save notification to drivers pending notifications
    FIRDatabaseReference *notificationRef = [[[[[DataService ds] publicUserReference] child:self.currentDriverPost.ownerKey] child: @"pendingRequests"] childByAutoId] ;
    
    //Update values
    [notificationRef setValue:@YES];
    NSString *notificationKey = notificationRef.key;
    
    NSDictionary *notificationDict = @{
                                       @"senderKey": currentUID,
                                       @"message" : [NSString stringWithFormat:@"%@ wants to ride with you!", self.currentPassengerName]
                                       };
    
    //Add notification to notifications child
    [[[[DataService ds] pendingRequestsReference] child: notificationKey] updateChildValues:notificationDict];
    
    //Alert User
    //Create an alert
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeSuccess];
    
    [alert showAlertInView:self
                 withTitle:@"Success"
              withSubtitle:[NSString stringWithFormat:@"Request to carpool with driver %@ have been sent! 🚗", self.currentDriverName]
           withCustomImage:nil
       withDoneButtonTitle:@"OK"
                andButtons:nil];
    [alert doneActionBlock:^{
        // Put your action here
        NSLog(@"Request Done");
    }];
}

#pragma mark - Firebase Request


- (void)loadCurrentUserInfo {
    
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    [[[[DataService ds] publicUserReference] child:currentUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"Current User Name");
        
        if ([snapshot exists]) {
            NSString *currentUserName = snapshot.value[@"name"];
            if (currentUserName != nil) {
                self.currentPassengerName = currentUserName;
            }
        }
    }];
}
- (void)loadCurrentDriversInfo {
    //Update values from Firebase
    
    //Load user image and text
    [[[[[DataService ds] rootReference] child:@"publicUsers"] child:self.currentDriverPost.ownerKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        //Access image
        if ([snapshot exists]) {
            NSString *firebaseImageURL = snapshot.value[@"image"];
            
            if (firebaseImageURL != nil) {
                [self.driverImageView sd_setImageWithURL:[NSURL URLWithString:firebaseImageURL]
                                        placeholderImage:[UIImage imageNamed:@"userCircle.png"]
                                                 options:SDWebImageRefreshCached];
                
                //NSLog(@"%@Profile Image URL", firebaseImageURL);
            }
            //Access user name
            NSString *currentDriverName = snapshot.value[@"name"];
            if (currentDriverName != nil) {
                self.driverNameLabel.text = currentDriverName;
                self.currentDriverName = currentDriverName;
            }
            
            NSString *pushID = snapshot.value[@"pushMessageID"];
            if (pushID != nil) {
                self.currentDriverPushID = pushID;
            }
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}



@end
