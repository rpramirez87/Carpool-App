//
//  CircleImage.m
//  FirebaseDemo
//
//  Created by Ron Ramirez on 4/17/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "BorderedCircleImageView.h"

@implementation BorderedCircleImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.clipsToBounds = YES;
    self.layer.borderWidth = 3.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
