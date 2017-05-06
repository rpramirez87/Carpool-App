//
//  CarpoolMessagesViewController.h
//  CarPool.in
//
//  Created by Ron Ramirez on 5/6/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "JSQMessagesViewController.h"
#import "DriverPost.h"
#import "JSQMessages.h"

@interface CarpoolMessagesViewController : JSQMessagesViewController
@property (strong, nonatomic) DriverPost *currentDriverPost;
@end
