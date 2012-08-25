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
    [self initStatusMenu];
}

- (void) initStatusMenu {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [self updateViewFromServerStatus];
}

- (Boolean) isServerRunning {
    // todo implement
    return YES;
}

- (void) updateViewFromServerStatus {
    NSString* imageNamePart = [self isServerRunning] ? @"lk-running" : @"lk-not-running";
    NSString* imageName = [[NSBundle mainBundle] pathForResource:imageNamePart ofType:@"png"];
    NSImage* lkStatusImage = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage: lkStatusImage];
}

- (void) inform:msg {
    NSAlert *alert = [[NSAlert new] init];
    [alert setMessageText:msg];
    [alert runModal];
}

- (IBAction) startServer:(id)sender {
    NSString *lkCmdPath = [[NSBundle mainBundle] pathForResource:@"lk" ofType:nil];
    lkCmdPath = @"/usr/local/bin/lk";
    NSArray *arguments = [NSArray arrayWithObjects: @"server", nil];
    NSPipe *pipe = [NSPipe pipe];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: lkCmdPath];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    //The magic line that keeps your log where it belongs
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"Returned:\n%@", string);
}

- (IBAction) runCmd:(id)sender {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/ls"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"/Users/robert/", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    //The magic line that keeps your log where it belongs
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"grep returned:\n%@", string);
}

@end
