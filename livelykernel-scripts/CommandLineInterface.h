//
//  CommandLineInterface.h
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandLineInterface : NSObject
- (void) runCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)())doneBlock;
@end
