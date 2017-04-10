//
//  AddTaskViewController.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "AddTaskViewController.h"
#import "TaskData.h"
#import "TaskStore.h"

@interface AddTaskViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addName;
@property (weak, nonatomic) IBOutlet UIButton *goalButton;
@property (weak, nonatomic) IBOutlet UIButton *limitButton;
@property (strong, nonatomic)  UIPickerView *dateTimePicker;
@property (nonatomic) NSMutableArray *stringInt;
@property (nonatomic) NSArray *timeArray;
@property (nonatomic) NSArray *dayArray;
@property (nonatomic) BOOL isGoal;
@property (nonatomic) BOOL buttonSelected;


@property CFTimeInterval timeSecs;

- (IBAction)editingChange:(id)sender;
//- (void)valueChange;
- (void)goalSelected;
- (void)limitSelected;
- (void)dismissKeyboard;

@end

@implementation AddTaskViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Nav Control Initialization
    
    self.stringInt = [[NSMutableArray alloc]init];
    for (int i = 0; i < 121; i++)
    {
        [self.stringInt addObject:[NSString stringWithFormat:@"%i", i]];
    }
    self.timeArray = @[ @"minute(s)", @"hour(s)"];
    self.dayArray = @[ @"per day", @"per week", @"per month"];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect pickerRect = CGRectMake(0, 230, width, 216);
    self.dateTimePicker = [[UIPickerView alloc]initWithFrame:pickerRect];
    // self.dateTimePicker.backgroundColor = [UIColor whiteColor];
    
    /*  NSLayoutConstraint *topConstraint = [NSLayoutConstraint
     constraintWithItem:self.dateTimePicker
     attribute:NSLayoutAttributeTop
     relatedBy:NSLayoutRelationEqual
     toItem:self.limitButton
     attribute:NSLayoutAttributeBottom
     multiplier:1.0
     constant:8];
     
     NSLayoutConstraint *leftConstraint =[NSLayoutConstraint constraintWithItem:self.dateTimePicker
     attribute:NSLayoutAttributeTrailing
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeRightMargin
     multiplier:1
     constant:0];
     
     NSLayoutConstraint *rightConstraint =[NSLayoutConstraint constraintWithItem:self.dateTimePicker
     attribute:NSLayoutAttributeLeading
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeLeftMargin
     multiplier:1
     constant:0];
     
     [self.view addConstraint:topConstraint];
     [self.view addConstraint:leftConstraint];
     [self.view addConstraint:rightConstraint];*/
    [self.view addSubview:self.dateTimePicker];
    [self.dateTimePicker setDataSource:self];
    [self.dateTimePicker setDelegate:self];
    
    self.title = @"New Task";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPage:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    cancelButton.tintColor = [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addNewTask:)];
    addButton.tintColor = [UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    CGRect frameRect = self.addName.frame;
    frameRect.size.height = 130;
    self.addName.frame = frameRect;
    [self.addName becomeFirstResponder];
    self.goalButton.layer.cornerRadius = 16.0;
    [self.goalButton addTarget:self action:@selector(goalSelected) forControlEvents:UIControlEventTouchDown];
    [self.limitButton addTarget:self action:@selector(limitSelected) forControlEvents:UIControlEventTouchDown];
    self.limitButton.layer.cornerRadius = 16.0;
    self.buttonSelected = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self.goalButton addGestureRecognizer:tap];
    [self.limitButton addGestureRecognizer:tap];
    [self.dateTimePicker addGestureRecognizer:tap];
    
    
    
    //self.taskInformation.text = @"Daily goals reset every day.";
    
    //[self.taskType addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initializing Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return 121;
            break;
            
        case 1:
            return 2;
            break;
            
        case 2:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    switch (component)
    {
        case 0:
        {
            return self.stringInt[row];
            break;
        }
        case 1:
        {
            return self.timeArray[row];
            break;
        }
        case 2:
        {
            return self.dayArray[row];
            break;
        }
        default:
            return @"";
            break;
    }
}

#pragma mark Prepare keyboard behavior

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.addName resignFirstResponder];
    return YES;
}

- (void) dismissKeyboard
{
    [self.addName resignFirstResponder];
}


