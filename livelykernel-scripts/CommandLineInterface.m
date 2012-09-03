//
//  CommandLineInterface.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "CommandLineInterface.h"

@implementation CommandLineInterface

- (void) runCmd:(NSString*)cmd {
    NSTask *task = [self cmdTask:cmd];
    [task launch];
}

- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString *stdoutCombined))doneBlock {
    [self runCmd:cmd onOutput:outputBlock whenDone:doneBlock isSync:false];
}

- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString*))doneBlock isSync:(BOOL)isSync {
    // Creates a task for command to execute it and attaches a filehandle to
    // stdout. Then runs the task and invokes the outputBlock when stdout data
    // arrives
    // note: since both the task itself and the read process are asynchronous,
    // reaching task terminate does not mean that all data is read!
    __block NSFileHandle *file;
    __block id observer;
    __block NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __block BOOL taskTerminated = NO;
    __block BOOL endOfFileReached = NO;
    __block NSString *stdoutCombined = @"";
    NSLog(@"running %@ cmd: %@", isSync ? @"sync" : @"async", cmd);

    //////////////////////////////////////
    // deal with what comes from stdout //
    //////////////////////////////////////
    void (^readDataBlock) (NSData *) = ^ (NSData *data) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"out: %@ (%@)", cmd, string);
        if (outputBlock) outputBlock(string);
        stdoutCombined = [stdoutCombined stringByAppendingString: string];
    };

    /////////////////////////////////////////////////////
    // if we are async we use an observer to read data //
    /////////////////////////////////////////////////////
    if (!isSync) {
        void (^responseBlock)(NSNotification*) = ^(NSNotification *note) {
            // mutliple commands can run concurrently, to make sure that
            // the notification is meant for us we need to compare the file
            // handlers from note and our context
            NSFileHandle *notificationFile = [note object];
            if (![notificationFile isEqual:file]) return;
            NSData *data = [[note userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
            if ([data length] == 0) {
                [center removeObserver:observer];
                endOfFileReached = YES;
                if (taskTerminated) doneBlock(stdoutCombined);
            }
            readDataBlock(data);
            [file readInBackgroundAndNotify];
        };
        observer = [center addObserverForName:NSFileHandleReadCompletionNotification
                                       object:nil
                                        queue:[NSOperationQueue mainQueue]
                                   usingBlock:responseBlock];
    }

    ////////////////////////////////////
    // attach reader to task's stdout //
    ////////////////////////////////////
    void (^setupTask)(NSTask*) = ^ (NSTask* task) {
//        NSLog(@"setup: %@", cmd);
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        //The magic line that keeps your log where it belongs
        [task setStandardInput:[NSPipe pipe]];
        file = [pipe fileHandleForReading];
        if (!isSync) [file readInBackgroundAndNotify];
    };

    ////////////////////////////////////////////////////////////
    // clean things up when tasks terminates + call doneBlock //
    ////////////////////////////////////////////////////////////
    void (^onTaskTermination)() = ^ {
//        NSLog(@"end: %@", cmd);
        taskTerminated = YES;
        if (endOfFileReached) doneBlock(stdoutCombined);
    };

    //////////////////////////
    // now start the things //
    //////////////////////////
    [self setupTask:setupTask runCmd:cmd whenDone:onTaskTermination];
    
    //////////////////////////////////////////////////////////
    // in case we want to wait do reading data here and now //
    //////////////////////////////////////////////////////////
    if (isSync) {
        NSData *data = [file readDataToEndOfFile];
        readDataBlock(data);
        endOfFileReached = YES;
        if (taskTerminated) doneBlock(stdoutCombined);
        NSLog(@"sync end cmd: %@ (%@)", cmd, stdoutCombined);
    }
}

- (void) setupTask:(void(^)(NSTask*))setupTaskBlock runCmd:(NSString*)cmd whenDone:(void(^)())doneBlock {
    NSTask *task = [self cmdTask:cmd];
    if (setupTaskBlock) { setupTaskBlock(task); }
    if (doneBlock) { task.terminationHandler = ^(NSTask *task) { doneBlock(); }; }
    [task launch];
}

- (NSTask*) cmdTask:(NSString*)cmd {
    // starts a bash asynchronously and passes cmd to it
    NSString *realCmd = @"/bin/bash";
    NSArray *arguments = [NSArray arrayWithObjects: @"--login", @"-c", cmd, nil];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: realCmd];
    [task setArguments: arguments];
    return task;
}

@end
