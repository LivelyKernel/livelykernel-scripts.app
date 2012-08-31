//
//  StorageController.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "StorageController.h"

@implementation StorageController

- (NSString *) pathForDataFile {
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSString *folder = @"~/Library/Application Support/livelykernel-scripts-macos/";
  folder = [folder stringByExpandingTildeInPath];

  if ([fileManager fileExistsAtPath: folder] == NO) {
    [fileManager createDirectoryAtPath: folder attributes: nil];
  }

  NSString *fileName = @"app-settings.data";
  return [folder stringByAppendingPathComponent: fileName];
}

- (void) saveData {
    NSString *path = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject: [self data] toFile: path];
}

- (void) loadData {
  NSString *path = [self pathForDataFile];
  [self setData: [NSKeyedUnarchiver unarchiveObjectWithFile:path]];
  // [self setMailboxes: [rootObject valueForKey:@"mailboxes"]];
}

// properties

@synthesize data;

- (BOOL) loadAtStartup {
  return (BOOL)[[self data] valueForKey: @"loadAtStartup"];
}

- (void) setLoadAtStartup:(BOOL)shouldLoadAtStartup {
  [[self data] setValue: [NSNumber numberWithBool:shouldLoadAtStartup] forKey: @"loadAtStartup"];
  [self saveData];
}

- (BOOL) isFirstStart {
  return !([[NSFileManager defaultManager] fileExistsAtPath: [self pathForDataFile]]);
}

@end
