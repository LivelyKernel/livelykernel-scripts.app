//
//  SettingsWindowController.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface SettingsWindowController : NSWindowController {
    IBOutlet NSPopUpButton *serverLocationsChooser;
    IBOutlet NSMenuItem *addServerLocationItem;
    IBOutlet NSTableView *infoTable;
    IBOutlet AppDelegate *app;
}

@end
