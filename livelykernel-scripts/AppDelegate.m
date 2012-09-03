//
//  AppDelegate.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupStatusItem];
    [storageController loadData];
    [loginController setupAutoStartup];
    
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserver:self selector:@selector(serverStateChanged:) name:@"LKServerState"object:nil];
    [noteCenter addObserver:self selector:@selector(showScriptOutput:) name:@"LKScriptOutput"object:nil];
    
    [lkScriptsController startServerWatcher];
    [lkScriptsController fetchServerStatus];
}

- (void)awakeFromNib {
    [scriptOutputWindow setReleasedWhenClosed: NO]; // we want to reuse it later
    storageController = [[StorageController alloc] init];
    loginController.storageController = storageController;
    firstServerStateChanged = YES;
}

-(void) serverStateChanged:(NSNotification*)note {
    BOOL isAlive = lkScriptsController.isServerAlive;
    if (firstServerStateChanged) {
        firstServerStateChanged = false;
        if (!isAlive) {
            NSLog(@"starting server in startup phase");
            [lkScriptsController startOrStopServer:self];
            return;
        }
    }
    NSString* imageNamePart = isAlive ? @"lk-running" : @"lk-not-running";
    NSString* imageName = [[NSBundle mainBundle] pathForResource:imageNamePart ofType:@"png"];
    NSImage* lkStatusImage = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage: lkStatusImage];
    [startStopMenuItem setTitle: (isAlive ? @"Stop server" : @"Start server")];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app {
    if (lkScriptsController.isServerAlive) {
        [lkScriptsController stopServerThenDo: ^ {
            NSLog(@"shutdown complete...");
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
}

-(void) showScriptOutput:(NSNotification*)note {
    NSString* string = [note object];
    if (![scriptOutputWindow isVisible]){
        [scriptOutputWindow makeKeyAndOrderFront: nil];
    }
    NSMutableString *content = [[scriptText textStorage] mutableString];
    [content appendString: string];
    if (![string hasSuffix:@"\n"]) {
        [content appendString: @"\n"];
    }
    [scriptText setTextColor:[NSColor whiteColor]];
}

- (void) inform:msg {
    NSAlert *alert = [[NSAlert new] init];
    [alert setMessageText:msg];
    [alert runModal];
}

@end
