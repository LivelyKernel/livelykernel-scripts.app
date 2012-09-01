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
    [scriptOutputWindow setReleasedWhenClosed: NO]; // we want to reuse it later
    storageController = [[StorageController alloc] init];
    [storageController loadData];
//    loginController.storageController = storageController;
    [loginController setupAutoStartup];
    [self setupStatusItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverStateChanged:)
                                                 name:@"LKServerState"object:nil];
    [lkScriptsController startServerWatcher];
    
//    if (![lkScriptsController isServerAlive]) {
//        [lkScriptsController startOrStopServer:nil thenDo: nil];
//    }
    
//    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
//    for (NSRunningApplication *app in running) {
//        NSLog([app bundleIdentifier]);
//    }
}

-(void) serverStateChanged:(NSNotification*)note {
    BOOL isAlive = lkScriptsController.isServerAlive;
    NSLog(@"serverStateChanged alive? %@", isAlive ? @"yes" : @"not");
    
    NSString* imageNamePart = isAlive ? @"lk-running" : @"lk-not-running";
    NSString* imageName = [[NSBundle mainBundle] pathForResource:imageNamePart ofType:@"png"];
    NSImage* lkStatusImage = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage: lkStatusImage];
    [startStopMenuItem setTitle: (isAlive ? @"Stop server" : @"Start server")];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {
    if (lkScriptsController.isServerAlive) {
        [lkScriptsController startOrStopServer:nil thenDo: ^ {
            [app replyToApplicationShouldTerminate: YES];
        }];
        
        return NSTerminateLater;
    }
    return NSTerminateNow;
}

- (void) setupStatusItem {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [self serverStateChanged: nil];
}

-(void) showInHUD:(NSString*)string {
    if (![scriptOutputWindow isVisible]){
        [scriptOutputWindow makeKeyAndOrderFront: nil];
    }
    [scriptText setTextColor:[NSColor whiteColor]];
    [[[scriptText textStorage] mutableString] appendString: string];
}

- (void) inform:msg {
    NSAlert *alert = [[NSAlert new] init];
    [alert setMessageText:msg];
    [alert runModal];
}

@end
