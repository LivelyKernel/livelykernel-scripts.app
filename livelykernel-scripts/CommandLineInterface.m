//
//  CommandLineInterface.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "CommandLineInterface.h"

@implementation CommandLineInterface

- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)())doneBlock {
    NSFileHandle *file = [self startCmd:cmd];
    [self observe:file onOutput:outputBlock whenDone:doneBlock];
}

- (void) observe:(NSFileHandle*)file onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)())doneBlock {
    // subscribes to data changes of file handle and triggers outputBlock when data comes in
    // in case it is triggered and no data is available we interpret that as file close. Is this correct?
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id observer;
    void (^responseBlock)(NSNotification*) = ^(NSNotification *note) {
        NSData *data = [[note userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
        if ([data length] == 0) {
            [center removeObserver:observer];
            if (doneBlock) { doneBlock(); }
            return;
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        outputBlock(string);
        [file readInBackgroundAndNotify];
    };
    observer = [center addObserverForName:NSFileHandleReadCompletionNotification
                                   object:nil
                                    queue:mainQueue
                               usingBlock:responseBlock];
    [file readInBackgroundAndNotify];
}

- (NSFileHandle*) startCmd:(NSString*)cmd {
    // starts a bash asynchronously and passes cmd to it
    // returns a file handle to stdout
    NSString *realCmd = @"/bin/bash";
    NSArray *arguments = [NSArray arrayWithObjects: @"--login", @"-c", cmd, nil];
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    [task setLaunchPath: realCmd];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    //The magic line that keeps your log where it belongs
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    return file;
}
@end
