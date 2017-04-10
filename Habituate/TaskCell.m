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

@end
