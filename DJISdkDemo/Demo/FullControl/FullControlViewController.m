//
//  FullControlViewController.m
//  DJISdkDemo
//
//  Created by Ping Chen on 1/17/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import "FullControlViewController.h"
#import "FileLabelViewController.h"
#import "ExternalJoystickController.h"
#import "DJIGimbal+CapabilityCheck.h"
#import "DemoUtility.h"
#import "AppDelegate.h"

#define MAX_PAN_SPEED 80
#define DEADZONE 0.1
#define DAMPENING_FACTOR 0.8

@interface FullControlViewController () <DJIGimbalDelegate, UITextFieldDelegate, FileLabelDelegate, ExternalJoystickDelegate>

@property (assign, nonatomic) NSNumber *pitchRotation;
@property (assign, nonatomic) NSNumber *yawRotation;

@property(strong,nonatomic) NSTimer* gimbalSpeedTimer;

@property (strong) NSString *recordFileName;
@property (strong) NSMutableArray *motionRecord;

@property (strong) ExternalJoystickController *externalJoystickController;


@end

@implementation FullControlViewController {
    BOOL decelerating;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    FileLabelViewController *labelVC = [[FileLabelViewController alloc] initWithNibName:@"FileLabelViewController" bundle:nil];
    [labelVC setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [labelVC setDelegate:self];
    
    [self presentViewController:labelVC animated:YES completion:nil];
    
    if (!self.recordFileName) {
        self.recordFileName = @"";
    }
    

    self.controlSlider = [[TapAnywhereSlider alloc] init];
    [self.view addSubview:self.controlSlider];
    [self.controlSlider setFrame:CGRectMake(15, self.view.bounds.size.height-270.0, self.view.bounds.size.width - 30, 250)];
    [self.controlSlider setBackgroundColor:[UIColor lightGrayColor]];
    [self.controlSlider setMaximumValue:MAX_PAN_SPEED];
    [self.controlSlider setMinimumValue:-MAX_PAN_SPEED];
    [self.controlSlider setValue:0];
    
    [self.controlSlider addTarget:self action:@selector(controlSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlSlider addTarget:self action:@selector(controlSliderRelease:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlSlider addTarget:self action:@selector(controlSliderRelease:) forControlEvents:UIControlEventTouchUpOutside];
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    appdelegate.joystickController.delegate = self;
    
    decelerating = NO;

}

-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [super viewWillAppear:animated];
    
    [self.gimbalInfoLabel setNumberOfLines:0];
    [self setupButtons];
    [self setupRotationStructs];
    
    [self checkAndStartSpeedTimer];
    
    __weak DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal) {
        [gimbal setDelegate:self];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.gimbalSpeedTimer) {
        [self.gimbalSpeedTimer invalidate];
        self.gimbalSpeedTimer = nil;
    }
    
    // Clean gimbal's delegate before exiting the view
    __weak DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal && gimbal.delegate == self) {
        [gimbal setDelegate:nil];
    }
    
    if (_motionRecord && _motionRecord.count > 0) {
        [self writeToFile:_motionRecord];
        [_motionRecord removeAllObjects];
    }
}



-(void)checkAndStartSpeedTimer {
    if (self.gimbalSpeedTimer == nil || ![self.gimbalSpeedTimer isValid]) {
        self.gimbalSpeedTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(onUpdateGimbalSpeedTick:) userInfo:nil repeats:YES];
    }
}

-(void) setupButtons {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    [self.upButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustPitch]];
    [self.downButton setEnabled:[gimbal isFeatureSupported:DJIGimbalParamAdjustPitch]];
}

-(void) setupRotationStructs {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    self.pitchRotation = [gimbal isFeatureSupported:DJIGimbalParamAdjustPitch] ? @(0) : nil;
    self.yawRotation = [gimbal isFeatureSupported:DJIGimbalParamAdjustYaw] ? @(0) : nil;
}


- (IBAction)onUpButtonPress:(id)sender{
    [self checkAndStartSpeedTimer];
    self.pitchRotation = @(3);
    self.yawRotation = nil;
}
- (IBAction)onDownButtonPress:(id)sender{
    [self checkAndStartSpeedTimer];
    self.pitchRotation = @(-3);
    self.yawRotation = nil;
}

- (IBAction)onAllButtonRelease:(id)sender {
    self.pitchRotation = nil;
    self.yawRotation = nil;
}

