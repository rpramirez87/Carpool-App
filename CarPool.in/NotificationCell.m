//
//  NotificationCell.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/5/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "NotificationCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation NotificationCell


- (void)configureCellWithNotificationKey:(NSString *)key {
    
    [[[[DataService ds] notificationsReference] child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    
        NSLog(@"%@", snapshot.value);
        NSString *message = snapshot.value[@"message"];
        self.notificationMessageLabel.text = message;
        NSString *userKey = snapshot.value[@"senderKey"];
        
        NSString *isRateNotification = snapshot.value[@"isRateNotification"];
        //Rating Notifications
        if ([isRateNotification isEqualToString:@"YES"]) {
            self.rejectButton.hidden = YES;
            self.acceptButton.hidden = YES;
            self.rateButton.hidden = NO;
            self.notificationTitleLabel.text = @"Ratings Request";
        }else {
            //Normal Notifications
            self.rejectButton.hidden = NO;
            self.acceptButton.hidden = NO;
            self.rateButton.hidden = YES;
            self.notificationTitleLabel.text = @"Driver Request";
        }
        
        [[[[[DataService ds] publicUserReference] child:userKey] child:@"image"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSString *imageURL = snapshot.value;
            
            //Load post image based on url
            [self.notificationSenderImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                                  placeholderImage:[UIImage imageNamed:@""]
                                           options:SDWebImageRefreshCached];
            
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}
@end
