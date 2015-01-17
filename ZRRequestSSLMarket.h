/*
 
 ZRRequestSSLMarket.h
 
 Copyright (c) 17/01/2015 Truong Vinh Tran
 
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

#ifndef ZRREQUEST_SSL_MARKET__H
#define ZRREQUEST_SSL_MARKET__H

#import <Foundation/Foundation.h>
#import "ZRRequestConnector.h"

/*! Class to access the market data, which use SSL*/
@interface ZRRequestSSLMarket : NSObject<NSURLConnectionDelegate>

/** Method to init a new object for calling
 *  @param target is the target class to handle response
 *  @param marketID is the index of the market
 */
- (ZRRequestSSLMarket*)initWithTarget:(id<ZRequestConnectionDelegate>)target market:(NSUInteger)marketID;

/** Method to start the request*/
- (void)start;

/** Method to cancel the reuqest*/
- (void)cancel;

@end

#endif