#pragma mark FileLabelDelegate
- (void)setFileLabel:(NSString *)fileLabel {
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"y-MM-dd-HH-mm"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    self.recordFileName = [NSString stringWithFormat:@"%@-%@", fileLabel, resultString];
}

#pragma mark - controlSlider methods
- (void)controlSliderValueChanged:(id)sender {
    float val = self.controlSlider.outputValue;
    
    if (ABS(val) > 90) {
        NSLog(@"lalal");
    }
    
    [self checkAndStartSpeedTimer];
    self.pitchRotation = nil;
    self.yawRotation = [NSNumber numberWithInt:(int)val];
}
- (void)controlSliderRelease:(id)sender {
    
    [self deceleration];
    [self.controlSlider setValue:0 animated:YES];
    [self.controlSlider setOutputValue:0];
    
//    [self checkAndStartSpeedTimer];
//    self.pitchRotation = nil;
//    [self.controlSlider setValue:0 animated:YES];
//    [self.controlSlider setOutputValue:0];
//    self.yawRotation = @(0);
}


-(void) onUpdateGimbalSpeedTick:(id)timer {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal) {
        
        NSLog(@"executed yaw %f",[self.yawRotation floatValue]);
        
        DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:self.pitchRotation
                                                                            rollValue:nil
                                                                             yawValue:self.yawRotation
                                                                                 time:0
                                                                                 mode:DJIGimbalRotationModeSpeed];
        
        [gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR: rotateGimbalInSpeed. %@", error.description);
            }
            if (decelerating) {
                [self deceleration];
            }
        }];
    }
}


- (IBAction)onResetButtonClicked:(id)sender{
    [self.gimbalSpeedTimer invalidate];
    self.gimbalSpeedTimer = nil;
    
    self.pitchRotation = @(0);
    self.yawRotation = @(0);
    
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal == nil) {
        return;
    }
    
    DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:@(0)
                                                                        rollValue:@(0)
                                                                         yawValue:@(0) time:1.5
                                                                             mode:DJIGimbalRotationModeAbsoluteAngle];
    [gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"rotateWithRotation failed: %@", error.description);
        }
    }];
}

-(void)deceleration {
    int dir = ((self.yawRotation.integerValue > 0)? 1:-1);
    NSLog(@"decelerate yaw: %@ dir: %d", self.yawRotation, dir);
    [self.joystickMessageLabel setText:[NSString stringWithFormat:@"%@", self.yawRotation]];
    
    [self checkAndStartSpeedTimer];
    
    self.yawRotation = [NSNumber numberWithInteger:(dir * (NSInteger)floorf(DAMPENING_FACTOR * fabsf([self.yawRotation floatValue])))];
    if ([self.yawRotation intValue] != 0) {
        decelerating = YES;
    } else {
        decelerating = NO;
    }
}


#pragma mark - ExternalJoystickDelegate
-(void)controllerConnected {
    
}

- (void)controllerDisconnected {
    
}

-(void)joystickMessage:(NSString *)message {
    [self.joystickMessageLabel setText:message];
}

- (void)stickWithHorizontalValue:(float)value {
    // give some deadzone and rescale remaining between [-1, 1]
    float val;
    if (fabsf(value) < DEADZONE) {
        val = 0.0;
    } else {
        val = (fabsf(value) - DEADZONE) * 1.0/(1-DEADZONE) * ((value > 0)? 1:-1);
    }
    
    // value is [-1, 1]. Map that to [-MAX_PAN_SPEED, MAX_PAN_SPEED]
    val = val*MAX_PAN_SPEED;
    
    // try decelerating rather than abrupt stop. Abrupt stop is too much torque and causes high frequency vibrations
    if (val == 0) {
        [self deceleration];
    } else {
        [self checkAndStartSpeedTimer];
        self.pitchRotation = nil;
        self.yawRotation = [NSNumber numberWithInt:(int)val];
    }
}

- (void)dPadUp {
    [self checkAndStartSpeedTimer];
    self.pitchRotation = @(3);
    self.yawRotation = nil;
}

-(void)dPadDown {
    [self checkAndStartSpeedTimer];
    self.pitchRotation = @(-3);
    self.yawRotation = nil;
}

-(void)dPadRight {
    [self checkAndStartSpeedTimer];
    self.yawRotation = @(MAX_PAN_SPEED/2);
    self.pitchRotation = nil;
}

