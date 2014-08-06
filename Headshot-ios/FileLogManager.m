//
//  FileLogger.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "FileLogManager.h"
#import <MFMailComposeViewController+BlocksKit.h>

@interface FileLogManager()

@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@implementation FileLogManager

+ (FileLogManager *)sharedManager
{
    static FileLogManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[FileLogManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)setUpFileLogging
{
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:self.fileLogger];
}

- (NSMutableArray *)errorLogData
{
    NSUInteger maximumLogFilesToReturn = MIN(self.fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    DDFileLogger *logger = self.fileLogger;
    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}

- (void)composeEmailWithDebugAttachment
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
        
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    NSMutableData *errorLogData = [NSMutableData data];
    for (NSData *errorLogFileData in [self errorLogData]) {
        [errorLogData appendData:errorLogFileData];
    }
    [mailViewController addAttachmentData:errorLogData mimeType:@"text/plain" fileName:@"errorLog.txt"];
    [mailViewController setSubject:NSLocalizedString(@"Here are my logs", @"")];
    [mailViewController setToRecipients:@[@"jeff@badge.co", @"charlie@badge.co"]];
    [mailViewController bk_setCompletionBlock:^(MFMailComposeViewController *mailComposeViewController, MFMailComposeResult result, NSError *error) {
        [mailComposeViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [[AppDelegate sharedDelegate].window.rootViewController presentViewController:mailViewController animated:YES completion:nil];
}

@end
