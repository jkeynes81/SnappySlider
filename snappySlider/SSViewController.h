//
//  SSViewController.h
//  snappySlider
//
//  Created by kp on 6/12/14.
//  Copyright (c) 2014 KeynesPaul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnappySlider.h"
@interface SSViewController : UIViewController
@property(nonatomic,strong) SnappySlider *blockSlider;
@property(nonatomic,strong) IBOutlet UILabel *blockLabel;
@end
