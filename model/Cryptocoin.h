/*
 
 Cryptocoin.h
 
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

#ifndef CRYPTOCOIN_H
#define CRYPTOCOIN_H

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exchange;

/*! Database object for the coin exchange*/
@interface Cryptocoin : NSManagedObject

/// latest buy price
@property (nonatomic, retain) NSNumber * buyPrice;

/// max price
@property (nonatomic, retain) NSNumber * highPrice;

/// coin name
@property (nonatomic, retain) NSString * name;

/// latest sell price
@property (nonatomic, retain) NSNumber * sellPrice;

/// coin symbol
@property (nonatomic, retain) NSString * symbol;

/// updated at
@property (nonatomic, retain) NSDate * updatedAt;

/// exchange market
@property (nonatomic, retain) Exchange *exchange;

@end

#endif