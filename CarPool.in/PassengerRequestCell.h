//
//  PassengerRequestCell.h
//  CarPool.in
//
//  Created by Ron Ramirez on 5/5/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleImageView.h"
@interface PassengerRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *passengerRequestImageView;
@property (weak, nonatomic) IBOutlet UILabel *requestMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestStatusLabel;

- (void)configureCellWithUserKey:(NSString *)userKey andRequestStatus:(NSString *)status;
@end
