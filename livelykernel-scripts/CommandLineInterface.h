//
//  CommandLineInterface.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandLineInterface : NSObject
- (void) runCmd:(NSString*)cmd;
- (NSTask*) cmdTask:(NSString*)cmd;
- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString *stdoutCombined))doneBlock;
- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString *stdoutCombined))doneBlock isSync:(BOOL)isSync;
@end