#pragma mark - Navigation bar buttons

- (void)cancelPage:(id)sender
{
    [self.addName resignFirstResponder];
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"unwindCancel" sender:sender];
}

- (TaskData *)addNewTask:(id)sender
{
    [self.addName resignFirstResponder];
    NSInteger row = [self.dateTimePicker selectedRowInComponent:0];
    NSString *timeString = [self pickerView:self.dateTimePicker titleForRow:row forComponent:0];
    self.timeSecs = [timeString doubleValue];
    if ([self.dateTimePicker selectedRowInComponent:1] == 0)
    {
        self.timeSecs = self.timeSecs * 60.0;
    }
    else
    {
        self.timeSecs = self.timeSecs * 60.0 * 60.0;
    }
    
    NSDate *currentDate= [NSDate date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:currentDate];
    
    DayOfWork *currentDay = [[DayOfWork alloc]initWithDate:currentDate
                                                 Component:currentComponents
                                             timeCompleted:0];
    
    // Dynamically set initial goal time to offset for when it was created
    double remainingDuration;
    double initialTime;
    if ([self.dateTimePicker selectedRowInComponent:2] == 0)
    {
        remainingDuration = self.timeSecs;
        initialTime = self.timeSecs;
    }
    else if ([self.dateTimePicker selectedRowInComponent:2] == 1)
    {
        double daysRemaining = 8 - [currentComponents weekday];
        remainingDuration = (self.timeSecs * (daysRemaining / 7));
        initialTime = (self.timeSecs * (daysRemaining / 7));
    }
    else
    {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentDate];
        double numberOfDaysInMonth = rng.length;
        double daysRemaining = numberOfDaysInMonth - [currentComponents day] + 1;
        remainingDuration = (self.timeSecs * (daysRemaining / numberOfDaysInMonth));
        initialTime = (self.timeSecs * (daysRemaining / numberOfDaysInMonth));
    }
    
    TaskData *newTask = [[TaskData alloc]initWithName:self.addName.text initialTime:initialTime finalTime:self.timeSecs initialDuration:remainingDuration type:[self.dateTimePicker selectedRowInComponent:2]];
    
    
    newTask.isGoodHabit = self.isGoal;
    
    
    [newTask.timeCompleted addObject:currentDay];
    
    [[TaskStore sharedStore] createTaskWithItem:newTask];
    [self performSegueWithIdentifier:@"unwindAdd" sender:sender];
    //[self dismissViewControllerAnimated:YES completion:nil];
    return newTask;
}

- (void)goalSelected
{
    [self dismissKeyboard];
    self.isGoal = YES;
    self.buttonSelected = YES;
    [self.goalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goalButton setBackgroundColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1]];
    
    [self.limitButton setBackgroundColor:[UIColor whiteColor]];
    [self.limitButton setTitleColor:[UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1] forState:UIControlStateNormal];
    [self editingChange:(self)];
}

- (void)limitSelected
{
    [self dismissKeyboard];
    self.isGoal = NO;
    self.buttonSelected = YES;
    [self.limitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.limitButton setBackgroundColor: [UIColor colorWithRed:1 green:(59/255) blue:(48/255) alpha:1]];
    
    [self.goalButton setBackgroundColor: [UIColor whiteColor]];
    [self.goalButton setTitleColor:[UIColor colorWithRed:.29804 green:.8510 blue:.3922 alpha:1] forState:UIControlStateNormal];
    [self editingChange:self];
}

#pragma mark - Editing Text Fields
- (IBAction)editingChange:(id)sender
{
    if ((self.addName.text.length != 0) && (self.buttonSelected == YES))
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

/*- (void)valueChange
 {
 
 if (self.taskType.selectedSegmentIndex == 0)
 {
 self.taskInformation.text = @"Daily goals reset every day.";
 }
 else if (self.taskType.selectedSegmentIndex == 1)
 {
 self.taskInformation.text = @"Resets every Sunday. New tasks created midweek automatically account for previous days of the week";
 }
 else
 {
 self.taskInformation.text = @"Resets on the first of the month. New tasks created mid-month automatically account for previous days of the month";
 }
 }*/

@end
