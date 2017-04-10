//
//  DayOfWork.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "DayOfWork.h"

@implementation DayOfWork

- (instancetype)initWithDate:(NSDate *)date
                   Component:(NSDateComponents *)dayComponent
               timeCompleted:(int)dayTimeCompleted;
{
    self = [super init];
    if (self)
    {
        _date = date;
        _dayComponent = dayComponent;
        _dayTimeCompleted = dayTimeCompleted;
    }
    return self;
}

- (void)addTime
{
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.dayComponent forKey:@"dayComponent"];
    [aCoder encodeInt:self.dayTimeCompleted forKey:@"dayTimeCompleted"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.date= [aDecoder decodeObjectForKey:@"date"];
        self.dayComponent = [aDecoder decodeObjectForKey:@"dayComponent"];
        self.dayTimeCompleted = [aDecoder decodeIntForKey:@"dayTimeCompleted"];
    }
    return self;
}

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"Date: %@ dayComponent: %@  daytimecompleted: %f", self.date, self.dayComponent, self.dayTimeCompleted];
    return descriptionString;
    
}

@end
