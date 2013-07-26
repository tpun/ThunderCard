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
#import "Card+Card_RecordingURL.h"
#import "Recording.h"

#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TCViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (strong, nonatomic) Card *card;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
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

        if (!_audioRecorder) {
            NSLog(@"Error: %@", error);
        }
    }
    return _audioRecorder;
}

#pragma mark - Audio

- (IBAction)startRecording:(UIButton *)sender {
    [self statusStartRecording];
    [self.audioRecorder record];
}

- (IBAction)stopRecording:(UIButton *)sender {
    [self.audioRecorder stop];
    [self.card saveRecording:self.audioRecorder.url];
    [self statusStopRecording];
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    Recording *recording = self.card.recording;
    NSData *data = recording.data;
    if (data.length > 0) {
        NSError *error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data
                                                              error:&error];
        [player play];
    }
}

#pragma mark - Status Updating

- (void)statusStartRecording {
    self.recordingStatusLabel.hidden = NO;
    [self.recordingActivityIndicator startAnimating];
}

- (void)statusStopRecording {
    self.recordingStatusLabel.hidden = YES;
    [self.recordingActivityIndicator stopAnimating];
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
