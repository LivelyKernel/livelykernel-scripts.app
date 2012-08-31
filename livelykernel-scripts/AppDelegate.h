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
    StorageController *storageController;
    StartAtLoginManager *loginController;
    LKScriptsController *lkScriptsController;
    IBOutlet NSMenu *statusMenu;
}
-(void) inform:msg;
@end
