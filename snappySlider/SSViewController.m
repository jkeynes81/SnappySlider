//
//  SSViewController.m
//  snappySlider
//
//  Created by kp on 6/12/14.
//  Copyright (c) 2014 Keynes Paul. All rights reserved.
//

#import "SSViewController.h"

@interface SSViewController ()

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.blockSlider = [[SnappySlider alloc] initWithFrame:CGRectMake(20, 121, 280, 23)];
	[self.view addSubview:self.blockSlider];
    NSArray *detents = @[@10, @20, @30, @40, @50, @60];
    
	self.blockSlider.valuesToPlot = detents;
    
    SSViewController *weakSelf = self;
    [self.blockSlider valueDidChange:^(id sender, int value) {
        weakSelf.blockLabel.text = [NSString stringWithFormat:@"Updated with a block: %@",[detents objectAtIndex:value]];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
