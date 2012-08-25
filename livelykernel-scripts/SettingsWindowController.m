//
//  SettingsWindowController.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "SettingsWindowController.h"

@implementation SettingsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        NSLog(@"initWithWindow");
    }
    
    return self;
}

- (void)showWindow:(id)sender {
    [super showWindow: sender];
    NSLog(@"showWindow");
}

- (void)windowDidLoad
{
    [super windowDidLoad];
 
    NSLog(@"windowDidLoad");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)chooseServerLocation:(id)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ([openDlg runModal] == NSOKButton) {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        NSURL *selection = [files lastObject];
//        [self inform: [selection absoluteString]];
        [serverLocationsChooser insertItemWithTitle:[selection path] atIndex:0];
        [serverLocationsChooser selectItemAtIndex:0];
        [app inform: @"test"];
    }
}

@end
