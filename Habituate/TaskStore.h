//
//  TaskStore.h
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskData;

@interface TaskStore : NSObject

@property (nonatomic, readonly) NSArray *allTasks;

+ (instancetype)sharedStore;
- (void)createTaskWithItem:(TaskData *)task;
- (void)deleteTask:(TaskData *)taskRemove;
- (BOOL)saveChanges;

@end

