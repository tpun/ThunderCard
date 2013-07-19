//
//  Card.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/19/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recording;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Recording *recording;

@end
