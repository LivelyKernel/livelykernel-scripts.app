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
    [self stopServerWatcher];
    serverWatchLoop = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(fetchServerStatus)
                                                     userInfo: nil
                                                      repeats:YES];
}

- (void) stopServerWatcher {
    if (serverWatchLoop) [serverWatchLoop invalidate];
}

- (void) fetchServerStatus {
    [self getServerStateThenDo: ^ (BOOL isAlive){
        NSLog(@"getServerStateThenDo %@", isAlive ? @"y" : @"n");
        _isServerAlive = isAlive;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LKServerState" object:self];
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
    [self stopServerWatcher];
    void (^updateBlock)() = ^{
        [self fetchServerStatus];
        [self startServerWatcher];
    };
    if (self.isServerAlive) {
        [self stopServerThenDo:updateBlock];
    } else {
        [self startServerThenDo:updateBlock];
    }
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
}

- (void) runAndShowLKServerCmd:(NSString*)cmd {
    [self runLKServerCmd:cmd
                onOutput: ^(NSString *out) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LKScriptOutput" object:out];
                }
                whenDone: ^(NSString *out) {
//                    NSLog(@"%@: %@", cmd, out);
                }];
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
