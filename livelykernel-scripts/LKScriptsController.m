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

- (id) init {
    self = [super init];
    [self updateFromServerStatus];
    return self;
}

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
    
    //    NSLog(@"alive: %@, pid: %lo", alive ? @"true" : @"false", pid);
    block(alive);
}

- (void) getServerStateThenDo:(void (^)(BOOL isAlive))block {
    [self runLKServerCmd:@"lk server --info"
                whenDone: ^(NSString*out){
                    [self parseServerInfoJSON: out thenDo:block];
                }];
}

- (void) serverStateChanged {
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(updateFromServerStatus)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) startServerWatcher {
    serverWatchLoop = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                       target:self
                                                     selector:@selector(updateFromServerStatus)
                                                     userInfo: nil
                                                      repeats:YES];
}

- (void) updateFromServerStatus {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LKServerState" object:self];
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

- (void) startOrStopServer:(id)sender thenDo:(void (^)())block {
    [self runLKServerCmd:[self isServerAlive] ? @"lk server --kill" : @"lk server"
                onOutput:^ (NSString *output) { }
                whenDone:block];
    [self serverStateChanged];
}

- (void) runAndShowLKServerCmd:(NSString*)cmd {
    [self runLKServerCmd:cmd
                whenDone: ^(NSString *out) { NSLog(@"%@: %@", cmd, out); }];
//    __block NSString* allOut;
//    [self runLKServerCmd:cmd
//                onOutput:^(NSString*out) {
//                    allOut = [allOut stringByAppendingString:out];
//                }
//                whenDone:^ {
//                    [self showInHUD:allOut];
//                }];
}

- (void) runLKServerCmd:(NSString*)cmd whenDone:(void (^)(NSString* output))doneBlock {
    __block NSString* allOut;
    [self runLKServerCmd:cmd
                onOutput:^(NSString*out) { allOut = [allOut stringByAppendingString:out]; }
                whenDone:^ { doneBlock(allOut); }];
}

- (void) runLKServerCmd:(NSString*)cmd onOutput:(void (^)(NSString *stdout))outputBlock whenDone:(void (^)())doneBlock {
//    CommandLineInterface *commandLine= [[CommandLineInterface alloc] init];
//    [commandLine runCmd:cmd onOutput:outputBlock whenDone:doneBlock];
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
