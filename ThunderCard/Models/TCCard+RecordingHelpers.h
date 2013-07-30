//
//  TCCard+RecordingHelpers.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/30/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCard.h"

@interface TCCard (RecordingHelpers)
// Temporary file location for storing the recording
@property (readonly, nonatomic) NSURL *recordingURL;
- (void)saveRecording:(NSURL *)fromURL;
@end
