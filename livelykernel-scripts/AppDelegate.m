//
//  AppDelegate.m
//  livelykernel-scripts
//
//  Created by Robert Krahn on 8/24/12.
//  Copyright (c) 2012 LivelyKernel. All rights reserved.
//

#import "AppDelegate.h" 

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    theApp = [aNotification object];
}

- (void)awakeFromNib {
    [self extendEnv];
    [self initStatusMenu];
    [self startServerWatcher];
}

- (void)extendEnv {
    // LSEnvironment doesn't work...
    NSString *gitPath = [[NSBundle mainBundle] pathForResource:@"git/bin" ofType:@""];
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:@"node/bin" ofType:@""];
    NSString *lkPath = [[NSBundle mainBundle] pathForResource:@"node/lib/node_modules/livelykernel-scripts/bin" ofType:@""];
    char *path = getenv ("PATH");
    NSArray *pathParts = [NSArray arrayWithObjects:
                          [NSString stringWithUTF8String:path],
                          gitPath, nodePath, lkPath, nil];
    NSString *nsPath = [pathParts componentsJoinedByString: @":"];
    NSLog(@"%@", nsPath);
    setenv("PATH", [nsPath UTF8String], true);
}

- (void) initStatusMenu {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [self updateViewFromServerStatus];
}

- (void) startServerWatcher {
    serverWatchLoop = [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(updateViewFromServerStatus)
                                   userInfo: nil
                                    repeats:YES];
}

- (void) serverStateChanged {
//    [serverWatchLoop invalidate];
//     quick update
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(updateViewFromServerStatus)
                                   userInfo:nil
                                    repeats:NO];
//    [self startServerWatcher];
}

- (void) inform:msg {
    NSAlert *alert = [[NSAlert new] init];
    [alert setMessageText:msg];
    [alert runModal];
}

- (void) updateViewFromServerStatus {
    isServerAlive = [self isServerAlive];
    NSString* imageNamePart = isServerAlive ? @"lk-running" : @"lk-not-running";
    NSString* imageName = [[NSBundle mainBundle] pathForResource:imageNamePart ofType:@"png"];
    NSImage* lkStatusImage = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage: lkStatusImage];
    [startStopMenuItem setTitle: (isServerAlive ? @"Stop server" : @"Start server")];
}

- (IBAction)chooseServerLocation:(id)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    if (lkRepositoryLocation) {
        [openDlg setDirectoryURL:lkRepositoryLocation];
    }
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ([openDlg runModal] == NSOKButton) {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        NSURL *selection = [files lastObject];
        //        [self inform: [selection absoluteString]];
        lkRepositoryLocation = selection;
        [self inform: [selection path]];
    }
}

- (Boolean)isServerAlive {
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

- (IBAction)informAboutServerState:(id)sender {
//    NSString *git = [[NSBundle mainBundle] pathForResource:@"git/bin/git" ofType:@""];
//    char *rawPath = getenv("foo");
//    NSString *path = [NSString stringWithCString:rawPath encoding:NSASCIIStringEncoding];
//    [self inform:path];
//    NSLog([self runCmd:@"/bin/bash" args: [NSArray arrayWithObjects:@"-c", @"npm", @"list", nil] waitForResult:true]);
//    NSLog([self runCmd:@"/bin/bash" args: [NSArray arrayWithObjects:@"-c", @"env", nil] waitForResult:true]);
//    NSLog([self runCmd:@"/bin/bash" args: [NSArray arrayWithObjects:@"-c", @"npm -g list", nil] waitForResult:true]);
    [self runCmd:@"/bin/bash" args: [NSArray arrayWithObjects:@"-c", @"lk server", nil] waitForResult:false];
//    [self inform: [self isServerAlive] ? @"Server is running" : @"No server running"];
//    [self inform: [self runCmd:@"node" args: [NSArray array] waitForResult:true]];
}

- (IBAction) startOrStopServer:(id)sender {
    // non-blocking
    NSString *arg = isServerAlive ? @"lk server --kill" : @"lk server";
    [self runLKServerCmdWithArgs:[NSArray arrayWithObjects: arg,nil] waitForResult:false];
    [self serverStateChanged];
}

- (NSString*) runLKServerCmdWithArgs:(NSArray *)arguments waitForResult:(Boolean)wait {
    NSString *lkCmdPath = [[NSBundle mainBundle] pathForResource:@"lk" ofType:nil];
    lkCmdPath = @"/bin/bash";
//    NSArray *baseArguments = [NSArray arrayWithObjects: @"--login", @"-c", @"lk server",nil];
    NSArray *baseArguments = [NSArray arrayWithObjects: @"-c",nil];
    NSArray *allArguments = [baseArguments arrayByAddingObjectsFromArray:arguments];
    //    NSArray *arguments = [NSArray arrayWithObjects: @"lk", @"server", nil];
    return [self runCmd:lkCmdPath args:allArguments waitForResult:wait];
}

- (NSString*) runCmd:(NSString*)cmd args:(NSArray *)arguments waitForResult:(Boolean)wait {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];

    [task setLaunchPath: cmd];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    //The magic line that keeps your log where it belongs
    [task setStandardInput:[NSPipe pipe]];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];

    [task launch];

    if (wait) {
        NSData *data = [file readDataToEndOfFile];
        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        return string;
    }
 
    return nil;
}

@end
