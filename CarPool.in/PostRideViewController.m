//
//  PostRideViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/29/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "PostRideViewController.h"

@interface PostRideViewController ()

@end

@implementation PostRideViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
