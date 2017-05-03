//
//  SelectViewController.h
//  CarPool.in
//
//  Created by Ron Ramirez on 5/1/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@interface SelectViewController : UIViewController
@property (nonatomic, assign) BOOL isSelectingRiders;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) NSString *userAddress;
@end
