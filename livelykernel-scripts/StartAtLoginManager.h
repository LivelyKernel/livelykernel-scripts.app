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

- (id)initWithStorage:(StorageController*)storage;
- (void) setupAutoStartup;
- (IBAction)updateStartAtLogin:(id)sender;

@property StorageController *storage;
@property BOOL startAtLogin;

@end
