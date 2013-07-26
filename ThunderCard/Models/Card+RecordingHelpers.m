//
//  Card+RecordingHelpers.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/24/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "Card+RecordingHelpers.h"

@implementation Card (RecordingHelpers)

- (NSURL *)recordingURL
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDirectory stringByAppendingPathComponent:[self recordingFilename]];
    return [NSURL fileURLWithPath:tmpFile];
}

- (void)saveRecording:(NSURL *)fromURL
{
}

- (NSString *)recordingFilename
{
    return @"xxx_recording"; // xxx should be based on unique ID of current Card object.
}

@end
