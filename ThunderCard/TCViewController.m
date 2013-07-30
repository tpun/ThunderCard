//
//  TCViewController.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/19/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCViewController.h"
#import "TCAppDelegate.h"

#import "TCCard.h"
#import "TCCard+RecordingHelpers.h"
#import "TCRecording.h"

#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>

@interface TCViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingActivityIndicator;

@property (strong, nonatomic) TCCard *card;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self statusStopRecording];
    self.textLabel.text = self.card.text;
    BOOL success = [self.audioRecorder prepareToRecord];
    NSLog(@"PrepareToRecord: %d", success);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (TCCard *)card
{
    if (!_card) { _card = [self randomCard]; }
    return _card;
}

- (AVAudioRecorder*)audioRecorder
{
    if (!_audioRecorder) {
        NSError *error = nil;
        NSURL *url = self.card.recordingURL;
        NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                                   AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
                                   AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
                                   AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityHigh]};

        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                     settings:settings
                                                        error:&error];
        NSLog(@"AVAudioRecord init (%@) error: %@, ", _audioRecorder, error);
        _audioRecorder.meteringEnabled = YES;

    }
    return _audioRecorder;
}

#pragma mark - Audio

- (IBAction)startOrStopRecording:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self startRecording];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self stopAndSaveRecording];
    } else if (sender.state != UIGestureRecognizerStateChanged) {
        [self stopRecording];
    }
}

- (void)startRecording
{
    [self statusStartRecording];
    BOOL success =  [self.audioRecorder record];
    NSLog(@"Audio Recording, success: %d", success);
}

- (void)stopAndSaveRecording
{
    [self stopRecording];
    [self.card saveRecording:self.audioRecorder.url];
}

- (void)stopRecording
{
    [self.audioRecorder stop];
    [self statusStopRecording];
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    TCRecording *recording = self.card.recording;
    NSData *data = recording.data;
    if (data.length > 0) {
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        BOOL success = [self.audioPlayer play];
        NSLog(@"Audio playing, success: %d", success);
    }
}

#pragma mark - Status Updating

- (void)statusStartRecording {
    self.recordingStatusLabel.hidden = NO;
    [self.recordingActivityIndicator startAnimating];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateVolumeFeedback)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)statusStopRecording {
    self.recordingStatusLabel.hidden = YES;
    [self.recordingActivityIndicator stopAnimating];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateVolumeFeedback {
    [self.audioRecorder updateMeters];
    float level = [self.audioRecorder averagePowerForChannel:0];
    float level2 = [self.audioRecorder averagePowerForChannel:1];
    NSLog(@"Audio level: %f, %f", level, level2);
}

#pragma mark - Testing

- (TCCard *)randomCard
{
    TCAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"TCCard"
                inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    [request setPredicate:NULL];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

    return [results firstObject];
}

@end
