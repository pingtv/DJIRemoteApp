//
//  ExternalJoystickController.h
//  DJISdkDemo
//
//  Created by Ping Chen on 8/21/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExternalJoystickDelegate <NSObject>

-(void)stickWithHorizontalValue:(float)value;
-(void)dPadLeft;
-(void)dPadRight;
-(void)dPadUp;
-(void)dPadDown;
-(void)dPadReleased;



@optional

-(void)controllerConnected;
-(void)controllerDisconnected;

-(void)joystickMessage:(NSString *)message;

@end


@interface ExternalJoystickController : NSObject

@property (weak) id <ExternalJoystickDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
