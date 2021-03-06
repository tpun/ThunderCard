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

@interface TCCardCollectionViewController() <UIActionSheetDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property (strong, nonatomic) TCCardCollection *cardCollection;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;
@end

NSString * const TCDeleteCardActionSheetButtonTitle = @"Delete this card";
NSString * const TCDeleteRecordingActionSheetButtonTitle = @"Delete this recording";
#define TimerFrequency 0.3

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
    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
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
    NSIndexPath *indexPath = [self currentCardViewCellIndexPath];
    return [self.cardCollection.sortedCards objectAtIndex:indexPath.row];
}

- (NSIndexPath *)currentCardViewCellIndexPath
{
    TCCardViewCell *currentViewCell = [self currentCardViewCell];
    return [self.collectionView indexPathForCell:currentViewCell];
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
    if (card.hasRecording) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Please double tap to delete existing recording before proceeding."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        [cardView startRecording];
        self.audioRecorder = card.audioRecorder;
        self.audioRecorder.meteringEnabled = YES;
        [self.audioRecorder record];

        // Set up a timer for update audio level
        self.timer = [NSTimer scheduledTimerWithTimeInterval:TimerFrequency
                                                      target:self
                                                    selector:@selector(meterRecorderVolumeLevel:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
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
    [self resetVolumeLevel];
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    TCCard *card = [self currentCard];

    // stop if previously playing
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        [self resetVolumeLevel];
    } else if (card.hasRecording) {
        self.audioPlayer = card.audioPlayer;
        self.audioPlayer.meteringEnabled = YES;
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];

        // Set up a timer for update audio level
        self.timer = [NSTimer scheduledTimerWithTimeInterval:TimerFrequency
                                                      target:self
                                                    selector:@selector(meterPlayerVolumeLevel:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

#pragma mark - Card Creation

- (IBAction)confirmCardCreation:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New ThunderCard"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"Name of the new card";
    [alertView show];
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

#pragma mark - Card Deletion

- (IBAction)confirmCardDeletion:(UITapGestureRecognizer *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:TCDeleteCardActionSheetButtonTitle
                                                    otherButtonTitles: nil];
    if (([self currentCard]).hasRecording) {
        [actionSheet addButtonWithTitle:TCDeleteRecordingActionSheetButtonTitle];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

- (void)deleteCurrentCard
{
    TCCard *card = [self currentCard];
    [self.cardCollection.managedObjectContext deleteObject:card];
    [self.cardCollection reload];
    [self updateTitle];

    [self.collectionView deleteItemsAtIndexPaths:@[[self currentCardViewCellIndexPath]]];
}

- (void)deleteCurrentRecording
{
    [self deleteRecordingFor:[self currentCard] inView:[self currentCardViewCell]];
}

- (void)deleteRecordingFor:(TCCard *)card inView:(TCCardViewCell *)cardView
{
    TCRecording *recording = card.recording;
    [self.cardCollection.managedObjectContext deleteObject:recording];
    [self.cardCollection reload];
    cardView.hasRecording = NO;
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self createCard:textField.text];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:TCDeleteCardActionSheetButtonTitle]) {
        [self deleteCurrentCard];
    } else if ([title isEqualToString:TCDeleteRecordingActionSheetButtonTitle]) {
        [self deleteCurrentRecording];
    }
}

- (void)meterRecorderVolumeLevel:(NSTimer *)timer
{
    [self.audioRecorder updateMeters];
    float dB = [self.audioRecorder averagePowerForChannel:0];
    TCCardViewCell *cardView = [self currentCardViewCell];
    [cardView updateVolumeLevel:dB];
}

- (void)meterPlayerVolumeLevel:(NSTimer *)timer
{
    [self.audioPlayer updateMeters];
    float dB = [self.audioPlayer averagePowerForChannel:0];
    TCCardViewCell *cardView = [self currentCardViewCell];
    [cardView updateVolumeLevel:dB];
}

- (void)resetVolumeLevel
{
    [self.timer invalidate];
    TCCardViewCell *cardView = [self currentCardViewCell];
    [cardView resetVolumeLevel];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self resetVolumeLevel];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self resetVolumeLevel];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self resetVolumeLevel];
}
@end
