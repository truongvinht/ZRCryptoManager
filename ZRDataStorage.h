/*
 
 ZRDataStorage.h
 
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

#ifndef ZRDATA_STORAGE__H
#define ZRDATA_STORAGE__H

#ifndef ZRDATA_DB_FOLDER
#define ZRDATA_DB_FOLDER @"data"
#endif

#ifndef ZRDATA_DB_PATH
#define ZRDATA_DB_PATH @"zrcryptoDB.sqlite"
#endif

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//import the model objects
#import "Wallet.h"
#import "Exchange.h"
#import "Cryptocoin.h"

/*! Class to handle all data storage*/
@interface ZRDataStorage : NSObject

/// context for accessing data
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/// mapping db-model to the objects
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/// coordinator for persisting the DB
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** Singleton method to access the data storage
 *  @return singleton instance
 */
+ (ZRDataStorage*)sharedInstance;

/** Class method to find all objects for given key
 *  @param obj is the searching object class
 *  @param key is the search key
 *  @param value is the content for the key
 */
+ (NSArray*)fetchAll:(NSString*)obj withKey:(NSString*)key forValue:(NSString*)value;

#pragma mark - Wallet

/** Method to add a new wallet address into DB
 *  @param walletData is the dictionary with all wallet informations
 *  @return true is the wallet could be added
 */
- (BOOL)addWallet:(NSDictionary*)walletData;

/** Method to update wallet object in the DB
 *  @param walletData is the dictionary with all wallet informations
 *  @return true is the wallet could be updated
 */
- (BOOL)updateWallet:(NSDictionary*)walletData;

/** Method to remove a saved db object
 *  @param managedObject is target object for deleting
 */
- (void)removeObject:(NSManagedObject*)managedObject;

#pragma mark - Market

/** Method to add a new market to the DB
 *  @param marketData is the dictionary with all market informations
 *  @return true if the market could be added
 */
- (BOOL)addMarket:(NSDictionary*)marketData;

/** Method to add exchanges for target market
 *  @param list is an array with exchanges as dictionary
 *  @param uuid is the id of the market
 *  @return true if the exchanges could be added
 */
- (BOOL)addExchanges:(NSArray*)list inMarket:(NSString*)uuid;
@end

#endif