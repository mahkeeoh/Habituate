//
//  TaskCell.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "TaskData.h"

IB_DESIGNABLE

@interface TaskCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *detailText;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (void)cellSetup:(TaskData *)task withDate:(NSDate *)date andComponents:(NSDateComponents *)components;


@end
