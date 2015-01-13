/*
 
 ZRRequestConnector.h
 
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

#ifndef ZREQ_CONNECTION__H
#define ZREQ_CONNECTION__H

#import <Foundation/Foundation.h>

/// enum for the error code
typedef enum{
    /// invalid symbol
    ZRRequesErrorInvalidSymbol = 1,
    ZRequestErrorInvalidAddress = 2,
    ZRequestErrorNotSupportSymbol = 3
}ZRequestError;

#ifndef ZREQ_WALLET_SOURCE_PLIST
#define ZREQ_WALLET_SOURCE_PLIST @"WalletSource"
#endif

/*! Protocol to handle callbacks*/
@protocol ZRequestConnectionDelegate <NSObject>

@optional
/** Method will be called after request for wallet information was successful
 *  @param walletData contains requested data
 */
- (void)didReceiveWalletData:(NSDictionary*)walletData;

/** Method will be called after request for wallet failed
 *  @param error contains the error for the failed request
 */
- (void)didFailedReceivingWalletData:(NSError*)error;

@end

/*! Class to handle all network connection*/
@interface ZRRequestConnector : NSObject

/// target to responds on responds
@property(nonatomic,weak) id<ZRequestConnectionDelegate> delegate;


/** Access singleton shared instance of the connector
 *  @return singleton instance
 */
+ (ZRRequestConnector*)sharedInstance;

/** Method to trigger a request to get latest value of the target wallet
 *  @param symbole is the cryptocoin symbole
 *  @param address is the target wallet address
 */
- (void)requestWalletValue:(NSString*)symbole forAddress:(NSString*)address;

/** Method to cancel all wallet balance requests
 */
- (void)cancelAllWalletRequest;
@end

#endif
