//
//  ViewController.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/1/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AddTaskViewController.h"
#import "TaskData.h"
#import "TaskStore.h"
#import "TaskCell.h"
#import "DayOfWork.h"

@interface MasterViewController ()

@property NSArray *tasks;
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


@end

@implementation MasterViewController


#pragma mark - Leaving/Entering View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Only check for date when initially opening app (If user is still using the app when it goes past midnight, it will count for original day
    self.currentDate= [NSDate date];
    self.currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:self.currentDate];
    
    // Prepare notifications for leaving app
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteringBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteringForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewwillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.topCircle.duration != 0)
    {
        [self loadCircle];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Check if animation was running or circle was full
    if (self.topCircle.animation || (self.topCircle.duration < 0))
    {
        // So that when circle view returns, it won't look filled for a brief moment
        self.topCircle.greenCircle.strokeEnd = 0.0;
        [self saveCircle];
    }
}

- (void)applicationEnteringForeground
{
    if (self.isViewLoaded && self.view.window)
    {
        if (self.topCircle.duration != 0)
        {
            [self loadCircle];
        }
    }
}

- (void)applicationEnteringBackground
{
    if (self.isViewLoaded && self.view.window)
    {
        if ((self.topCircle.animation) || (self.topCircle.duration < 0))
        {
            [self saveCircle];
        }
    }
    [[TaskStore sharedStore] saveChanges];
}

- (void)applicationWillTerminate
{
    TaskData *currentTask = self.tasks[self.topCircle.buttonTag];
    if (currentTask.isPlaying)
    {
        [self loadCircle];
        currentTask.isPlaying = !currentTask.isPlaying;
    }
    [[TaskStore sharedStore] saveChanges];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TaskData *detail = self.tasks[indexPath.row];
        DayOfWork *lastRecordedDay = [detail.timeCompleted lastObject];
        [self addBlankDays:lastRecordedDay fromData:detail];
        
        DetailViewController *controller = [segue destinationViewController];
        controller.detailItem = detail;
        controller.currentDate = self.currentDate;
        controller.currentDateComponents = self.currentComponents;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    [self viewwillAppear:YES];
}


#pragma mark - Table View Header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.topCircle)
    {
        // Create circle
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGRect circRect = CGRectMake(0, 0, width, 275);
        self.topCircle = [[CircleView alloc]initWithFrame:circRect];
        self.topCircle.delegate = self;
        
        // Make timer clickable
        UITapGestureRecognizer *clickable = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timerClicked)];
        [self.topCircle.timerLabel setUserInteractionEnabled:YES];
        [self.topCircle.timerLabel addGestureRecognizer:clickable];
        
        
    }
    return self.topCircle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 350;
}

#pragma Circle Animation Parameters

