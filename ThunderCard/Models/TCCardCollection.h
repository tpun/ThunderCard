//
//  TCCardCollection.h
//  ThunderCard
//
//  Created by Thomas Pun on 7/31/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCardCollection : NSObject
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSArray *sortedCards;
- (TCCardCollection *)initWithManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (void)reload;
@end
