//
//  TCCardCollectionViewController.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/27/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCardCollectionViewController.h"
#import "TCCardViewCell.h"

@interface TCCardCollectionViewController ()
@property (strong, readonly, nonatomic) TCCardViewCell *currentCardView;
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

- (TCCardViewCell *)currentCardView
{
    NSArray *cells = [self.collectionView visibleCells];
    return cells.firstObject;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    TCCardViewCell *cardViewCell = (TCCardViewCell *) cell;
    cardViewCell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}

#pragma mark - Recording

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
    [self.currentCardView startRecording];
    NSLog(@"startRecording");
}

- (void)stopAndSaveRecording
{
    [self stopRecording];
    NSLog(@"saveRecording");
}

- (void)stopRecording
{
    [self.currentCardView stopRecording];
    NSLog(@"stopRecording");
}

- (IBAction)playRecording:(UITapGestureRecognizer *)sender {
    NSLog(@"playRecording");
}


@end
