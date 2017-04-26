//
//  TaskCell.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.playButton.titleLabel.minimumScaleFactor = 0.5f;
        self.playButton.titleLabel.numberOfLines = 1;
        self.playButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
    }
    return self;
}

- (void)cellSetup:(TaskData *)task withDate:(NSDate *)date andComponents:(NSDateComponents *)components
{
    switch (task.taskDataType)
    {
        case 0:
        {
            task.daysRemaining = 1;
            self.detailText.text =[NSString stringWithFormat:@"Daily. %.01f minutes remaining today", ((task.remainingDuration / task.daysRemaining) / 60)];
            if (([task.startingComponents day]!= [components day]))
            {
                [task resetComponents];
                task.daysRemaining = 1;
                task.startingDate = date;
                task.startingComponents = components;
            }
            break;
        }
        case 1:
        {
            
            
            // 8 - days gives remaining day (7 for sunday)
            task.daysRemaining = 8 - [components weekday];
            self.detailText.text = [NSString  stringWithFormat:@"Weekly. %.01f minutes remaining today", ((task.remainingDuration / task.daysRemaining) / 60)];
            
            
            // Reset time, and always set start date to the sunday of that week
            if (([task.startingComponents weekOfYear]!= [components weekOfYear]))
            {
                [task resetComponents];
                [components setWeekday:1];
                task.startingDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                task.startingComponents = components;
                components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:date];
                
            }
            break;
        }
        case 2:
        {
            // Calculate number of days in current month
            NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            NSUInteger numberOfDaysInMonth = rng.length;
            
            {
                task.daysRemaining = numberOfDaysInMonth - [components day] + 1;
                self.detailText.text = [NSString  stringWithFormat:@"Monthly. %.01f minutes remaining today", ((task.remainingDuration / task.daysRemaining) / 60)];
            }
            
            if (([task.startingComponents month]!= [components month]))
            {
                [task resetComponents];
                [components setDay:1];
                task.startingDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                task.startingComponents = components;
                components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:date];
            }
            break;
        }
    }
    if (([task.currentComponents day]!= [components day]))
    {
        task.dailyRemainingDuration = (task.remainingDuration / task.daysRemaining);
        task.stackingTime = 0;
        task.resumeFromValue = 0;
        components = components;
    }
    
    self.nameText.text = task.taskDataName;
    //[cell.detailButton addTarget:self action:@selector(detailClicked) forControlEvents:UIControlEventTouchUpInside];
    NSString *percentRemaining = [NSString stringWithFormat:@"%.0f%%", (100 - (task.remainingDuration/task.taskDataTime * 100))];
    
    if (!task.remainingDuration)
    {
        percentRemaining = [NSString stringWithFormat:@"0%%"];
    }
    [self.playButton setTitle:percentRemaining forState:UIControlStateNormal];
    
    if (task.isGoodHabit)
    {
        [self.playButton setTitleColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setTitleColor:[UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1] forState:UIControlStateNormal];
    }
}

@end
