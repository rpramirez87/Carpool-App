//
//  ProfileViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/4/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "ProfileViewController.h"
#import "BorderedCircleImageView.h"
#import "DataService.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NotificationCell.h"
#import "FCAlertView.h"
#import "RideLogViewController.h"
#import "CarpoolPostViewController.h"
#import "DriverPostTableViewCell.h"
#import "DriverPost.h"
#import "HCSStarRatingView.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, FCAlertViewDelegate>
@property (weak, nonatomic) IBOutlet BorderedCircleImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//UI Control
@property (strong, nonatomic) NSMutableArray *notificationDictionaryKeysArray;
@property (strong, nonatomic) NSMutableArray *carpoolPostsArray;
@property (nonatomic) BOOL isShowingNotifications;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRatingsLabel;

//Buttons
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;
@property (weak, nonatomic) IBOutlet UIButton *carpoolPostsButton;
@end

@implementation ProfileViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initial setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBar.hidden = YES;
    self.notificationDictionaryKeysArray = [[NSMutableArray alloc] init];
    self.carpoolPostsArray = [[NSMutableArray alloc] init];
    //UI Setup
    [self notificationButtonPressed:self.notificationButton];
    
    //Load current user info
    [self loadCurrentUserInfo];
    [self loadAllNotifications];
    [self loadAllUsersCarpoolPosts];
    [self loadUserRatings];
    
    //Initialize star rating
    self.starRatingView.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - IBActions
- (IBAction)profileButtonPressed:(UIButton *)sender {
    //    self.navigationController.navigationBar.hidden = NO;
    //    [self.navigationController popViewControllerAnimated:YES];
    
    //Only for remote notifications
    RideLogViewController *rideLogVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RideLogVC"];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:rideLogVC animated:YES];
}

- (IBAction)notificationButtonPressed:(UIButton *)sender {
    self.notificationButton.selected = YES;
    self.carpoolPostsButton.selected = NO;
    
    //Blue Color
    CGFloat red = 84.0 / 255.0;
    CGFloat green = 100.0 / 255.0;
    CGFloat blue = 246.0 / 255.0;
    UIColor *blueColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    if (sender.selected) {
        //Change notification post button
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor: blueColor forState:UIControlStateSelected];
        
        //Change Carpool post button
        [self.carpoolPostsButton setBackgroundColor:blueColor];
        
        //Show push notifications
        self.isShowingNotifications = YES;
        [self.tableView reloadData];
        
    }
}

- (IBAction)carpoolPostsButtonPressed:(UIButton *)sender {
    
    self.notificationButton.selected = NO;
    self.carpoolPostsButton.selected = YES;
    
    //Blue Color
    CGFloat red = 84.0 / 255.0;
    CGFloat green = 100.0 / 255.0;
    CGFloat blue = 246.0 / 255.0;
    UIColor *blueColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    if (sender.selected) {
        //UI Setup
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor: blueColor forState:UIControlStateSelected];
        [self.notificationButton setBackgroundColor:blueColor];
        
        //Show Carpool Posts
        self.isShowingNotifications = NO;
        [self.tableView reloadData];
    }
}

#pragma mark - Firebase

- (void)loadCurrentUserInfo {
    
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    [[[[DataService ds] publicUserReference] child:currentUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"Current User Image");
        if ([snapshot exists]) {
            NSString *firebaseImageURL = snapshot.value[@"image"];
            
            //Load image
            [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:firebaseImageURL]
                                     placeholderImage:[UIImage imageNamed:@"userCircle.png"]
                                              options:SDWebImageRefreshCached];
            NSLog(@"%@Profile Image URL", firebaseImageURL);
            NSString *currentUserName = snapshot.value[@"name"];
            if (currentUserName != nil) {
                self.profileNameLabel.text = currentUserName;
            }
            
        }else {
            //Assign empty image
            self.profileImageView.image = [UIImage imageNamed:@"userCircle"];
        }
    }];
}

- (void)loadAllNotifications {
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    // Load all loadAllNotifications from current user
    [[[[[DataService ds] publicUserReference] child: currentUID] child:@"pendingRequests" ]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         //Clear Array
         [self.notificationDictionaryKeysArray removeAllObjects];
         
         // Loop over children
         NSEnumerator *children = [snapshot children];
         FIRDataSnapshot *child;
         while (child = [children nextObject]) {
             NSString *notificationKey = child.key;
             NSLog(@"Notification Key - %@", notificationKey);
             [self.notificationDictionaryKeysArray addObject:notificationKey];
         }
         NSLog(@"Array Count %lu", (unsigned long)[self.notificationDictionaryKeysArray count]);
         [self.tableView reloadData];
     }];
}

