//
//  AppDelegate.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSApplication *theApp;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSWindow *settingsWindow;
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@end
