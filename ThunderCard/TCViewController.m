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

@interface TCViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) Card *card;
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

#pragma mark - Audio Recording

- (IBAction)startRecording:(UIButton *)sender {
    [self statusStartRecording];
}

- (IBAction)stopRecording:(UIButton *)sender {

    [self statusStopRecording];
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
