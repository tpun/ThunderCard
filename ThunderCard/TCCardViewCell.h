//
//  TCCardViewCell.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/27/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCardViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic) BOOL hasRecording;

- (void)startRecording;
- (void)stopRecording;
- (void)updateVolumeLevel:(float)dB;
- (void)resetVolumeLevel;
@end
