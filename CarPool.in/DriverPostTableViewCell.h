//
//  DriverPostTableViewCell.h
//  CarPool.in
//
//  Created by Ron Ramirez on 4/30/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverPost.h"
#import "CircleImageView.h"
#import "DataService.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface DriverPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *endingAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UIView *sideBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *isDriverLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceInMilesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *destinationLogoImageView;


- (void)configureCellWithDriverPost:(DriverPost *)driverPost;
@end
