//
//  TCCardCollection.m
//  ThunderCard
//
//  Created by Thomas Pun on 7/31/13.
//  Copyright (c) 2013 Thomas Pun. All rights reserved.
//

#import "TCCardCollection.h"
#import <CoreData/CoreData.h>
#import "TCCard.h"

@interface TCCardCollection ()
@property (strong, readwrite, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readwrite, nonatomic) NSArray *sortedCards;
@end


@implementation TCCardCollection
- (TCCardCollection *)initWithManagedContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        self.managedObjectContext = managedObjectContext;
        [self reload];
    }
    return self;
}

- (void)reload
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TCCard"
                                              inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];

    [request setEntity:entity];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:NULL];

    NSError *error = nil;
    self.sortedCards = [self.managedObjectContext executeFetchRequest:request error:&error];
}

@end
