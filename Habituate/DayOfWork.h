//
//  DayOfWork.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayOfWork : NSObject <NSCoding>

@property NSDate *date;
@property NSDateComponents *dayComponent;
@property double dayTimeCompleted;

- (instancetype)initWithDate:(NSDate *)date
                   Component:(NSDateComponents *)dayComponent
               timeCompleted:(int)dayTimeCompleted;
- (void)addTime;

@end