- (void)buttonClicked:(int)row
{
    TaskData *task = self.tasks[row];
    self.topCircle.tagNumber = (row + 1);
    self.topCircle.nameLabel.text = @"Daily Goal";
    
    if (task.isGoodHabit)
    {
        self.topCircle.greenCircle.strokeColor = [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1].CGColor;
    }
    else
    {
        self.topCircle.greenCircle.strokeColor = [UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1].CGColor;
    }
    
    // Set initial dailyremaining if new task
    if (!task.dailyRemainingDuration)
    {
        task.dailyRemainingDuration = (task.remainingDuration / task.daysRemaining);
    }
    // Set circle duration to original task data duration
    self.topCircle.duration = task.dailyRemainingDuration;
    
    // Set circle start point to saved cell value (see saveCircle)
    self.topCircle.fromValue = task.resumeFromValue;
    
    // Set task text
    //self.topCircle.taskLabel.text = task.taskDataName;
    self.title = task.taskDataName;
    
    // If new task is clicked
    if (!(self.topCircle.buttonTag == row))
    {
        TaskData *oldTask = self.tasks[self.topCircle.buttonTag];
        // And old task had been played
        if ((self.topCircle.animation) || (oldTask.dailyRemainingDuration < 0))
        {
            // Nill animation and if playing, pause and save time
            if (oldTask.isPlaying)
            {
                [self saveCircle];
                if (self.timer)
                {
                    [self.timer invalidate];
                    self.timer = nil;
                }
                oldTask.isPlaying = !oldTask.isPlaying;
            }
            
            self.topCircle.buttonTag = row;
            
            // Fill circle view with new task values
            self.topCircle.duration = task.dailyRemainingDuration;
            self.topCircle.fromValue = task.resumeFromValue;
            [self buttonClicked:row];
            if (oldTask.dailyRemainingDuration < 0)
            {
                [self.topCircle pauseLayer:self.topCircle.greenCircle];
            }
            [self buttonClicked:row];
        }
        else
        {
            self.topCircle.buttonTag = row;
        }
        
    }
    
    
    // Save bool to determine if animation was paused when leaving view
    task.isPlaying = !task.isPlaying;
    
    if (task.dailyRemainingDuration > 0)
    {
        [self.topCircle didTapPlayPauseButton];
    }
    
    else
    {
        [CATransaction setDisableActions:YES];
        [self.topCircle.greenCircle removeAllAnimations];
        self.topCircle.greenCircle.strokeEnd = 1;
        if (task.isPlaying)
        {
            [self.topCircle continueFinishedTime];
        }
        else
        {
            [self.topCircle pauseFinishedTime];
        }
        
    }
    
    // Must save when pausing, so that when leaving view during play, old data is already stored
    if (!task.isPlaying)
    {
        if (self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        [self saveCircle];
        [self loadCircle];
    }
    // Start NSTimer to update percent complete
    else
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(updatePercent:)
                                                    userInfo:@(row)
                                                     repeats:YES];
    }
    if (task.isGoodHabit)
    {
        [self.topCircle.timerLabel setTextColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1]];
        [self.topCircle.nameLabel setTextColor: [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1]];
    }
    else
    {
        [self.topCircle.timerLabel setTextColor:[UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1]];
        self.topCircle.nameLabel.text = @"Daily Limit";
        [self.topCircle.nameLabel setTextColor:[UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1]];
    }
    
}

- (void)updatePercent:(NSTimer*)sender
{
    [self saveCircle];
    long tag = [sender.userInfo integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [self loadCircle];
}

- (void)timerClicked
{
    if (self.topCircle.tagNumber)
    {
        UIButton *timerButton = [[UIButton alloc] init];
        timerButton.tag = (self.topCircle.tagNumber - 1);
        int newTimerButton = (int)timerButton.tag;
        [self buttonClicked:newTimerButton];
    }
}

#pragma mark - saving/loading
- (void)saveCircle
{
    
    
    // Use two different timing methods to calculate time difference (due to the fact that in one situation, the layer time will reset
    TaskData *currentTask = self.tasks[self.topCircle.buttonTag];
    if (currentTask.isPlaying)
    {
        self.loadStartTime = [[NSDate date] timeIntervalSince1970];
        
        
        [self recordSaveLoadEnd:self.loadStartTime start:self.topCircle.loadingStartTime];
    }
    else
    {
        [self recordSaveLoadEnd:self.topCircle.savingPauseTime start:self.topCircle.loadingStartTime];
    }
}

- (void)loadCircle
{
    TaskData *currentTask = self.tasks[self.topCircle.buttonTag];
    if (currentTask.isPlaying)
    {
        self.loadEndTime = [[NSDate date]timeIntervalSince1970];
        [self recordSaveLoadEnd:self.loadEndTime start:self.loadStartTime];
        
        if (currentTask.dailyRemainingDuration > 0)
        {
            [self.topCircle didTapPlayPauseButton];
        }
        else
        {
            [self.topCircle continueFinishedTime];
        }
        
    }
    else
    {
        if (currentTask.dailyRemainingDuration > 0)
        {
            [self.topCircle didTapPlayPauseButton];
            [self.topCircle pauseLayer:self.topCircle.greenCircle];
        }
        else
        {
            [self.topCircle continueFinishedTime];
            [self.topCircle pauseFinishedTime];
        }
    }
    
    if (currentTask.isGoodHabit)
    {
        [self.topCircle.timerLabel setTextColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1]];
    }
    else
    {
        [self.topCircle.timerLabel setTextColor:[UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1]];
    }
    
    
    
}

