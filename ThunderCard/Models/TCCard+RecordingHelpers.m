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

- (BOOL)saveRecording:(NSURL *)fromURL
{
    if (!self.recording) {
        TCRecording *recording = [NSEntityDescription insertNewObjectForEntityForName:@"TCRecording"
                                                               inManagedObjectContext:self.managedObjectContext];
        self.recording = recording;
    }

    self.recording.data = [NSData dataWithContentsOfURL:fromURL];
    return [self.managedObjectContext save:nil];
}

- (BOOL)hasRecording
{
    // TODO: TCRecording should implement hasRecording
    return (self.recording.data.length > 0);
}

- (NSString *)recordingFilename
{
    return @"xxx_recording.m4a"; // xxx should be based on unique ID of current Card object.
}

- (AVAudioRecorder *)audioRecorder
{
    NSError *error = nil;
    NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                               AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
                               AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityHigh]};

    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:self.recordingURL
                                                            settings:settings
                                                               error:&error];
    if (!recorder) NSLog(@"Failed to init recorder: error: %@", error);
    recorder.meteringEnabled = YES;
    BOOL success = [recorder prepareToRecord];
    if (!success)  NSLog(@"Failed to prepare for recording with %@", settings);

    return recorder;
}

- (AVAudioPlayer *)audioPlayer
{
    AVAudioPlayer *player = nil;
    NSData *data = self.recording.data;
    if (data.length > 0) {
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if (!player) {
            NSLog(@"Failed to init player: error: %@", error);
        }
    }
    BOOL success = [player prepareToPlay];
    if (!success) NSLog(@"Failed to prepare for playback");

    return player;
}
@end
