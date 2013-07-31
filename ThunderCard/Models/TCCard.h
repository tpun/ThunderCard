//
//  TCCard.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/31/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TCRecording;

@interface TCCard : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) TCRecording *recording;

@end