- (void)loadAllUsersCarpoolPosts {
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    // Load all loadAllNotifications from current user
    [[[[[DataService ds] publicUserReference] child: currentUID] child:@"driverPosts"]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         
         //Clear Array
         [self.carpoolPostsArray removeAllObjects];
         
         // Loop over children
         NSEnumerator *children = [snapshot children];
         FIRDataSnapshot *child;
         while (child = [children nextObject]) {
             NSString *drivePostKey = child.key;
             NSLog(@"Drive Post Key - %@", drivePostKey);
             
             
             // Load all loadAllNotifications from current user
             [[[[DataService ds] driverPostsReference] child: drivePostKey]
              observeSingleEventOfType:FIRDataEventTypeValue
              withBlock:^(FIRDataSnapshot *snapshot) {
                  if ([snapshot exists]) {
                      NSDictionary *driverPostDictionary = snapshot.value;
                      NSLog(@"Driver Post - %@", driverPostDictionary);
                      DriverPost *driverPost = [[DriverPost alloc] initWithDict:driverPostDictionary andKey:drivePostKey];
                      if ([driverPost.isDriver isEqualToString:@"YES"]) {
                          [self.carpoolPostsArray addObject:driverPost];
                      }
                  }
              }];
         }
         NSLog(@"Array Count %lu", (unsigned long)[self.carpoolPostsArray count]);
         [self.tableView reloadData];
     }];
}

// Load user ratings

- (void)loadUserRatings {
    
    //Current User ID
    NSString *currentUID = [FIRAuth auth].currentUser.uid;
    
    [[[[[DataService ds] publicUserReference] child:currentUID] child:@"userRatings"] observeEventType:FIRDataEventTypeValue
withBlock:^(FIRDataSnapshot *snapshot) {
    NSLog(@"User Ratings");
    
    if ([snapshot exists]) {
        
        NSUInteger ratingsCount = [snapshot childrenCount];
        self.numberOfRatingsLabel.text = [NSString stringWithFormat:@"%d", (int)ratingsCount];
        
        // Loop over children
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSInteger totalValue = 0;
        while (child = [children nextObject]) {
            NSNumber *ratingValue = child.value;
            NSLog(@"Rating Value - %@", ratingValue);
            totalValue += [ratingValue integerValue];
        }
        
        NSNumber *NSRatingCount = [NSNumber numberWithUnsignedInteger:ratingsCount];
        float ratingCountFloat = [NSRatingCount floatValue];
        float currentUserRating = (float)totalValue / ratingCountFloat;
        
        NSLog(@"User Rating - %.2f", currentUserRating);
        
        self.starRatingView.value = currentUserRating;
    }
    

    //Set data
}];
}

# pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isShowingNotifications) {
        NSString *currentNotificationKey = self.notificationDictionaryKeysArray[indexPath.row];
        static NSString *cellIdentifier = @"NotificationCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        //Configure Cell
        [cell configureCellWithNotificationKey:currentNotificationKey];
        
        //Add target-action for buttons
        cell.acceptButton.tag = indexPath.row;
        cell.rejectButton.tag = indexPath.row;
        cell.rateButton.tag = indexPath.row;
        
        
        [cell.acceptButton addTarget:self action:@selector(notificationAccepted:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rejectButton addTarget:self action:@selector(notificationRejected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rateButton addTarget:self action:@selector(rateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else {
        DriverPost *currentDriverPost = self.carpoolPostsArray[indexPath.row];
        static NSString *postCellIdentifier = @"PostCell";
        DriverPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier];
        [cell configureCellWithDriverPost:currentDriverPost];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isShowingNotifications) {
        return self.notificationDictionaryKeysArray.count;
    } else {
        return self.carpoolPostsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isShowingNotifications) {
        return 100.0;
    }else {
        return 200.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did pressed table view");
    if (!self.isShowingNotifications) {
        DriverPost *currentDriverPost = self.carpoolPostsArray[indexPath.row];
        CarpoolPostViewController *carpoolPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolPostVC"];
        carpoolPostVC.currentDriverPost = currentDriverPost;
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:carpoolPostVC animated:YES];
    }
}

#pragma mark - Target Actions

- (void) notificationAccepted:(UIButton *)acceptButton{
    CGPoint touchPoint = [acceptButton convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *clickedButtonIndexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    NSLog(@"Accept Button - NSIndex Path Row %ld", (long) clickedButtonIndexPath.row);
    NSString *currentDictionaryKey = self.notificationDictionaryKeysArray[clickedButtonIndexPath.row];
    
    //Create an alert
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeSuccess];
    
    [alert showAlertInView:self
                 withTitle:@"Notice"
              withSubtitle:[NSString stringWithFormat:@"Are you sure you want to accept this passenger?"]
           withCustomImage:nil
       withDoneButtonTitle:@"Accept"
                andButtons:nil];
    [alert doneActionBlock:^{
        NSLog(@"Accept Done");
        [self.notificationDictionaryKeysArray removeObjectAtIndex:clickedButtonIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSString *currentUID = [FIRAuth auth].currentUser.uid;
        
        [[[[DataService ds] notificationsReference] child:currentDictionaryKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if ([snapshot exists]) {
                NSString *drivePostID = snapshot.value[@"drivePostID"];
                NSString *senderkey = snapshot.value[@"senderKey"];
                
                //Change value to true
                [[[[[[DataService ds] driverPostsReference] child: drivePostID] child: @"driverRequests"] child:senderkey] setValue: @"Accepted"];
                
                //Segue to Carpool VC
                [[[[DataService ds] driverPostsReference] child:drivePostID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                    if ([snapshot exists]) {
                        NSDictionary *drivePostDict = snapshot.value;
                        DriverPost *currentDrivePost = [[DriverPost alloc] initWithDict:drivePostDict andKey:snapshot.key];
                        
                        //Show current drive post accepted
                        CarpoolPostViewController *carpoolPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolPostVC"];
                        carpoolPostVC.currentDriverPost = currentDrivePost;
                        self.navigationController.navigationBarHidden = YES;
                        [self.navigationController pushViewController:carpoolPostVC animated:YES];
                        
                        
                        //Delete this notification in the database
                        [[[[DataService ds] notificationsReference] child:currentDictionaryKey] removeValue];
                        
                        //Delete notifications from public user
                        [[[[[[DataService ds] publicUserReference] child:currentUID] child:@"pendingRequests"] child:currentDictionaryKey] removeValue];
                    }
                }];
            }
        }];
    }];
    [alert addButton:@"No" withActionBlock:^{
        
    }];
}

- (void) notificationRejected:(UIButton *)rejectButton {
    CGPoint touchPoint = [rejectButton convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *clickedButtonIndexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    NSLog(@"Reject Button - NSIndex Path Row %ld", (long) clickedButtonIndexPath.row );
    NSString *currentDictionaryKey = self.notificationDictionaryKeysArray[clickedButtonIndexPath.row];
    //Create Alert View to warn user
    
    //Create an alert
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeWarning];
    
    [alert showAlertInView:self
                 withTitle:@"Warning"
              withSubtitle:[NSString stringWithFormat:@"Are you sure you want to reject this passenger?"]
           withCustomImage:nil
       withDoneButtonTitle:@"Reject"
                andButtons:nil];
    [alert doneActionBlock:^{
        NSLog(@"Reject Done");
        [self.notificationDictionaryKeysArray removeObjectAtIndex:clickedButtonIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSString *currentUID = [FIRAuth auth].currentUser.uid;
        
        NSLog(@"%@ - Dictionary Key", currentDictionaryKey);
        //Delete this notification in the database
        [[[[DataService ds] notificationsReference] child:currentDictionaryKey] removeValue];
        
        //Delete notifications from public user
        [[[[[[DataService ds] publicUserReference] child:currentUID] child:@"pendingRequests"] child:currentDictionaryKey] removeValue];
        
        //TODO: Set child to rejected
        
    }];
    [alert addButton:@"No" withActionBlock:^{
    }];
}

- (void)rateButtonTapped:(UIButton *)button {
    CGPoint touchPoint = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *clickedButtonIndexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    NSLog(@"Rate Button - NSIndex Path Row %ld", (long) clickedButtonIndexPath.row );
    NSString *currentDictionaryKey = self.notificationDictionaryKeysArray[clickedButtonIndexPath.row];
    NSString *currentUID = [FIRAuth auth].currentUser.uid;    //Create an alert
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeRateStars:^(NSInteger rating) {
        NSLog(@"Your Stars Rating: %ld", (long)rating); // Use the Rating as you'd like
        
        [[[[DataService ds] notificationsReference] child:currentDictionaryKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if ([snapshot exists]) {
                NSString *drivePostID = snapshot.value[@"drivePostID"];
                NSString *senderkey = snapshot.value[@"senderKey"];
                NSLog(@"Drive Post ID%@", drivePostID);
                NSLog(@"Sender %@", senderkey);
                
                [[[[[[DataService ds] publicUserReference] child:senderkey] child:@"userRatings"] child:drivePostID] setValue:[NSNumber numberWithInteger:rating]];
                
                //Delete notification
                [self.notificationDictionaryKeysArray removeObjectAtIndex:clickedButtonIndexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                
                NSLog(@"%@ - Dictionary Key", currentDictionaryKey);
                //Delete this notification in the database
                [[[[DataService ds] notificationsReference] child:currentDictionaryKey] removeValue];
                
                //Delete notifications from public user
                [[[[[[DataService ds] publicUserReference] child:currentUID] child:@"pendingRequests"] child:currentDictionaryKey] removeValue];
            }
        }];
    }];
    
    [alert showAlertInView:self
                 withTitle:@"User Experience Rating"
              withSubtitle:[NSString stringWithFormat:@"Rate your carpool experience."]
           withCustomImage:nil
       withDoneButtonTitle:@"Rate"
                andButtons:nil];
    [alert doneActionBlock:^{
        NSLog(@"Done");

    }];
}

@end
