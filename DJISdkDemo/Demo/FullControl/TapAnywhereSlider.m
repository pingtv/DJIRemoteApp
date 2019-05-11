//
//  TapAnywhereSlider.m
//  DJISdkDemo
//
//  Created by Ping on 5/11/19.
//  Copyright © 2019 DJI. All rights reserved.
//

#import "TapAnywhereSlider.h"

@implementation TapAnywhereSlider

-(instancetype)init {
    self = [super init];
    if (self) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(tapAndSlide:)];
        longPress.minimumPressDuration = 0;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    return [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
}

- (void)tapAndSlide:(UILongPressGestureRecognizer*)gesture
{
    CGPoint pt = [gesture locationInView: self];
    CGFloat thumbWidth = [self thumbRect].size.width;
    CGFloat value;
    
    if(pt.x <= [self thumbRect].size.width/2.0)
        value = self.minimumValue;
    else if(pt.x >= self.bounds.size.width - thumbWidth/2.0)
        value = self.maximumValue;
    else {
        CGFloat percentage = (pt.x - thumbWidth/2.0)/(self.bounds.size.width - thumbWidth);
        CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
        value = self.minimumValue + delta;
    }
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setValue:value animated:YES];
            [super sendActionsForControlEvents:UIControlEventValueChanged];
        } completion:nil];
    }
    else [self setValue:value];
    
    if(gesture.state == UIGestureRecognizerStateChanged)
        [super sendActionsForControlEvents:UIControlEventValueChanged];
    
    if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed)
        [super sendActionsForControlEvents:UIControlEventTouchUpInside];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
