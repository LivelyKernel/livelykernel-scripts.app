//
//  livelykernel_scriptsTests.m
//  livelykernel-scriptsTests
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "CommandLineInterfaceTests.h"

@implementation CommandLineInterfaceTests

CommandLineInterface *commandline;

@synthesize signalWaitDone;

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    // see http://stackoverflow.com/questions/2162213/how-to-unit-test-asynchronous-apis
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            STFail(@"timeout");
            break;
        }
    } while (![self signalWaitDone]);
    return [self signalWaitDone];
}

- (void)setUp {
    [super setUp];
    commandline = [[CommandLineInterface alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRunSimpleEcho {
    __block NSString* allout = @"";
    [commandline runCmd:@"echo test"
               onOutput: ^(NSString *stdout) {
                   allout = [allout stringByAppendingString:stdout];
               }
               whenDone: ^ (NSString *combinedOut) {
                   STAssertEqualObjects(@"test\n", allout, @"stdout did not match");
                   STAssertEqualObjects(@"test\n", combinedOut, @"combinedOut did not match");
                   signalWaitDone = true;
               }];
    [self waitForCompletion:3];
}

- (void)testRunSimpleEchoSync {
    __block NSString* stdoutString = @"";
    __block NSString* alloutString;
    [commandline runCmd:@"echo test"
               onOutput: ^(NSString *stdout) {
                   stdoutString = [stdoutString stringByAppendingString:stdout];
               }
               whenDone: ^ (NSString *combinedOut) {
                   alloutString = combinedOut;
                   signalWaitDone = true;
               }
                 isSync:YES];
    STAssertEqualObjects(@"test\n", stdoutString, @"stdout did not match");
    STAssertEqualObjects(@"test\n", alloutString, @"combinedOut did not match");
}

@end
