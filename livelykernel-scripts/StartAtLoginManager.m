//
//  StartAtLoginManager.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/29/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "StartAtLoginManager.h"

@implementation StartAtLoginManager

@synthesize storage;

-(id)initWithStorage:(StorageController*)storageRef {
    self = [self init];
    [self setStorage: storageRef];
    return self;
}

-(void) setupAutoStartup {
    if ([storage isFirstStart]) {
        NSLog(@"Starting for the first time, enabling start at login");
        [self setStartAtLogin:YES];
    } else {
        [startAtLoginMenuItem setState: [self startAtLogin] ? NSOnState : NSOffState];
    }
}

- (IBAction)updateStartAtLogin:(id)sender {
    [self setStartAtLogin:![self startAtLogin]];
}

- (NSURL *) appURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}


- (BOOL) startAtLogin {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    return [self willStartAtLogin:url];
}

- (void) setStartAtLogin:(BOOL)startAtLogin {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self setStartAtLogin:url enabled:startAtLogin];
    [storage setLoadAtStartup: startAtLogin];
    [startAtLoginMenuItem setState: [self startAtLogin] ? NSOnState : NSOffState];
}

- (BOOL) willStartAtLogin:(NSURL *)itemURL {
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seed);
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, (__bridge CFURLRef) itemURL);
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

- (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled {
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seed);
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, (__bridge CFURLRef) itemURL);
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
            
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
        
        CFRelease(loginItems);
    }       
}

@end
