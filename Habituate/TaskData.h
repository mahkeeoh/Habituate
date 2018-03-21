//
//  TaskData.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskData : NSObject <NSCoding>

@property NSString *taskDataName;
@property CFTimeInterval taskDataTime;
@property CFTimeInterval taskFinalTime;
@property long taskDataType;
@property NSDate *startingDate;
@property NSDateComponents *startingComponents;
@property NSDateComponents *currentComponents;
@property BOOL isPlaying;
@property CFTimeInterval stackingTime;
@property CFTimeInterval remainingDuration;
@property CFTimeInterval dailyRemainingDuration;
@property long daysRemaining;
@property CFTimeInterval resumeFromValue;
@property NSMutableArray *timeCompleted;
@property BOOL animationIsComplete;
@property BOOL isGoodHabit;

- (instancetype)initWithName:(NSString *)name
                 initialTime:(double)initialTime
                   finalTime:(double)finalTime
             initialDuration:(double)initialDuration
                        type:(long)type
               daysRemaining:(double)daysRemaining;

- (void)resetComponents;

@end
