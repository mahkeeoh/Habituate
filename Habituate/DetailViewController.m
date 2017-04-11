//
//  DetailViewController.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "DetailViewController.h"
//#import "TimeTrack-Swift.h"
#import "DayOfWork.h"



@interface DetailViewController () <ChartViewDelegate, IChartAxisValueFormatter>

@property (weak, nonatomic) IBOutlet LineChartView *lineChart;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
        
        self.pastFutureDates = 0;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup basic chart information
    self.leftAxis = nil;
    self.lineChart.delegate = self;
    self.lineChart.chartDescription = nil;
    [self.lineChart.legend setEnabled:NO];
    self.lineChart.noDataText = @"You need to provide data for the chart.";
    self.lineChart.dragEnabled = YES;
    [self.lineChart setScaleEnabled:YES];
    self.lineChart.pinchZoomEnabled = YES;
    self.lineChart.rightAxis.enabled = NO;
    self.lineChart.drawGridBackgroundEnabled = NO;
    self.title = self.detailItem.taskDataName;
    
    self.graphTitle.text = self.detailItem.taskDataName;

    
    ChartLimitLine *goalLine;
    self.xAxisValue = [[NSMutableArray alloc]init];
    if (self.currentDate && self.currentDateComponents)
    {
        // Will want to check task label and choose x axis as weekly, monthly, yearly
        if (self.detailItem.taskDataType == 2)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMMM, yyyy"];
            self.graphTitle.text = [dateFormatter stringFromDate:self.currentDate];
            NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate];
            NSUInteger numberOfDaysInMonth = rng.length;
            for (NSUInteger i = 0; i < numberOfDaysInMonth; i++)
            {
                [self.xAxisValue addObject:[NSString stringWithFormat:@"%lu", (i+1)]];
            }
            double dailyLimit = (self.detailItem.taskFinalTime / 60 / numberOfDaysInMonth);
            self.maxY = dailyLimit;
            if (self.detailItem.isGoodHabit)
            {
                goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Goal"];
            }
            else
            {
                goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Limit"];
            }
        }
        else
        {
            NSDate *sundayDate = self.currentDate;
            NSDateComponents *Sunday = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:sundayDate];
            sundayDate = [sundayDate dateByAddingTimeInterval:60*60*24*(1 - Sunday.weekday)];
            
            NSDate *saturdayDate = self.currentDate;
            NSDateComponents *Saturday = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:saturdayDate];
            saturdayDate = [saturdayDate dateByAddingTimeInterval:60*60*24*(7 - Saturday.weekday)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM/dd/yy"];
            NSString *stringDate = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:sundayDate], [dateFormatter stringFromDate:saturdayDate]];
            self.graphTitle.text = stringDate;
            self.xAxisValue = [NSMutableArray arrayWithObjects:@"S", @"M", @"T", @"W", @"Th", @"F", @"Sa", nil];
            if (self.detailItem.taskDataType == 0)
            {
                double dailyLimit = (self.detailItem.taskFinalTime / 60);
                self.maxY = dailyLimit;
                if (self.detailItem.isGoodHabit)
                {
                    goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Goal"];
                }
                else
                {
                    goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Limit"];
                }
            }
            else if (self.detailItem.taskDataType == 1)
            {
                double dailyLimit = (self.detailItem.taskFinalTime / 60 / 7);
                self.maxY = dailyLimit;
                if (self.detailItem.isGoodHabit)
                {
                    goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Goal"];
                }
                else
                {
                    goalLine = [[ChartLimitLine alloc] initWithLimit:dailyLimit label:@"Daily Limit"];
                }
            }
        }
    }
    
    
    // Format x axis
    self.xAxis = self.lineChart.xAxis;
    self.xAxis.drawGridLinesEnabled = false;
    self.xAxis.labelFont = [UIFont systemFontOfSize:12];
    self.xAxis.axisLineColor = [UIColor whiteColor];
    self.xAxis.labelTextColor = [UIColor whiteColor];
    self.xAxis.granularityEnabled = YES;
   // self.xAxis.axisMinimum = 0.0;
    self.xAxis.axisMaxValue = self.xAxisValue.count;
    
    NSLog(@"axis max value:%f, axis min value:%f, axisvalue.count: %lu", self.xAxis.axisMaxValue, self.xAxis.axisMinValue, (unsigned long)self.xAxisValue.count);
    
    
    self.xAxis.granularity = 1.0;
    //self.xAxis.decimals = 0;
   // self.xAxis.valueFormatter = self;
    [self.xAxis setLabelPosition:XAxisLabelPositionBottom];

    
    // Format y axis
    self.leftAxis = self.lineChart.leftAxis;
    self.leftAxis.labelTextColor = [UIColor whiteColor];
    self.leftAxis.granularity = 1.0;
    self.leftAxis.labelFont = [UIFont systemFontOfSize:12];
    self.leftAxis.axisLineColor = [UIColor whiteColor];
    self.leftAxis.drawAxisLineEnabled = YES;
    self.leftAxis.drawGridLinesEnabled = NO;
    self.leftAxis.axisMinimum = 0.0;
    goalLine.lineWidth = 1.0;
    goalLine.valueTextColor = [UIColor whiteColor];
    goalLine.lineColor = [UIColor whiteColor];
    [self.leftAxis removeAllLimitLines];
    [self.leftAxis addLimitLine:goalLine];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 1;
   // [self.leftAxis setValueFormatter:formatter];
    self.leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:formatter];
    

    
    
    [self setChartData];
}



