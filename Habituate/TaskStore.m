//
//  TaskStore.m
//  Habituate
//
//  Created by Mikael Olezeski on 4/3/17.
//  Copyright © 2017 Mikael Olezeski. All rights reserved.
//

#import "TaskStore.h"

#import "TaskData.h"

@interface TaskStore ()

@property (nonatomic) NSMutableArray *privateTasks;

@end

@implementation TaskStore

#pragma mark - Initializers

+ (instancetype)sharedStore;
{
    static TaskStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[self alloc]initPrivate];
    }
    return sharedStore;
}


// Throw error if user tries to initialize taskStore
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[BNRItemStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
        NSString *path = [self itemArchivePath];
        self.privateTasks  = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the array hadn't been saved previously, create a new empty one
        if (!self.privateTasks)
        {
            self.privateTasks = [[NSMutableArray alloc]init];
        }
    }
    return self;
}

#pragma mark - Item Creation/Deletion

- (NSArray *)allTasks
{
    return self.privateTasks;
}

- (void)createTaskWithItem:(TaskData *)task
{
    [self.privateTasks addObject:task];
}

- (void)deleteTask:(TaskData *)taskRemove
{
    [self.privateTasks removeObjectIdenticalTo:taskRemove];
}

// To access archived files
- (NSString *)itemArchivePath
{
    // Find the document directory list
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
    // Get the one document directory from that list
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    // Returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.privateTasks
                                       toFile:path];
}
@end







