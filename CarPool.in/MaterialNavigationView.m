//
//  MaterialNavigationView.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/29/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "MaterialNavigationView.h"

@implementation MaterialNavigationView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.layer.shadowColor = [[UIColor alloc] initWithRed:157.0 / 255.0 green:157.0 / 255.0 blue:157.0 / 255.0 alpha:1.0].CGColor;
}
@end
