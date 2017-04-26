//
//  DetailViewController.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;
#import "TaskData.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) TaskData *detailItem;
@property (nonatomic) NSDate *currentDate;
@property (nonatomic) NSDateComponents *currentDateComponents;
//@property (nonatomic) ChartXAxis *xAxis;
//@property (nonatomic) NSMutableArray *xAxisValue;
//@property (nonatomic) long pastFutureDates;
//@property (weak, nonatomic) IBOutlet UIButton *backButton;
//@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
//@property (weak, nonatomic) IBOutlet UILabel *graphTitle;
//
//@property ChartYAxis *leftAxis;
//@property int maxY;
//
//- (IBAction)backButtonClicked:(id)sender;
//- (IBAction)forwardButtonClicked:(id)sender;
//- (void)popController;
//



@end