- (void)popController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setChartData
{
    
    // For daily/weekly tasks, find first day of current week (sunday). Start for loop of that day and continue through
    
    NSMutableArray *Yval =[[NSMutableArray alloc]init];
    
    DayOfWork *todayWorkObject =  [self.detailItem.timeCompleted lastObject];
    long sizeOfArray = [self.detailItem.timeCompleted count];
    long daysToSubtract;
    if (self.detailItem.taskDataType == 2)
    {
        daysToSubtract = [todayWorkObject.dayComponent day] + self.pastFutureDates;
    }
    
    else
    {
        daysToSubtract = [todayWorkObject.dayComponent weekday] + self.pastFutureDates;
    }
    
    for (int i = 0; i < self.xAxisValue.count; i++)
    {
        
        // get first day of current week and see if there is an object for that
        long arrayIndex = sizeOfArray - daysToSubtract + i;
        
        
        if (arrayIndex >= 0 && arrayIndex < sizeOfArray)
        {
            DayOfWork *currentWorkObject = self.detailItem.timeCompleted[arrayIndex];
            double minutesCompleted = currentWorkObject.dayTimeCompleted / 60;
          //  [Yval addObject:[[ChartDataEntry alloc] initWithValue:minutesCompleted xIndex:i]];
            [Yval addObject:[[ChartDataEntry alloc] initWithX:i y:minutesCompleted]];
            // Find max of array to set points above that
            if (minutesCompleted > self.maxY)
            {
                self.maxY = minutesCompleted;
            }
        }
        else
        {
            //[Yval addObject:[[ChartDataEntry alloc] ini]
             [Yval addObject:[[ChartDataEntry alloc] initWithX:i y:5]];
        }
        

    }
    
 //   self.lineChart.xAxis.valueFormatter = self.xAxis.valueFormatter;
    self.leftAxis.axisMaxValue = (self.maxY + 5);
    
   // LineChartDataSet *set1 = [[LineChartDataSet alloc]initWithYVals:Yval label:@""];
    LineChartDataSet *set1 = [[LineChartDataSet alloc]initWithValues:Yval];
    [set1 setAxisDependency:AxisDependencyLeft];
    [set1 setValueTextColor:[UIColor whiteColor]];
    [set1 setDrawValuesEnabled:YES];
    [set1 setColor:[UIColor whiteColor]];
    [set1 setCircleColor:[UIColor colorWithRed:.29804 green:.99 blue:.3922 alpha:1]];
    [set1 setCircleRadius:8.0];
    [set1 setHighlightColor:[UIColor whiteColor]];
    [set1 setDrawFilledEnabled:YES];
    
    
    
    // Set gradient fade below graph
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#00ffffff"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#6Bffffff"].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    set1.fillAlpha = 1.f;
    set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    
//    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
//    [dataSets addObject:set1];
    
    
   // LineChartData *data = [[LineChartData alloc]initWithXVals:Xvalue dataSets:dataSets];
   // LineChartData *data = [[LineChartData alloc]initWithDataSets:dataSets];
    LineChartData *data = [[LineChartData alloc]initWithDataSet:set1];
    [data setValueTextColor:[UIColor whiteColor]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 1;
  //  [data setValueFormatter:formatter];
    self.lineChart.data = data;
    
    
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase * _Nullable)axis
{
   // return self.xAxisValue[(int)value %self.xAxisValue.count];
    return self.xAxisValue[(int)value - 1];
}

// allow user to go back/forward by time frame (week).
- (IBAction)backButtonClicked:(id)sender
{
    if (self.currentDate && self.currentDateComponents)
    {
        if (self.detailItem.taskDataType == 0 | self.detailItem.taskDataType == 1)
        {
            self.pastFutureDates = self.pastFutureDates + 7;
            
            NSDateComponents *weekComponent = [[NSDateComponents alloc]init];
            [weekComponent setWeekOfYear:-1];
            
            self.currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:weekComponent toDate:self.currentDate options:0];
            self.currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:self.currentDate];
        }
        
        else
        {
            NSDateComponents *monthComponent = [[NSDateComponents alloc]init];
            [monthComponent setMonth:-1];
            
            self.currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:monthComponent toDate:self.currentDate options:0];
            self.currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:self.currentDate];
            
            NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate];
            NSUInteger numberOfDaysInMonth = rng.length;
            self.pastFutureDates = self.pastFutureDates + numberOfDaysInMonth;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        [self viewDidLoad];
    }
}



- (IBAction)forwardButtonClicked:(id)sender
{
    if (self.currentDate && self.currentDateComponents)
    {
        
        if (self.detailItem.taskDataType == 0 | self.detailItem.taskDataType == 1)
        {
            self.pastFutureDates = self.pastFutureDates - 7;
            
            NSDateComponents *weekComponent = [[NSDateComponents alloc]init];
            [weekComponent setWeekOfYear:1];
            
            self.currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:weekComponent toDate:self.currentDate options:0];
            self.currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:self.currentDate];
        }
        
        else
        {
            NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate];
            NSUInteger numberOfDaysInMonth = rng.length;
            self.pastFutureDates = self.pastFutureDates - numberOfDaysInMonth;
            
            NSDateComponents *monthComponent = [[NSDateComponents alloc]init];
            [monthComponent setMonth:1];
            
            self.currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:monthComponent toDate:self.currentDate options:0];
            self.currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYearForWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:self.currentDate];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        
        [self viewDidLoad];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
