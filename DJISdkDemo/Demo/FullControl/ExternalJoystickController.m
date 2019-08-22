//
//  ExternalJoystickController.m
//  DJISdkDemo
//
//  Created by Ping Chen on 8/21/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import "ExternalJoystickController.h"
@import GameController;

@interface ExternalJoystickController ()
@property (strong, nonatomic) GCController *mainController;
@end

@implementation ExternalJoystickController

-(instancetype) init {
    self = [super init];
    
    // notifications for controller (dis)connect
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerWasConnected:) name:GCControllerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controllerWasDisconnected:) name:GCControllerDidDisconnectNotification object:nil];
    
    return self;
}

- (void)controllerWasConnected:(NSNotification *)notification {
    
    // a controller was connected
    GCController *controller = (GCController *)notification.object;
    NSString *status = [NSString stringWithFormat:@"Controller connected\nName: %@\n", controller.vendorName];
    if (self.delegate && [self.delegate respondsToSelector:@selector(joystickMessage:)]) {
        [self.delegate joystickMessage:status];
    }
    
    self.mainController = controller;
    [self reactToInput];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controllerConnected)]) {
        [self.delegate controllerConnected];
    }
    
}

- (void)controllerWasDisconnected:(NSNotification *)notification {
    
    // a controller was disconnected
    GCController *controller = (GCController *)notification.object;
    NSString *status = [NSString stringWithFormat:@"Controller disconnected\nName: %@\n", controller.vendorName];
    if (self.delegate && [self.delegate respondsToSelector:@selector(joystickMessage:)]) {
        [self.delegate joystickMessage:status];
    }
    self.mainController = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controllerDisconnected)]) {
        [self.delegate controllerDisconnected];
    }
}

- (void)reactToInput {
    
    // register block for input change detection
    GCExtendedGamepad *profile = self.mainController.extendedGamepad;
    profile.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element)
    {
        NSString *message = @"Waiting...";
        
        // left trigger
        if (gamepad.leftTrigger == element && gamepad.leftTrigger.isPressed) {
            message = @"Left Trigger";
        }
        
        // right trigger
        if (gamepad.rightTrigger == element && gamepad.rightTrigger.isPressed) {
            message = @"Right Trigger";
        }
        
        // left shoulder button
        if (gamepad.leftShoulder == element && gamepad.leftShoulder.isPressed) {
            message = @"Left Shoulder Button";
        }
        
        // right shoulder button
        if (gamepad.rightShoulder == element && gamepad.rightShoulder.isPressed) {
            message = @"Right Shoulder Button";
        }
        
        // A button
        if (gamepad.buttonA == element && gamepad.buttonA.isPressed) {
            message = @"A Button";
        }
        
        // B button
        if (gamepad.buttonB == element && gamepad.buttonB.isPressed) {
            message = @"B Button";
        }
        
        // X button
        if (gamepad.buttonX == element && gamepad.buttonX.isPressed) {
            message = @"X Button";
        }
        
        // Y button
        if (gamepad.buttonY == element && gamepad.buttonY.isPressed) {
            message = @"Y Button";
        }
        
        // d-pad
        if (gamepad.dpad == element) {
            if (gamepad.dpad.up.isPressed) {
                message = @"D-Pad Up";
                [self.delegate dPadUp];
            }
            else if (gamepad.dpad.down.isPressed) {
                message = @"D-Pad Down";
                [self.delegate dPadDown];
            }
            else if (gamepad.dpad.left.isPressed) {
                message = @"D-Pad Left";
                [self.delegate dPadLeft];
            }
            else if (gamepad.dpad.right.isPressed) {
                message = @"D-Pad Right";
                [self.delegate dPadRight];
            }
            else {
                message = @"D-Pad Release";
                [self.delegate dPadReleased];
            }
            
        }
        
        // left stick
        if (gamepad.leftThumbstick == element) {
            if (gamepad.leftThumbstick.up.isPressed) {
                message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.yAxis.value];
            }
            else if (gamepad.leftThumbstick.down.isPressed) {
                message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.yAxis.value];
            }
            else if (gamepad.leftThumbstick.left.isPressed) {
                message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.xAxis.value];
            }
            else if (gamepad.leftThumbstick.right.isPressed) {
                message = [NSString stringWithFormat:@"Left Stick %f", gamepad.leftThumbstick.xAxis.value];
            }
            else {
                message = @"Left Stick Released";
            }
            [self.delegate stickWithHorizontalValue:gamepad.leftThumbstick.xAxis.value];
        }
        
        // right stick
        if (gamepad.rightThumbstick == element) {
            if (gamepad.rightThumbstick.up.isPressed) {
                message = [NSString stringWithFormat:@"Right Stick %f", gamepad.rightThumbstick.yAxis.value];
            }
            if (gamepad.rightThumbstick.down.isPressed) {
                message = [NSString stringWithFormat:@"Right Stick %f", gamepad.rightThumbstick.yAxis.value];
            }
            if (gamepad.rightThumbstick.left.isPressed) {
                message = [NSString stringWithFormat:@"Right Stick %f", gamepad.rightThumbstick.xAxis.value];
            }
            if (gamepad.rightThumbstick.right.isPressed) {
                message = [NSString stringWithFormat:@"Right Stick %f", gamepad.rightThumbstick.xAxis.value];
            }
            else {
                message = @"Right Stick Release";
            }
            
            [self.delegate stickWithHorizontalValue:gamepad.rightThumbstick.xAxis.value];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(joystickMessage:)]) {
            [self.delegate joystickMessage:message];
        }
                
    };
}

@end
