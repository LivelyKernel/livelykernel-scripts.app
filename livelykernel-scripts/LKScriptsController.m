//
//  LKScriptsController.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/31/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "LKScriptsController.h"

@implementation LKScriptsController

@synthesize isServerAlive=_isServerAlive;

//- (id) init {
//    self = [super init];
//    return self;
//}

- (void)parseServerInfoJSON:(NSString*)serverInfoString thenDo:(void(^)(BOOL isAlive))block {
    // we are currently only interested in "alive"
    Boolean alive = false;
    NSInteger pid = 0;
    
    // scan a one level JSON object
    NSScanner *infoScanner = [NSScanner scannerWithString:serverInfoString];
    NSString *key;
    [infoScanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    while ([infoScanner isAtEnd] == NO) {
        [infoScanner scanString:@"\"" intoString:NULL];
        [infoScanner scanUpToString: @"\"" intoString:&key];
        [infoScanner scanString:@"\":" intoString:NULL];
        if ([key isEqualToString:@"alive"]) {
            NSString *aliveString;
            [infoScanner scanUpToString: @"," intoString:&aliveString];
            alive = [aliveString isEqualToString:@"true"];
        }
        if ([key isEqualToString:@"pid"]) {
            [infoScanner scanString:@"\"" intoString:NULL];
            [infoScanner scanInteger:&pid];
            [infoScanner scanString:@"\"" intoString:NULL];
        }
        [infoScanner scanString: @"," intoString:NULL];
    }
    block(alive);
}

- (void) getServerStateThenDo:(void (^)(BOOL isAlive))block {
    [self runLKServerCmd:@"lk server --info"
                whenDone: ^(NSString*out){
                    [self parseServerInfoJSON: out thenDo:block];
                }];
}

- (void) startServerWatcher {
    if (serverWatchLoop) [serverWatchLoop invalidate];
    serverWatchLoop = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                       target:self
                                                     selector:@selector(updateFromServerStatus)
                                                     userInfo: nil
                                                      repeats:YES];
}

- (void) fetchServerStatus {
    [self getServerStateThenDo: ^ (BOOL isAlive){
        NSLog(@"getServerStateThenDo %@", isAlive ? @"y" : @"n");
        _isServerAlive = isAlive;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LKServerState" object:self];
    }];

}

- (IBAction)updatePartsBin:(id)sender {
    [self runAndShowLKServerCmd: @"lk partsbin"];
}

- (IBAction)updateCoreRepo:(id)sender {
    [self runAndShowLKServerCmd: @"lk workspace -u"];
}

- (IBAction)updateUserDirectory:(id)sender {
}

- (IBAction)openLivelyInBrowser:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://localhost:9001/blank.xhtml"]];
}

- (IBAction)informAboutServerState:(id)sender {
    [self runAndShowLKServerCmd: @"lk server --info"];
}

- (IBAction)startOrStopServer:(id)sender {
    [self startOrStopServerThenDo:^{ [self fetchServerStatus]; }];
}

- (void) startServerThenDo:(void (^)())block {
    __block BOOL thenDoBlockRun = NO;
    [self runLKServerCmd:@"lk server"
                onOutput:^ (NSString *output) {
                    if (!thenDoBlockRun) {
                        block();
                        thenDoBlockRun = YES;
                    }
                }
                whenDone:^ (NSString *out) { }];
}

- (void) stopServerThenDo:(void (^)())block {
    NSLog(@"stopping server ...");
    [self runLKServerCmdSync:@"lk server --kill"];
    block();
//    CommandLineInterface *commandLine= [[CommandLineInterface alloc] init];
//    NSTask *task = [commandLine cmdTask:@"lk server --kill"];
//    task.terminationHandler = ^(NSTask *task) {
//            block();
//    };
//    [task launch];
//    [task waitUntilExit];

//    [self runLKServerCmd:@"lk server --kill"
//                onOutput:^(NSString *output) {     NSLog(@"stopping server ... %@", output); }
//                whenDone:block];
}
- (void) startOrStopServerThenDo:(void (^)())block {    
    if (self.isServerAlive) {
        [self stopServerThenDo:block];
    } else {
        [self startServerThenDo:block];
    }
}

- (void) runAndShowLKServerCmd:(NSString*)cmd {
    [self runLKServerCmd:cmd
                whenDone: ^(NSString *out) { NSLog(@"%@: %@", cmd, out); }];
}

- (NSString*) runLKServerCmdSync:(NSString*)cmd {
    __block NSString *out;
    [self runLKServerCmd:(NSString*)cmd
                onOutput:^(NSString *stdout) {}
                whenDone:^(NSString* output) { out = output; }
                  isSync:YES];
    return out;
}

- (void) runLKServerCmd:(NSString*)cmd whenDone:(void (^)(NSString* output))doneBlock {
    [self runLKServerCmd:cmd onOutput:^(NSString*out) {} whenDone:doneBlock];
}

- (void) runLKServerCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString* output))doneBlock {
    [self runLKServerCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString* output))doneBlock isSync:NO];
}

- (void) runLKServerCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)(NSString* output))doneBlock isSync:(BOOL)isSync {
    CommandLineInterface *commandLine= [[CommandLineInterface alloc] init];
    [commandLine runCmd:cmd onOutput:outputBlock whenDone:doneBlock isSync: isSync];
}

//- (IBAction)chooseServerLocation:(id)sender {
//    // Create the File Open Dialog class.
//    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
//    [openDlg setCanChooseFiles:NO];
//    [openDlg setCanChooseDirectories:YES];
//    [openDlg setAllowsMultipleSelection:NO];
//    if (lkRepositoryLocation) {
//        [openDlg setDirectoryURL:lkRepositoryLocation];
//    }
//    // Display the dialog.  If the OK button was pressed,
//    // process the files.
//    if ([openDlg runModal] == NSOKButton) {
//        // Get an array containing the full filenames of all
//        // files and directories selected.
//        NSArray* files = [openDlg URLs];
//        NSURL *selection = [files lastObject];
//        //        [self inform: [selection absoluteString]];
//        lkRepositoryLocation = selection;
//        [self inform: [selection path]];
//    }
//}

@end
