//
//  TCCardViewCell.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/27/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCardViewCell.h"

@interface TCCardViewCell()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *helperLabel;
@end

@implementation TCCardViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)startRecording
{
    self.statusLabel.hidden = NO;
    [self.statusActivityIndicator startAnimating];
}

- (void)stopRecording
{
    self.statusLabel.hidden = YES;
    [self.statusActivityIndicator stopAnimating];
}

- (void)setHasRecording:(BOOL)hasRecording
{
    _hasRecording = hasRecording;
    if (_hasRecording) {
        self.helperLabel.text = @"Tap to play. Hold to record.";
    } else {
        self.helperLabel.text = @"Hold to record.";
    }
    [self setNeedsDisplay];
}

@end
