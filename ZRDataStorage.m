/*
 
 ZRDataStorage.m
 
 Copyright (c) 13/01/2015 Truong Vinh Tran
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "ZRDataStorage.h"
#import "ZRRequestConnector.h"

@interface ZRDataStorage ()

/// data model
@property(nonatomic,strong) NSManagedObjectModel *managedObjectModel;

/// persistent coordinator
@property(nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/// context for database
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ZRDataStorage

+ (ZRDataStorage*)sharedInstance{
    
    //create singleton instance
    static dispatch_once_t predicate = 0;
    
    static ZRDataStorage *instance = nil;
    
    dispatch_once(&predicate,^{
        instance = [[self alloc] init];
        
        
    });
    return instance;
}

/** Method to access the path to the home directory
 @return the path as string
 */
- (NSString*)getDocumentDirectory{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

#pragma mark - Core Data init

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
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

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ZRCryptModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[NSURL fileURLWithPath:[self getDocumentDirectory]] URLByAppendingPathComponent:ZRDATA_DB_PATH];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Use lightweight migration for new Core Data model versions.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"LocalFMStore#%@: Unresolved error %@, %@",NSStringFromSelector(_cmd), error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - private Core Data methods

/** Method to save the context to file
 */
- (BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    BOOL saved = NO;
    
    if (managedObjectContext != nil)
    {
        saved = [managedObjectContext save:&error];
        
        if ([managedObjectContext hasChanges] && !saved)
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"LocalFMStore#%@: Unresolved error %@, %@",NSStringFromSelector(_cmd), error, [error userInfo]);
            abort();
        }
    }
    return saved;
}

/** Method to clean up the context
 */
- (void)clearContext
{
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
}

#pragma mark - Find methods

+ (NSArray*)fetchAll:(NSString*)obj withKey:(NSString*)key forValue:(NSString*)value{
    
    // invalid find input
    if (value == nil || [value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    // value is too short
    if ([value length]==0) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:obj inManagedObjectContext:[[ZRDataStorage sharedInstance] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@",key, value];
    [fetchRequest setPredicate:predicate];
    
    NSError *error =  nil;
    NSArray *items = [[[ZRDataStorage sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([items count] > 0) {
        return items;
    }
    else {
        /// no result found
        return [NSArray array];
    }
}

#pragma mark - Wallet Methods

- (BOOL)addWallet:(NSDictionary *)walletData{
    
    //create a parent context for merge
    Wallet *wallet = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Wallet class]) inManagedObjectContext:[self managedObjectContext]];
    wallet.address = [walletData objectForKey:@"address"];
    wallet.type = [walletData objectForKey:@"symbol"];
    wallet.label = [walletData objectForKey:@"label"];
    wallet.updatedAt = nil;
    return [self saveContext];
}

- (BOOL)updateWallet:(NSDictionary*)walletData{
    
    NSArray *objects = [ZRDataStorage fetchAll:@"Wallet" withKey:@"address" forValue:[walletData objectForKey:@"address"]];
    
    if ([objects count]==0) {
        return NO;
    }
    
    Wallet *wallet = [objects lastObject];
    wallet.updatedAt = [NSDate date];
    
    // update label
    if ([walletData objectForKey:@"label"]) {
        wallet.label = [walletData objectForKey:@"label"];
    }
    
    if ([walletData objectForKey:@"amount"]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:ZREQ_WALLET_SOURCE_PLIST ofType:@"plist"];
        NSDictionary *walletDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSDictionary *walletMetaData = [walletDictionary objectForKey:wallet.type];
        
        double factor = 1;
        
        //multiplier for the currency
        if ([walletMetaData objectForKey:@"factor"]) {
            factor = [[walletMetaData objectForKey:@"factor"] doubleValue];
        }
        
        wallet.amount = [NSNumber numberWithDouble:[[walletData objectForKey:@"amount"] doubleValue]*factor];
    }
    
    return [self saveContext];
}

- (void)removeWallet:(Wallet *)wallet{
    [[self managedObjectContext] deleteObject:wallet];
    [self saveContext];
}

@end
