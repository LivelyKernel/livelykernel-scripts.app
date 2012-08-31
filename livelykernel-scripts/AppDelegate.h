//
//  AppDelegate.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <stdlib.h> // for setenv
#import "StartAtLoginManager.h"
#import "StorageController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    StorageController *storageController;
    StartAtLoginManager *loginController;
    NSTimer *serverWatchLoop;
    NSStatusItem *statusItem;
    NSURL *lkRepositoryLocation;
    Boolean isServerAlive;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem *startStopMenuItem;
    IBOutlet NSWindow *scriptOutputWindow;
    IBOutlet NSTextView *scriptText;
}
-(void) inform:msg;
@end
