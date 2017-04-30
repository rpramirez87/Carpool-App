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
    //Assign labels based on model
    self.startingAddressLabel.text = driverPost.startingAddress;
    self.endingAddressLabel.text = driverPost.endingAddress;
    self.timeLabel.text = driverPost.time;
    
    //Randomize color for side view
    CGFloat red = arc4random() % 255 / 255.0;
    CGFloat green = arc4random() % 255 / 255.0;
    CGFloat blue = arc4random() % 255 / 255.0;
    UIColor *randomColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    self.sideBackgroundView.backgroundColor = randomColor;
    
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
                
                NSLog(@"%@Profile Image URL", firebaseImageURL);
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
