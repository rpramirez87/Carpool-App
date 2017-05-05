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

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
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
    [self dismissViewControllerAnimated:YES completion:nil];
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

# pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentNotificationKey = self.notificationDictionaryKeysArray[indexPath.row];
    static NSString *cellIdentifier = @"NotificationCell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithNotificationKey:currentNotificationKey];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationDictionaryKeysArray.count;
}
@end
