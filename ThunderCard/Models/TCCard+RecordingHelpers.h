//
//  TCCard+RecordingHelpers.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/30/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCard.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TCCard (RecordingHelpers)
// Temporary file location for storing the recording
@property (readonly, nonatomic) NSURL *recordingURL;
@property (readonly, nonatomic) AVAudioRecorder *audioRecorder;
@property (readonly, nonatomic) AVAudioPlayer *audioPlayer;
- (BOOL)saveRecording:(NSURL *)fromURL;
- (BOOL)hasRecording;
@end