- (void)recordSaveLoadEnd:(CFTimeInterval)endTime start:(CFTimeInterval)startTime
{
    TaskData *task = self.tasks[self.topCircle.buttonTag];
    
    
    // Calculate the arc of the circle already filled (based on time)
    task.stackingTime = task.stackingTime + (endTime - startTime);
    
    // Subtract from duration so animation duration remains constant no matter when it starts
    task.remainingDuration = task.remainingDuration - (endTime - startTime);
    task.dailyRemainingDuration = task.dailyRemainingDuration - (endTime - startTime);
    
    // Calculation used to determine where to start animation
    task.resumeFromValue = (task.stackingTime / (task.dailyRemainingDuration + task.stackingTime));
    
    
    // Set new values for CircleView
    self.topCircle.duration = task.dailyRemainingDuration;
    self.topCircle.fromValue = task.resumeFromValue;
    
    
    // Save time completed to TaskData
    DayOfWork *currentDay = [task.timeCompleted lastObject];
    
    if ([currentDay.dayComponent day] != [self.currentComponents day])
    {
        [self addBlankDays:currentDay fromData:task];
        currentDay = [task.timeCompleted lastObject];
    }
    currentDay.dayTimeCompleted = currentDay.dayTimeCompleted + (endTime - startTime);
    self.topCircle.animation = nil;
    [CATransaction setDisableActions:YES];
    self.topCircle.greenCircle.strokeEnd = 0.0;
    
}

- (void)addBlankDays:(DayOfWork *)lastRecordedDay fromData:(TaskData *)data
{
    if (lastRecordedDay.date)
    {
        // Add days since last recorded day with 0 time completed
        
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:lastRecordedDay.date];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:self.currentDate];
        
        NSDateComponents *difference = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                       fromDate:fromDate
                                                                         toDate:toDate
                                                                        options:0];
        
        NSDate *nextDate;
        NSDateComponents *nextComponents;
        NSDateComponents *addDayComponent = [[NSDateComponents alloc]init];
        
        for (int i = 0; i < difference.day; i++)
        {
            addDayComponent.day = i + 1;
            nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:addDayComponent
                                                                     toDate:lastRecordedDay.date
                                                                    options:0];
            nextComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:nextDate];
            
            DayOfWork *currentDay = [[DayOfWork alloc]initWithDate:nextDate
                                                         Component:nextComponents
                                                     timeCompleted:0];
            
            [data.timeCompleted addObject:currentDay];
        }
    }
}

#pragma mark - Table View Setup

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[TaskStore sharedStore]allTasks]count];
}

#pragma mark - Edit Table View Cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    if (!cell)
    {
        cell = [[TaskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"taskCell"];
    }
    
    
    self.tasks = [[TaskStore sharedStore]allTasks];
    TaskData *task = self.tasks[indexPath.row];
    [cell cellSetup:task withDate:self.currentDate andComponents:self.currentComponents];
    
    // In taskdata, add properties for date/component in order to keep track every day, therefore I can limit entering
    // into this switch to the first time of the day. This will also allow me to update daily time needed
    
    // Check to see if new day/week/month has begun, reset everything and set new start date/components

    [cell.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.playButton.tag = indexPath.row;
    return cell;
}

- (void)playButtonClicked:(UIButton *)sender
{
    [self buttonClicked:sender.tag];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Edit Table View
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL restartTimer = NO;
        long tag = [self.timer.userInfo integerValue];
        if (self.timer)
        {
            if (tag >= indexPath.row)
            {
                [self.timer invalidate];
                self.timer = nil;
            }
            if (tag > indexPath.row)
            {
                restartTimer = YES;
            }
            
        }
        TaskData *taskRemove = self.tasks[indexPath.row];
        [[TaskStore sharedStore] deleteTask:taskRemove];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (indexPath.row == self.topCircle.buttonTag)
        {
            self.topCircle = nil;
        }
        else if (self.topCircle.buttonTag > indexPath.row)
        {
            self.topCircle.buttonTag = self.topCircle.buttonTag - 1;
            
            // Keep separate tag number for clickable timer (due to issue of 0 being nil and need to check for nil)
            self.topCircle.tagNumber = self.topCircle.tagNumber - 1;
        }
        self.tasks = [[TaskStore sharedStore]allTasks];
        [tableView reloadData];
        if (restartTimer)
        {
            tag = tag - 1;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                          target:self
                                                        selector:@selector(updatePercent:)
                                                        userInfo:@(tag)
                                                         repeats:YES];
        }
    }
}

@end
