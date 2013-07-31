//
//  TCCard+CreatedAtTimeStamp.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/31/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCard+CreatedAtTimeStamp.h"

@implementation TCCard (CreatedAtTimeStamp)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setValue:[NSDate date] forKey:@"createdAt"];
}

@end
