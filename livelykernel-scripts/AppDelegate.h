//
//  AppDelegate.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <stdlib.h> // for setenv

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSTimer *serverWatchLoop;
    NSStatusItem *statusItem;
    NSURL *lkRepositoryLocation;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem *startStopMenuItem;
    Boolean isServerAlive;
    
    IBOutlet NSWindow *scriptOutputWindow;
    IBOutlet NSTextView *scriptText;
}
-(void) inform:msg;
@end
