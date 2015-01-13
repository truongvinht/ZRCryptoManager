/*
 
 Exchange.h
 
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

#ifndef EXCHANGE_H
#define EXCHANGE_H

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**  Database object for the market*/
@interface Exchange : NSManagedObject

/// name of the market
@property (nonatomic, retain) NSString * name;

/// unique ID of the market (URL)
@property (nonatomic, retain) NSString * uuid;

/// coins connected to the market
@property (nonatomic, retain) NSSet *coins;
@end

@interface Exchange (CoreDataGeneratedAccessors)

- (void)addCoinsObject:(NSManagedObject *)value;
- (void)removeCoinsObject:(NSManagedObject *)value;
- (void)addCoins:(NSSet *)values;
- (void)removeCoins:(NSSet *)values;

@end

#endif