//
//  StartAtLoginManager.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/29/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartAtLoginManager : NSObject
+ (BOOL) willStartAtLogin:(NSURL *)itemURL;
+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;
@end
