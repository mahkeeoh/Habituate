//
//  CircleView.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskStore.h"
@import MZTimerLabel;

IB_DESIGNABLE

@protocol CircleViewDelegate

- (void)saveCircle;

@end

@interface CircleView : UIView
// Draw shapes
@property CAShapeLayer *greyCircle;
@property CAShapeLayer *greenCircle;
@property UIBezierPath *circlePath;
@property UILabel *taskLabel;

// Animation properties
@property CFTimeInterval duration;
@property CFTimeInterval fromValue;
@property CABasicAnimation *animation;
//@property NSDate *startDate;
//@property NSDateComponents *components;
@property CFTimeInterval savingPauseTime;
@property CFTimeInterval loadingStartTime;
@property CFTimeInterval pausedTime;
@property NSInteger buttonTag;

// Countdown Timer
@property UILabel *timerLabel;
@property UILabel *nameLabel;
@property MZTimerLabel *countdownTimer;
@property NSInteger tagNumber;
//@property UILabel *timerLabel;


// Assign delegate to communicate with Master
@property  id <CircleViewDelegate> delegate;


- (void)loadView;
- (void)animateCircle;
- (void)didTapPlayPauseButton;
- (void)pauseLayer:(CALayer *)layer;
- (void)resumeLayer:(CALayer *)layer;
- (void)continueFinishedTime;
- (void)pauseFinishedTime;

@end

