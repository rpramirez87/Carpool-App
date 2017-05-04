//
//  DriverPostTableViewCell.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/30/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "DriverPostTableViewCell.h"


@implementation DriverPostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCellWithDriverPost:(DriverPost *)driverPost {
    
    self.currentDriverPost = driverPost;
    
    //Assign labels based on model
    self.startingAddressLabel.text = driverPost.startingAddress;
    self.endingAddressLabel.text = driverPost.endingAddress;
    self.timeLabel.text = driverPost.time;
    self.distanceInMilesLabel.text = driverPost.milesInDistanceString;
    
    if ([driverPost.isDriver isEqualToString:@"NO"]) {
        //Red color for side view
        CGFloat red = 186.0 / 255.0;
        CGFloat green = 0 / 255.0;
        CGFloat blue = 0 / 255.0;
        UIColor *redColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.sideBackgroundView.backgroundColor = redColor;
        self.isDriverLabel.textColor = redColor;
        self.isDriverLabel.text = @"Passenger";
        self.destinationLogoImageView.image = [UIImage imageNamed:@"redDestinationLogo"];
    }else {
        //Green Color for side view
        CGFloat red = 91.0 / 255.0;
        CGFloat green = 189.0 / 255.0;
        CGFloat blue = 110.0 / 255.0;
        UIColor *greenColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.sideBackgroundView.backgroundColor = greenColor;
        self.isDriverLabel.textColor = greenColor;
        self.isDriverLabel.text = @"Driver";
        self.destinationLogoImageView.image = [UIImage imageNamed:@"destinationLogo"];
        
    }

    //Load up user name and image
    //Load user image and text
    [[[[[DataService ds] rootReference] child:@"publicUsers"] child:driverPost.ownerKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
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
            NSString *currentUserName = snapshot.value[@"name"];
            if (currentUserName != nil) {
                self.driverNameLabel.text = currentUserName;
            }
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}
@end
