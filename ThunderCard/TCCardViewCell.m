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
@property (weak, nonatomic) IBOutlet UIView *cardView;
@end

@implementation TCCardViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cardView.backgroundColor = [UIColor whiteColor];
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
        self.helperLabel.text = @"Tap to play.";
    } else {
        self.helperLabel.text = @"Hold to record.";
    }
    [self setNeedsDisplay];
}

- (void)updateVolumeLevel:(float)dB
{
    float min = 0.5;
    float max = 1.0;
    float strength = pow(dB+180, 5.0) / pow(180.0, 5.0);
    if (strength < min) strength = min;
    if (strength > max) strength = max;
    UIColor *color = [UIColor colorWithRed:strength
                                     green:0
                                      blue:0
                                     alpha:1];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.cardView.backgroundColor = color;
                     }];
}

- (void)resetVolumeLevel
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.cardView.backgroundColor = [UIColor whiteColor];
                     }];
}

@end
