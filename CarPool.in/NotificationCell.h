//
//  NotificationCell.h
//  CarPool.in
//
//  Created by Ron Ramirez on 5/5/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"
#import "CircleImageView.h"

@interface NotificationCell : UITableViewCell


@property (weak, nonatomic) IBOutlet CircleImageView *notificationSenderImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationMessageLabel;

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;

- (void)configureCellWithNotificationKey:(NSString *)key;


@end
