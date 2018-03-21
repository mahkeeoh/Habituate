//
//  CircleView.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self loadView];
    return self;
}

- (void)loadView
{
    // Create circle parameters
    self.circlePath = [[UIBezierPath alloc]init];
    float radius = (MIN(self.frame.size.width, self.frame.size.height)/2.0) - 20;
    [self.circlePath addArcWithCenter:self.center radius:radius startAngle:-M_PI / 2.0 endAngle:M_PI * 3.0/2.0 clockwise:YES];
    
    // Create countdown timer parameters
    CGRect timerRect = CGRectMake(0, 0, 2 * radius - 30, (radius - 30)/2);
    self.timerLabel = [[UILabel alloc]initWithFrame:timerRect];
    self.timerLabel.center = self.center;

    self.countdownTimer = [[MZTimerLabel alloc]initWithLabel:self.timerLabel andTimerType:MZTimerLabelTypeTimer];
    self.timerLabel.font = [UIFont systemFontOfSize:60.0f];
    self.timerLabel.textColor = [UIColor colorWithRed:.5568 green:.5568 blue:.5765 alpha:.65];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    //timerLabel.adjustsFontSizeToFitWidth = YES;
    [self.countdownTimer setCountDownTime:0];
    self.countdownTimer.timeFormat = @"HH:mm:ss";
    [self addSubview:self.timerLabel];
    
    CGRect nameRect = CGRectMake(self.center.x - (radius - 15), self.center.y + ((radius - 30) / 4), 2 * radius - 30, (radius - 30)/2);
    self.nameLabel = [[UILabel alloc]initWithFrame:nameRect];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:25.0f];
    self.nameLabel.textColor = [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1];
    [self addSubview:self.nameLabel];
    
    
    // Draw the grey circle
    self.greyCircle = [CAShapeLayer layer];
    [self.greyCircle setPath:self.circlePath.CGPath];
    self.greyCircle.fillColor = [UIColor clearColor].CGColor;
    self.greyCircle.strokeColor = [UIColor colorWithRed:.5568 green:.5568 blue:.5765 alpha:.65].CGColor;
    self.greyCircle.lineWidth = 24;
    [self.layer addSublayer:self.greyCircle];
    
    
    // Prepare animated green circle
    self.greenCircle = [CAShapeLayer layer];
    [self.greenCircle setPath:self.circlePath.CGPath];
    self.greenCircle.fillColor = [UIColor clearColor].CGColor;
    self.greenCircle.lineWidth = 26;
    self.greenCircle.strokeColor = [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1].CGColor;
    self.greenCircle.strokeEnd = 0.0;
    [self.layer addSublayer:self.greenCircle];
    
    // Prepare label of Task
    CGFloat width = CGRectGetWidth(self.bounds);
    CGRect taskRect = CGRectMake(0, 276, width, 50);
    self.taskLabel = [[UILabel alloc]initWithFrame:taskRect];
    self.taskLabel.textAlignment = NSTextAlignmentCenter;
    [self.taskLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [self addSubview:self.taskLabel];
}

- (void)didTapPlayPauseButton
{
    [self.timerLabel setTextColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1]];
    if(!self.animation)
    {
        [self animateCircle];
    }
    else if(self.greenCircle.speed == 0)
    {
        [self resumeLayer:self.greenCircle];
    }
    else
    {
        [self pauseLayer:self.greenCircle];
    }
}

- (void)animateCircle
{

    
    // Set countdown timer
    if (self.countdownTimer.getCountDownTime)
    {
        [self.countdownTimer reset];
    }
    
    self.countdownTimer.timerType = MZTimerLabelTypeTimer;
    [self.countdownTimer setCountDownTime:self.duration];

    
    // Animate the drawing of the circle
    self.animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.animation.duration = self.duration;
    NSNumber *animFromValue = [NSNumber numberWithDouble:self.fromValue];
//    printf("fromValue: %f \n", (self.fromValue * 60));
    self.animation.fromValue = animFromValue;
    self.animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    self.animation.delegate = self;
    
    
    self.greenCircle.strokeEnd = 1;
    
    // Initialize animation
    [self.greenCircle addAnimation:self.animation forKey:@"strokeEnd"];
    
    [self.countdownTimer start];
    
    self.loadingStartTime = [[NSDate date]timeIntervalSince1970];
}

- (void)pauseLayer:(CALayer *)layer
{
    self.savingPauseTime = [[NSDate date]timeIntervalSince1970];
    self.pausedTime = [self.greenCircle convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.timeOffset = self.pausedTime;
    layer.speed = 0.0;
    [self.countdownTimer pause];
}

- (void)resumeLayer:(CALayer *)layer
{
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.greenCircle convertTime:CACurrentMediaTime() fromLayer:nil] - self.pausedTime;
    layer.beginTime = timeSincePause;
    
    // resume timer and update remaining time
    
    [self.countdownTimer start];
    
    // update start time for load screen every resume
    self.loadingStartTime = [[NSDate date]timeIntervalSince1970];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES)
    {
        // must save original time here before going into new timing.
        [self.delegate saveCircle];
        [self continueFinishedTime];
    }
}


- (void)continueFinishedTime
{
    [CATransaction setDisableActions:YES];
    self.greenCircle.strokeEnd = 1.0;
    
    // Set countdown timer
    [self.countdownTimer reset];
    
    NSTimeInterval addedTime = -self.duration;
    self.countdownTimer.timerType = MZTimerLabelTypeStopWatch;
    [self.countdownTimer setStopWatchTime:addedTime];
    [self.countdownTimer start];
    
    self.loadingStartTime = [[NSDate date]timeIntervalSince1970];
}

- (void)pauseFinishedTime
{
    self.savingPauseTime = [[NSDate date]timeIntervalSince1970];
    [self.countdownTimer pause];
}

@end
