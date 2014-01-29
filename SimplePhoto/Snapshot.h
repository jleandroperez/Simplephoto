//
//  Snapshot.h
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Snapshot : NSManagedObject

@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSDate * date;

@end
