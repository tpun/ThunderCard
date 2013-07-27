//
//  TCViewController.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/19/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCViewController.h"
#import "TCAppDelegate.h"

#import "Card.h"
#import "Card+RecordingHelpers.h"
#import "Recording.h"

#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TCViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingActivityIndicator;

@property (strong, nonatomic) Card *card;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Card *)card
{
    if (!_card) { _card = [self randomCard]; }
    return _card;
}

- (AVAudioRecorder*)audioRecorder
{
    if (!_audioRecorder) {
        NSError *error = nil;
        NSURL *url = self.card.recordingURL;
        NSDictionary *settings = @{AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityHigh]};

        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                     settings:settings
                                                        error:&error];
        _audioRecorder.meteringEnabled = YES;
        if (!_audioRecorder) {
            NSLog(@"Error: %@", error);
        }
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
    [self.audioRecorder record];
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
    Recording *recording = self.card.recording;
    NSData *data = recording.data;
    if (data.length > 0) {
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data
                                                         error:&error];
        [self.audioPlayer play];
        NSLog(@"Playing recording");
    }
}

#pragma mark - Status Updating

- (void)statusStartRecording {
    self.recordingStatusLabel.hidden = NO;
    [self.recordingActivityIndicator startAnimating];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3
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
    NSLog(@"Audio level: %f", level);
}

#pragma mark - Testing

- (Card *)randomCard
{
    TCAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Card"
                inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    [request setPredicate:NULL];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

    return [results firstObject];
}

@end
