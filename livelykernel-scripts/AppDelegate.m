//
//  AppDelegate.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    theApp = [aNotification object];
}

- (void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];
}

- (IBAction)openSettingsWindow:(id)sender {
    [theApp activateIgnoringOtherApps:true];
    [settingsWindow makeKeyAndOrderFront:nil];
    [settingsWindow makeMainWindow];

//    [settingsWindow ]
    
}

- (IBAction)isWindowVisible:(id)sender {
    NSAlert *alert = [[NSAlert new] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete the record?"];
    NSString *msg = [settingsWindow isVisible] ? @"yep" : @"nop";
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // OK clicked, delete the record
        //[self deleteRecord:currentRec];
    }
}

@end
