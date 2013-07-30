//
//  TCCard+RecordingHelpers.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/30/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCard+RecordingHelpers.h"
#import "TCRecording.h"

@implementation TCCard (RecordingHelpers)

- (NSURL *)recordingURL
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDirectory stringByAppendingPathComponent:[self recordingFilename]];
    return [NSURL fileURLWithPath:tmpFile];
}

- (void)saveRecording:(NSURL *)fromURL
{
    if (!self.recording) {
        TCRecording *recording = [NSEntityDescription insertNewObjectForEntityForName:@"TCRecording"
                                                               inManagedObjectContext:self.managedObjectContext];
        self.recording = recording;
    }

    self.recording.data = [NSData dataWithContentsOfURL:fromURL];
}

- (NSString *)recordingFilename
{
    return @"xxx_recording.m4a"; // xxx should be based on unique ID of current Card object.
}

@end
