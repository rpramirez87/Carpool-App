//
//  PassengerRequestCell.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/5/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "PassengerRequestCell.h"
#import "DataService.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation PassengerRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithUserKey:(NSString *)userKey andRequestStatus:(NSString *)status {
    
    [[[[DataService ds] publicUserReference] child:userKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"Current User Image");
        if ([snapshot exists]) {
            NSString *firebaseImageURL = snapshot.value[@"image"];
            
            //Load image
            [self.passengerRequestImageView sd_setImageWithURL:[NSURL URLWithString:firebaseImageURL]
                                     placeholderImage:[UIImage imageNamed:@"userCircle.png"]
                                              options:SDWebImageRefreshCached];
            
            NSLog(@"%@Profile Image URL", firebaseImageURL);
            NSString *currentUserName = snapshot.value[@"name"];
            if (currentUserName != nil) {
                self.requestMessageLabel.text = [NSString stringWithFormat:@"%@ has sent a request to this driver.", currentUserName];
            }
        }else {
            //Assign empty image
            self.passengerRequestImageView.image = [UIImage imageNamed:@"userCircle"];
        }
    }];
    
    self.requestStatusLabel.layer.borderWidth = 1.0f;
    self.requestStatusLabel.layer.cornerRadius = 5.0;
    
    if ([status isEqualToString:@"Requested"]) {
        CGFloat red = 0.0 / 255.0;
        CGFloat green = 122.0 / 255.0;
        CGFloat blue = 255.0 / 255.0;
        UIColor *blueColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.requestStatusLabel.text = @"Requested";
        
        //Set color to blue
        self.requestStatusLabel.textColor = blueColor;
        self.requestStatusLabel.layer.borderColor = blueColor.CGColor;

    }else if ([status isEqualToString:@"Accepted"]) {
        self.requestStatusLabel.text = @"Accepted";
        
        CGFloat red = 91.0 / 255.0;
        CGFloat green = 189.0 / 255.0;
        CGFloat blue = 110.0 / 255.0;
        UIColor *greenColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        //Set color to green
        self.requestStatusLabel.textColor = greenColor;
        self.requestStatusLabel.layer.borderColor = greenColor.CGColor;
        
    }else {
        //Do nothing
    }
}

@end
