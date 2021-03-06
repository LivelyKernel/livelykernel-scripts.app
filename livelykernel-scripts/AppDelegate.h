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
#import "LKScriptsController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BOOL firstServerStateChanged;
    StorageController *storageController;
    IBOutlet StartAtLoginManager *loginController;
    IBOutlet LKScriptsController *lkScriptsController;
    
    NSStatusItem *statusItem;
    IBOutlet NSMenuItem *startStopMenuItem;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSWindow *scriptOutputWindow;
    IBOutlet NSTextView *scriptText;

}
-(void) inform:msg;
@end
