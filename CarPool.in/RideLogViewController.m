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

@interface RideLogViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *driverPostsArray;
@end

@implementation RideLogViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.driverPostsArray = [[NSMutableArray alloc] init];
    
    //Load all driverPosts for now
    [self loadAllDriverPostsFromFirebase];

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

@end
