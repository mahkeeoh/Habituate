//
//  ViewController.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/1/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "DayOfWork.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <CircleViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property CABasicAnimation *animationViewPosition;
@property CircleView *topCircle;
@property NSTimeInterval loadStartTime;
@property NSTimeInterval loadEndTime;
@property NSDate *currentDate;
@property NSDateComponents *currentComponents;
@property NSTimer *timer;

- (void)recordSaveLoadEnd:(CFTimeInterval)endTime start:(CFTimeInterval)startTime;
- (void)buttonClicked:(int)row;
- (void)updatePercent:(NSTimer*)sender;
- (void)addBlankDays:(DayOfWork *)lastRecordedDay fromData:(TaskData *)data;
- (void)timerClicked;
- (void)saveCircle;
- (void)loadCircle;
- (void)applicationWillTerminate;
- (void)applicationEnteringBackground;
- (void)applicationEnteringForeground;
- (void)caretClicked;

@end

