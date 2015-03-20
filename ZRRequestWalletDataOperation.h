/*
 
 ZRRequestWalletDataOperation.h
 
 Copyright (c) 12/01/2015 Truong Vinh Tran
 
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

#ifndef ZRREQ_WALLETDATA_OPERATION__H
#define ZRREQ_WALLETDATA_OPERATION__H

//short time out for the requests
#ifndef ZRREQ_WALLET_SHORT_TIMEOUT
#define ZRREQ_WALLET_SHORT_TIMEOUT 30
#endif

//acceptable range for requests
#ifndef ZRREQ_STATUS_MIN
#define ZRREQ_STATUS_MIN 200
#endif

#ifndef ZRREQ_STATUS_MAX
#define ZRREQ_STATUS_MAX 300
#endif

#import <Foundation/Foundation.h>
#import "ZRRequestConnector.h"

/*! Operation to execute the server request to read the wallet data*/
@interface ZRRequestWalletDataOperation : NSOperation

/// flag for the operation status
@property (nonatomic,assign,getter = isOperationStarted) BOOL operationStarted;

/// wallet address
@property(nonatomic,copy) NSString *address;

/** init new instance with target for handle finish
 *  @param target is the object to handle callback
 *  @param address is the url for the request
 */
- (ZRRequestWalletDataOperation*)initWithTarget:(id<ZRequestConnectionDelegate>)target address:(NSString*)address;

@end

#endif