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
    [self updateTitle];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

- (void)updateTitle
{
    self.navigationItem.title = [NSString stringWithFormat:@"%d ThunderCards", self.cardCollection.sortedCards.count];
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

- (TCCard *)cardFromViewCell:(TCCardViewCell *)cardViewCell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cardViewCell];
    return [self.cardCollection.sortedCards objectAtIndex:indexPath.row];
}

- (TCCardViewCell *)currentCardViewCell
{
    return [[self.collectionView visibleCells] firstObject];
}

- (TCCard *)currentCard
{
    return [self cardFromViewCell:[self currentCardViewCell]];
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
    cardViewCell.hasRecording = card.hasRecording;
    return cell;
}

#pragma mark - Audio Recording / Playing

- (IBAction)startOrStopRecording:(UILongPressGestureRecognizer *)sender {
    TCCardViewCell *cardView = [self currentCardViewCell];
    TCCard *card = [self currentCard];

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
    if ([card saveRecording:self.audioRecorder.url]) {
        cardView.hasRecording = card.hasRecording;
    }
}

- (void)stopRecordingFor:(TCCard *)card inView:(TCCardViewCell *)cardView
{
    [cardView stopRecording];
    [self.audioRecorder stop];
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    TCCard *card = [self currentCard];

    // stop if previously playing
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    } else {
        self.audioPlayer = card.audioPlayer;
        [self.audioPlayer play];
    }
}

#pragma mark - Card Creation

- (IBAction)addCard:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New ThunderCard"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cacnel"
                                              otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"Name of the new card";
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self createCard:textField.text];
    }
}

- (void)createCard:(NSString *)text {
    TCCard *card = [NSEntityDescription insertNewObjectForEntityForName:@"TCCard"
                                                 inManagedObjectContext:self.cardCollection.managedObjectContext];
    card.text = text;
    [self.cardCollection reload];
    [self updateTitle];
    NSIndexPath *latestPath = [NSIndexPath indexPathForItem:self.cardCollection.sortedCards.count-1
                                                  inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[latestPath]];
    [self.collectionView scrollToItemAtIndexPath:latestPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically & UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

@end
