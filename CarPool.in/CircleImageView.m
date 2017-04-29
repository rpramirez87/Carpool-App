//
//  CircleImageView.m
//  FirebaseDemo
//
//  Created by Ron Ramirez on 4/18/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.clipsToBounds = YES;    
}

@end
