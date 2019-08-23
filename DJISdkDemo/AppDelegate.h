//
//  AppDelegate.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "ExternalJoystickController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong) ExternalJoystickController *joystickController;

@end
