//
//  FullControlViewController.h
//  DJISdkDemo
//
//  Created by Ping Chen on 1/17/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FullControlViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *gimbalInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *joystickMessageLabel;
@property (weak, nonatomic) IBOutlet UISwitch *joystickToggle;

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (weak, nonatomic) IBOutlet UISlider *controlSlider;

@end
NS_ASSUME_NONNULL_END
