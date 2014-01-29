//
//  STAppDelegate.h
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>



#pragma mark ================================================================================================
#pragma mark SimplePhoto App Delegate
#pragma mark ================================================================================================

@interface STAppDelegate : UIResponder <UIApplicationDelegate>

@property (readwrite, strong, nonatomic) UIWindow						*window;
@property (readonly,  strong, nonatomic) NSPersistentStoreCoordinator	*persistentStoreCoordinator;
@property (readonly,  strong, nonatomic) NSManagedObjectModel			*managedObjectModel;
@property (readonly,  strong, nonatomic) NSManagedObjectContext			*managedObjectContext;

- (void)saveContext;

+ (STAppDelegate *)sharedDelegate;

@end
