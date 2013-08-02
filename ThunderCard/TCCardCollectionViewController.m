//
//  TCCardCollectionViewController.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/27/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCardCollectionViewController.h"
#import "TCCardViewCell.h"
#import "TCCardCollection.h"
#import "TCCard.h"
#import "TCCard+RecordingHelpers.h"
#import "TCRecording.h"
#import "TCAppDelegate.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>

@interface TCCardCollectionViewController ()
@property (strong, readonly, nonatomic) TCCardViewCell *currentCardView;
@property (strong, nonatomic) TCCardCollection *cardCollection;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation TCCardCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Card Management

- (TCCardCollection *)cardCollection
{
    if (!_cardCollection) {
        TCAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
        _cardCollection = [[TCCardCollection alloc] initWithManagedContext:managedObjectContext];
    }
    return _cardCollection;
}

- (TCCard *)cardFromView:(TCCardViewCell *)cardView
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cardView];
    return [self.cardCollection.sortedCards objectAtIndex:indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.cardCollection.sortedCards count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    TCCardViewCell *cardViewCell = (TCCardViewCell *) cell;
    TCCard *card = [self.cardCollection.sortedCards objectAtIndex:indexPath.row];

    cardViewCell.textLabel.text = card.text;
    return cell;
}

#pragma mark - Audio Recording / Playing

- (IBAction)startOrStopRecording:(UILongPressGestureRecognizer *)sender {
    // TCCardViewCell *cardView = (TCCardViewCell *)sender.view;
    TCCardViewCell *cardView = [[self.collectionView visibleCells] firstObject];
    TCCard *card = [self cardFromView:cardView];

    if (sender.state == UIGestureRecognizerStateBegan) {
        [self startRecordingFor:card inView:cardView];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self stopAndSaveRecordingFor:card inView:cardView];
    } else if (sender.state != UIGestureRecognizerStateChanged) {
        [self stopRecordingFor:card inView:cardView];
    }
}

- (void)startRecordingFor:(TCCard *)card inView:(TCCardViewCell *)cardView
{
    [cardView startRecording];
    self.audioRecorder = card.audioRecorder;
    [self.audioRecorder record];
}

- (void)stopAndSaveRecordingFor:(TCCard *)card inView:(TCCardViewCell *)cardView
{
    [self stopRecordingFor:card inView:cardView];
    [card saveRecording:self.audioRecorder.url];
}

- (void)stopRecordingFor:(TCCard *)card inView:(TCCardViewCell *)cardView
{
    [cardView stopRecording];
    [self.audioRecorder stop];
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    // TCCardViewCell *cardView = (TCCardViewCell *)sender.view;
    TCCardViewCell *cardView = [[self.collectionView visibleCells] firstObject];
    TCCard *card = [self cardFromView:cardView];

    self.audioPlayer = card.audioPlayer;
    [self.audioPlayer play];
}


@end
