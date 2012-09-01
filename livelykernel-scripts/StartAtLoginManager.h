//
//  StartAtLoginManager.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/29/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageController.h"

@interface StartAtLoginManager : NSObject {
    IBOutlet NSMenuItem *startAtLoginMenuItem;
}

- (void) setupAutoStartup;
- (IBAction)toggleStartAtLogin:(id)sender;

@property StorageController *storageController;
@property BOOL startAtLogin;

@end
