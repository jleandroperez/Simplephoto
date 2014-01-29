//
//  STAppDelegate.m
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "STAppDelegate.h"



#pragma mark ================================================================================================
#pragma mark Private
#pragma mark ================================================================================================

@interface STAppDelegate ()

@property (readwrite,  strong, nonatomic) NSPersistentStoreCoordinator	*persistentStoreCoordinator;
@property (readwrite,  strong, nonatomic) NSManagedObjectModel			*managedObjectModel;
@property (readwrite,  strong, nonatomic) NSManagedObjectContext		*managedObjectContext;

@end


#pragma mark ================================================================================================
#pragma mark SimplePhoto App Delegate
#pragma mark ================================================================================================

@implementation STAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self setupUserInterface];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveContext];
}


#pragma mark ================================================================================================
#pragma mark Helpers
#pragma mark ================================================================================================

- (void)setupUserInterface
{
    self.window.tintColor = [UIColor whiteColor];	
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext == nil)
	{
		return;
	}
	
	if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

+ (STAppDelegate *)sharedDelegate
{
	return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark ================================================================================================
#pragma mark Core Data stack
#pragma mark ================================================================================================

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
	{
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
	{
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
	{
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimplePhoto" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
	{
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimplePhoto.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
