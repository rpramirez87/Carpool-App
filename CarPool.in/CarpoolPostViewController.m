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
#import "PassengerRequestCell.h"
#import "CarpoolMessagesViewController.h"

@interface CarpoolPostViewController () <UITableViewDelegate, UITableViewDataSource>

//User Interface
@property (weak, nonatomic) IBOutlet FlatImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *startingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *endingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

//Buttons
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

//Driver Information
@property (strong, nonatomic) NSString *currentDriverName;
@property (strong, nonatomic) NSString *currentDriverPushID;

//Passenger Information
@property (strong, nonatomic) NSString *currentPassengerName;


//Current Requests
@property (weak, nonatomic) IBOutlet UITableView *requestsTableView;
@property (strong, nonatomic) NSMutableArray *drivePostRequestsArray;

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
    [self loadAllPendingRequests];
    
    //Initialize values
    self.drivePostRequestsArray = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"View will appear");
    self.navigationController.navigationBarHidden = NO;
    [self loadAllPendingRequests];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"goToCarpoolMessagesVC"]) {
        CarpoolMessagesViewController *carpoolMessagesVC = [segue destinationViewController];
        carpoolMessagesVC.currentDriverPost = self.currentDriverPost;
    }
}



#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.drivePostRequestsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *currentPassengerRequestDict = self.drivePostRequestsArray[indexPath.row];
    static NSString *cellIdentifier = @"PassengerRequestCell";
    PassengerRequestCell *cell = [self.requestsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithUserKey:[currentPassengerRequestDict valueForKey:@"userKey"]
                  andRequestStatus:[currentPassengerRequestDict valueForKey:@"requestStatus"]
     ];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

#pragma mark - IBAction

- (IBAction)RequestButtonPressed:(id)sender {
    
    
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    //   NSString *sampleFireInstanceToken = @"fs97oPrvEDI:APA91bG71PzQOem2B4jRot9S5fQT0JL-4ta1cQ_pBzZBcKzc6NAhPGgLolQ8bwUTjNbdE4InArdKhgeagajeGag1YHCATgybGVsEBBy2a1jpDCdeub4vNQm-P6hD-J0PeCK1holw-qEk";
    
    NSLog(@"Notification Sent to %@", self.currentDriverPushID);
    
    NSDictionary *pushNotificationDict = @{
                                           @"username": self.currentDriverPushID,
                                           @"message" : [NSString stringWithFormat:@"%@ wants to ride with you!", self.currentPassengerName],
                                           @"rideinfo" : self.currentDriverPost.drivePostID
                                           };
    
    //Send a notification using nodeJS
    [[[[DataService ds] pushNotificationsReference] childByAutoId] updateChildValues:pushNotificationDict];
    
    //Save notification to drivers pending notifications
    FIRDatabaseReference *notificationRef = [[[[[DataService ds] publicUserReference] child:self.currentDriverPost.ownerKey] child: @"pendingRequests"] childByAutoId] ;
    
    //Update values
    [notificationRef setValue:@YES];
    NSString *notificationKey = notificationRef.key;
    
    NSDictionary *notificationDict = @{
                                       @"senderKey": currentUID,
                                       @"message" : [NSString stringWithFormat:@"%@ wants to ride with you!", self.currentPassengerName],
                                       @"drivePostID" : self.currentDriverPost.drivePostID
                                       };
    
    //Add notification to notifications child
    [[[[DataService ds] notificationsReference] child: notificationKey] updateChildValues:notificationDict];
    
    //Create a pending request inside the drive post key
    [[[[[[DataService ds] driverPostsReference] child:self.currentDriverPost.drivePostID] child:@"driverRequests"] child:currentUID] setValue:@"Requested"];
    
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


- (IBAction)messageButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"goToCarpoolMessagesVC" sender:nil];
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

- (void)loadAllPendingRequests {
    
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    [[[[[DataService ds] driverPostsReference] child:self.currentDriverPost.drivePostID] child:@"driverRequests"] observeEventType:FIRDataEventTypeValue
withBlock:^(FIRDataSnapshot *snapshot) {

     BOOL isAccepted = NO;
    
    //Clear Array
    [self.drivePostRequestsArray removeAllObjects];
    
    // Loop over children
    NSEnumerator *children = [snapshot children];
    FIRDataSnapshot *child;
    while (child = [children nextObject]) {
        NSString *passengerKey = child.key;
        NSString *status = child.value;
        
        //Check if current user already requested - (disable button) (change name)
        if ([passengerKey isEqualToString:currentUID]) {
            NSLog(@"Request Button Disabled!");
            self.requestButton.enabled = NO;
            self.requestButton.hidden = YES;
            
            //Check if my status is accepted
            if ([status isEqualToString:@"Accepted"]) {
                
                //If current user is the passenger and is accepted
                //Unhide message button
                self.messageButton.hidden = NO;
            }
        }
        //Check if anyone's status is accepted for the driver
        if ([status isEqualToString:@"Accepted"]) {
              isAccepted = YES;
        }
        
        //Create a dictionary to save values and save to array
        NSDictionary *passengerDict = @{@"userKey" : passengerKey,
                                        @"requestStatus" : status};
        NSLog(@"PassengerRequest - %@ with status - %@", passengerKey, status);
        [self.drivePostRequestsArray addObject:passengerDict];
    }
    
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    // Allow messages if current user is the driver and someone have been accepted to carpool
    if ([self.currentDriverPost.ownerKey isEqualToString:currentUID]) {
        
        //Hide request button if current user is the driver.
        self.requestButton.hidden = YES;
        
        if (isAccepted) {
            //Allow message button if someone is accepted and if current user is the driver
            NSLog(@"Driver Messages PASSED!!!");
            self.messageButton.hidden = NO;
        }else {
            NSLog(@"No one is accepted");
            
        }
    }else {
        NSLog(@"Boolean - %d", isAccepted);
        NSLog(@"Boolean - %d", isAccepted);
        NSLog(@"Current Owner Key - %@", self.currentDriverPost.ownerKey);
        NSLog(@"Current UID - %@", currentUID);
        NSLog(@"Boolean Failed");
    }
    NSLog(@"Array Count %lu", (unsigned long)[self.drivePostRequestsArray count]);
    [self.requestsTableView reloadData];
}];
}


@end
