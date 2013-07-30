//
//  TCCardViewCell.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/27/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCardViewCell.h"

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

@end
