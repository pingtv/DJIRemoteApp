//
//  FullControlViewController.m
//  DJISdkDemo
//
//  Created by Ping Chen on 1/17/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import "FullControlViewController.h"
#import "DJIGimbal+CapabilityCheck.h"
#import "DemoUtility.h"

@interface FullControlViewController () <DJIGimbalDelegate, UITextFieldDelegate>

@property (assign, nonatomic) NSNumber *pitchRotation;
@property (assign, nonatomic) NSNumber *yawRotation;

@property(strong,nonatomic) NSTimer* gimbalSpeedTimer;

@property (strong) NSMutableArray *motionRecord;

@end

@implementation FullControlViewController

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
    
    [self.phoneTag setDelegate:self];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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

#pragma mark - controlSlider methods
- (IBAction)controlSliderValueChanged:(id)sender {
    [self checkAndStartSpeedTimer];
    self.pitchRotation = nil;
    self.yawRotation = [NSNumber numberWithInt:(int)self.controlSlider.value];
}
- (IBAction)controlSliderRelease:(id)sender {
    [self.controlSlider setValue:0 animated:YES];
    self.yawRotation = @(0);
}


-(void) onUpdateGimbalSpeedTick:(id)timer {
    DJIGimbal* gimbal = [DemoComponentHelper fetchGimbal];
    if (gimbal) {
        DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:self.pitchRotation
                                                                            rollValue:nil
                                                                             yawValue:self.yawRotation
                                                                                 time:0
                                                                                 mode:DJIGimbalRotationModeSpeed];
        
        [gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR: rotateGimbalInSpeed. %@", error.description);
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
    
    CFAbsoluteTime timeInSeconds = CFAbsoluteTimeGetCurrent();
    double timestamp = timeInSeconds + NSTimeIntervalSince1970;
    
    NSLog(@"%f", timestamp);
    
    self.gimbalInfoLabel.text = [NSString stringWithFormat:@"pitch %f\n roll %f\n yaw %f", state.attitudeInDegrees.pitch,
                                 state.attitudeInDegrees.roll,
                                 state.attitudeInDegrees.yaw];
    
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
    NSString *filePath= [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-motionData.csv", self.phoneTag.text]];
    
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
