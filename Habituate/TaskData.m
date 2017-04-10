//
//  TaskData.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "TaskData.h"

@implementation TaskData

- (instancetype)initWithName:(NSString *)name
                 initialTime:(double)initialTime
                   finalTime:(double)finalTime
             initialDuration:(double)initialDuration
                        type:(long)type;
{
    self = [super init];
    if (self)
    {
        _taskDataName = name;
        _taskDataTime = initialTime;
        _taskFinalTime = finalTime;
        _remainingDuration = initialDuration;
        _taskDataType = type;
        _timeCompleted = [[NSMutableArray alloc]init];
        _startingDate = [NSDate date];
        _startingComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:_startingDate];
        _currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:_startingDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.taskDataName forKey:@"taskDataName"];
    [aCoder encodeDouble:self.taskDataTime forKey:@"taskDataTime"];
    [aCoder encodeDouble:self.taskFinalTime forKey:@"taskFinalTime"];
    [aCoder encodeInteger:self.taskDataType forKey:@"taskDataType"];
    [aCoder encodeObject:self.timeCompleted forKey:@"timeCompleted"];
    [aCoder encodeObject:self.startingDate forKey:@"startingDate"];
    [aCoder encodeObject:self.startingComponents forKey:@"startingComponents"];
    [aCoder encodeObject:self.currentComponents forKey:@"currentComponents"];
    [aCoder encodeDouble:self.stackingTime forKey:@"stackingTime"];
    [aCoder encodeDouble:self.remainingDuration forKey:@"remainingDuration"];
    [aCoder encodeDouble:self.dailyRemainingDuration forKey:@"dailyRemainingDuration"];
    [aCoder encodeDouble:self.daysRemaining forKey:@"daysRemaining"];
    [aCoder encodeDouble:self.resumeFromValue forKey:@"resumeFromValue"];
    [aCoder encodeBool:self.animationIsComplete forKey:@"animationIsComplete"];
    [aCoder encodeBool:self.isGoodHabit forKey:@"isGoodHabit"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.taskDataName = [aDecoder decodeObjectForKey:@"taskDataName"];
        self.taskDataTime = [aDecoder decodeDoubleForKey:@"taskDataTime"];
        self.taskFinalTime = [aDecoder decodeDoubleForKey:@"taskFinalTime"];
        self.taskDataType = [aDecoder decodeIntegerForKey:@"taskDataType"];
        self.timeCompleted = [aDecoder decodeObjectForKey:@"timeCompleted"];
        self.startingDate = [aDecoder decodeObjectForKey:@"startingDate"];
        self.startingComponents = [aDecoder decodeObjectForKey:@"startingComponents"];
        self.currentComponents = [aDecoder decodeObjectForKey:@"currentComponents"];
        self.stackingTime = [aDecoder decodeDoubleForKey:@"stackingTime"];
        self.remainingDuration = [aDecoder decodeDoubleForKey:@"remainingDuration"];
        self.dailyRemainingDuration = [aDecoder decodeDoubleForKey:@"dailyRemainingDuration"];
        self.daysRemaining = [aDecoder decodeDoubleForKey:@"daysRemaining"];
        self.resumeFromValue = [aDecoder decodeDoubleForKey:@"resumeFromValue"];
        self.animationIsComplete = [aDecoder decodeBoolForKey:@"animationIsComplete"];
        self.isGoodHabit = [aDecoder decodeBoolForKey:@"isGoodHabit"];
    }
    return self;
}

- (void)resetComponents
{
    self.stackingTime = 0;
    self.taskDataTime = self.taskFinalTime;
    self.remainingDuration = self.taskDataTime;
    self.resumeFromValue = 0;
}
@end

