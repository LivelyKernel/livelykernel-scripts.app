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

- (id) initWithStatusItem:(NSStatusItem*)appStatusItem;
- (void) updateFromServerStatus;
- (IBAction) startOrStopServer:(id)sender thenDo:(void (^)())block;

@property (readonly) BOOL isServerAlive;
@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) NSMenuItem *startStopMenuItem;
@property (nonatomic) NSMenu *statusMenu;
@property (nonatomic) NSWindow *scriptOutputWindow;
@property (nonatomic) NSTextView *scriptText;

@end
