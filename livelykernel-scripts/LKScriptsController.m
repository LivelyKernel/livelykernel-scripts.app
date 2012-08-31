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
@synthesize statusItem, statusMenu, startStopMenuItem, scriptOutputWindow, scriptText;

- (id) initWithStatusItem: (NSStatusItem *)appStatusItem {
    self = [super init];
    [self setStatusItem: appStatusItem];
    [self setStatusMenu: [statusItem menu]];
    [self setStartStopMenuItem: [[self statusMenu] itemAtIndex:2]]; // FIXME
    [self updateFromServerStatus];
    [self startServerWatcher];
    [scriptOutputWindow setReleasedWhenClosed: NO]; // we want to reuse it later
    return self;
}

- (BOOL)isServerAlive {
    // get `lk server --info`
    NSArray *arguments = [NSArray arrayWithObjects: @"lk server --info",nil];
    NSString* serverInfoString = [self runLKServerCmdWithArgs:arguments waitForResult:true];
    
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
    return alive;
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
    BOOL isServerAlive = [self isServerAlive];
    NSString* imageNamePart = isServerAlive ? @"lk-running" : @"lk-not-running";
    NSString* imageName = [[NSBundle mainBundle] pathForResource:imageNamePart ofType:@"png"];
    NSImage* lkStatusImage = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage: lkStatusImage];
    [[self startStopMenuItem] setTitle: (isServerAlive ? @"Stop server" : @"Start server")];
}

- (IBAction)updatePartsBin:(id)sender {
    [self runAndShowLKServerCmdWithArgs: [NSArray arrayWithObject:@"lk partsbin"]];
}

- (IBAction)updateCoreRepo:(id)sender {
    [self runAndShowLKServerCmdWithArgs: [NSArray arrayWithObject:@"lk workspace -u"]];
}

- (IBAction)updateUserDirectory:(id)sender {
}

- (IBAction)openLivelyInBrowser:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://localhost:9001/blank.xhtml"]];
}

- (IBAction)informAboutServerState:(id)sender {
    [self runAndShowLKServerCmdWithArgs: [NSArray arrayWithObjects:@"lk server --info", nil]];
}

- (IBAction) startOrStopServer:(id)sender {
    // non-blocking
    NSString *arg = [self isServerAlive] ? @"lk server --kill" : @"lk server";
    [self runLKServerCmdWithArgs:[NSArray arrayWithObjects: arg,nil] waitForResult:false];
    [self serverStateChanged];
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

- (void) runAndShowLKServerCmdWithArgs:(NSArray *)arguments {
    NSArray *baseArguments = [NSArray arrayWithObjects: @"--login", @"-c",nil];
    NSArray *allArguments = [baseArguments arrayByAddingObjectsFromArray:arguments];
    NSFileHandle *out = [self runCmd:@"/bin/bash" args:allArguments];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(readLKServerCmdOutput:)
                               name:NSFileHandleReadCompletionNotification
                             object:out];
    [out readInBackgroundAndNotify];
}

-(void) readLKServerCmdOutput: (NSNotification *)aNotification {
    NSData *data = [[aNotification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
    if ([data length] == 0) return;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self performSelectorOnMainThread:@selector(showInHUD:)
                           withObject:string
                        waitUntilDone:false];
    [[aNotification object] readInBackgroundAndNotify];
}

-(void) showInHUD:(NSString*)string {
    if (![scriptOutputWindow isVisible]){
        [scriptOutputWindow makeKeyAndOrderFront: nil];
    }
    [scriptText setTextColor:[NSColor whiteColor]];
    [[[scriptText textStorage] mutableString] appendString: string];
}

- (NSString*) runLKServerCmdWithArgs:(NSArray *)arguments waitForResult:(Boolean)wait {
    NSArray *baseArguments = [NSArray arrayWithObjects: @"--login", @"-c",nil];
    NSArray *allArguments = [baseArguments arrayByAddingObjectsFromArray:arguments];
    return [self runCmd:@"/bin/bash" args:allArguments waitForResult:wait];
}

- (NSString*) runCmd:(NSString*)cmd args:(NSArray *)arguments waitForResult:(Boolean)wait {
    NSFileHandle *file = [self runCmd:cmd args:arguments];
    if (wait) {
        NSData *data = [file readDataToEndOfFile];
        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        return string;
    }
    return nil;
}

- (NSFileHandle*) runCmd:(NSString*)cmd args:(NSArray *)arguments {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    
    [task setLaunchPath: cmd];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    //The magic line that keeps your log where it belongs
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    return file;
}


@end
