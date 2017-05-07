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
#import "CarpoolPostViewController.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, FCAlertViewDelegate>
@property (weak, nonatomic) IBOutlet BorderedCircleImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Array of notifications
@property (strong, nonatomic) NSMutableArray *notificationDictionaryKeysArray;

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
    
    //Load current user info
    [self loadCurrentUserInfo];
    [self loadAllNotifications];
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
    [self.navigationController popViewControllerAnimated:YES];
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
     observeSingleEventOfType:FIRDataEventTypeValue
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

# pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentNotificationKey = self.notificationDictionaryKeysArray[indexPath.row];
    static NSString *cellIdentifier = @"NotificationCell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Configure Cell
    [cell configureCellWithNotificationKey:currentNotificationKey];
    
    //Add target-action for buttons
    cell.acceptButton.tag = indexPath.row;
    cell.rejectButton.tag = indexPath.row;
    
    [cell.acceptButton addTarget:self action:@selector(notificationAccepted:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rejectButton addTarget:self action:@selector(notificationRejected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationDictionaryKeysArray.count;
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

@end
