//
//  FlatImageView.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/3/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "FlatImageView.h"

@implementation FlatImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = YES;
}

@end
