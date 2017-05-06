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
