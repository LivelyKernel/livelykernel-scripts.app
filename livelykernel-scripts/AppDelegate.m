//
//  AppDelegate.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib {
    storageController = [[StorageController alloc] init];
    [storageController loadData];
    loginController = [[StartAtLoginManager alloc] initWithStorage:storageController];
    [loginController setupAutoStartup];
    lkScriptsController = [[LKScriptsController alloc] initWithStatusItem: [self setupStatusItem]];
    if (![lkScriptsController isServerAlive]) {
        [lkScriptsController startOrStopServer:nil];
    }
    
//    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
//    for (NSRunningApplication *app in running) {
//        NSLog([app bundleIdentifier]);
//    }
}

-(void)applicationWillTerminate:(NSNotification *)notification {
   if ([lkScriptsController isServerAlive]) {
       // [self startOrStopServer:nil];
   }
}

- (NSStatusItem *) setupStatusItem {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    return statusItem;
}

- (void) inform:msg {
    NSAlert *alert = [[NSAlert new] init];
    [alert setMessageText:msg];
    [alert runModal];
}

@end
