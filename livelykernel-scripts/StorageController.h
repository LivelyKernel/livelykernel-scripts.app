//
//  StorageController.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageController : NSObject
- (void) saveData;
- (void) loadData;

@property NSMutableDictionary *data;
@property BOOL loadAtStartup;
@property (readonly) BOOL isFirstStart;

@end
