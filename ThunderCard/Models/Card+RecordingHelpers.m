//
//  Card+RecordingHelpers.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/24/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "Card+RecordingHelpers.h"
#import "Recording.h"

@implementation Card (RecordingHelpers)

- (NSURL *)recordingURL
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDirectory stringByAppendingPathComponent:[self recordingFilename]];
    return [NSURL fileURLWithPath:tmpFile];
}

- (void)saveRecording:(NSURL *)fromURL
{
    if (!self.recording) {
        Recording *recording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording"
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
