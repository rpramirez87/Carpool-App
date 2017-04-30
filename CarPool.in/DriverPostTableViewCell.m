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
    self.startingAddressLabel.text = driverPost.startingAddress;
    self.endingAddressLabel.text = driverPost.endingAddress;
    self.timeLabel.text = driverPost.time;
    
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
