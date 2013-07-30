//
//  TCRecording.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/30/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TCCard;

@interface TCRecording : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) TCCard *card;

@end