-(void)dPadLeft {
    [self checkAndStartSpeedTimer];
    self.yawRotation = @(-MAX_PAN_SPEED/2);
    self.pitchRotation = nil;
}

-(void)dPadReleased {
    [self checkAndStartSpeedTimer];
    self.yawRotation = @(0);
    self.pitchRotation = nil;
}

#pragma mark - DJIGimbalDelegate
// Override method in DJIGimbalDelegate to receive the pushed data
-(void)gimbal:(DJIGimbal *)gimbal didUpdateState:(DJIGimbalState *)state {
//    NSMutableString* gimbalInfoString = [[NSMutableString alloc] init];
//    [gimbalInfoString appendFormat:@"%f, %f, %f)\n", state.attitudeInDegrees.pitch,
//     state.attitudeInDegrees.roll,
//     state.attitudeInDegrees.yaw];
//    [gimbalInfoString appendString:@"Gimbal work mode: "];
//    switch (state.mode) {
//        case DJIGimbalModeFPV:
//            [gimbalInfoString appendString:@"FPV\n"];
//            break;
//        case DJIGimbalModeFree:
//            [gimbalInfoString appendString:@"Free\n"];
//            break;
//        case DJIGimbalModeYawFollow:
//            [gimbalInfoString appendString:@"Yaw-follow\n"];
//            break;
//
//        default:
//            break;
//    }
//    [gimbalInfoString appendString:@"Is calibrating: "];
//    [gimbalInfoString appendString:state.isCalibrating?@"YES\n" : @"NO\n"];
//    [gimbalInfoString appendString:@"Is pitch at stop: "];
//    [gimbalInfoString appendString:state.isPitchAtStop?@"YES\n" : @"NO\n"];
//    [gimbalInfoString appendString:@"Is roll at stop: "];
//    [gimbalInfoString appendString:state.isRollAtStop?@"YES\n" : @"NO\n"];
//    [gimbalInfoString appendString:@"Is yaw at stop: "];
//    [gimbalInfoString appendString:state.isYawAtStop?@"YES\n" : @"NO\n"];
    
    NSString *gimbalInfoString = @"";
    switch (state.mode) {
        case DJIGimbalModeFPV:
            gimbalInfoString = @"FPV\n";
            break;
        case DJIGimbalModeFree:
            gimbalInfoString = @"Free\n";
            break;
        case DJIGimbalModeYawFollow:
            gimbalInfoString = @"yaw-follow\n";
            break;
            
        default:
            break;
    }
    
    CFAbsoluteTime timeInSeconds = CFAbsoluteTimeGetCurrent();
    double timestamp = timeInSeconds + NSTimeIntervalSince1970;
    
    self.gimbalInfoLabel.text = [NSString stringWithFormat:@" %@ pitch %f\n roll %f\n yaw %f\n slider value: %f",
                                 gimbalInfoString,
                                 state.attitudeInDegrees.pitch,
                                 state.attitudeInDegrees.roll,
                                 state.attitudeInDegrees.yaw,
                                 self.controlSlider.outputValue];
    

    
    if (!_motionRecord) {
        _motionRecord = [[NSMutableArray alloc] init];
    }
    
    [_motionRecord addObject:@{@"timestamp": [NSNumber numberWithDouble:timestamp],
                               @"pitch": [NSNumber numberWithFloat:state.attitudeInDegrees.pitch],
                               @"roll": [NSNumber numberWithFloat:state.attitudeInDegrees.roll],
                               @"yaw": [NSNumber numberWithFloat:state.attitudeInDegrees.yaw]
                               }];
    
    if (_motionRecord.count >= 300) {
        [self writeToFile:[_motionRecord copy]];
        [_motionRecord removeAllObjects];
    }
    
}



-(void)writeToFile:(NSArray*)motionData{
    NSString *filePath= [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-gimbal_attitudes.csv", self.recordFileName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0]; //don't worry about the capacity, it will expand as necessary
    
    for (int i=0; i<[motionData count]; i++) {
        NSDictionary *dic = [motionData objectAtIndex:i];
        [writeString appendString:[NSString stringWithFormat:@"%@, %@, %@, %@\n", dic[@"timestamp"], dic[@"pitch"], dic[@"roll"], dic[@"yaw"]]];
    }
    
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //say to handle where's the file fo write
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    //position handle cursor to the end of file
    [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
