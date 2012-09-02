//
//  LKScriptsController.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandLineInterface.h"

@interface LKScriptsController : NSObject {
    NSTimer *serverWatchLoop;
//    NSURL *lkRepositoryLocation;
}

- (void) startServerWatcher;
- (void) fetchServerStatus;
- (IBAction) startOrStopServer:(id)sender;
- (void) stopServerThenDo:(void (^)())block;
- (void) startServerThenDo:(void (^)())block;
- (void) startOrStopServerThenDo:(void (^)())block;

@property (readonly) BOOL isServerAlive;
@end
