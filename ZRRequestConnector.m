/*
 
 ZRRequestConnector.m
 
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

#import "ZRRequestConnector.h"
#import "ZRRequestWalletDataOperation.h"

/// set 10 seconds delay after each request
#define ZREQUEST_DELAY_IN_QUEUE 10

/// number of request: default 1
#define ZREQUEST_NUMBER_OF_SIMULTANEOS_REQUEST 1

@interface ZRRequestConnector ()

/// operation queue for server requests
@property(nonatomic,strong) NSOperationQueue *requestQueue;

@end

@implementation ZRRequestConnector

+ (ZRRequestConnector*)sharedInstance{
    
    //create singleton instance
    static dispatch_once_t predicate = 0;
    
    static ZRRequestConnector *instance = nil;
    
    dispatch_once(&predicate,^{
        instance = [[self alloc] init];
        instance.requestQueue = [[NSOperationQueue alloc] init];
        
        //set limit for simultaneos request
        [instance.requestQueue setMaxConcurrentOperationCount:ZREQUEST_NUMBER_OF_SIMULTANEOS_REQUEST];
    });
    return instance;
}

#pragma mark - Wallet Methods


- (void)requestWalletValue:(NSString*)symbol forAddress:(NSString*)address{
    
    //no delegate set
    if (!_delegate) {
        return;
    }
    
    // invalid symbol
    if (!symbol || [symbol length]<2) {
        
        NSError *error = [NSError errorWithDomain:@"Invalid Symbol for Wallet request" code:ZRRequesErrorInvalidSymbol userInfo:nil];
        
        //forward error to main
        if ([_delegate respondsToSelector:@selector(didFailedReceivingWalletData:)]) {
            [_delegate didFailedReceivingWalletData:error];
        }
        return;
    }
    
    // invalid symbole
    if (!address || [address length]<=0) {
        
        NSError *error = [NSError errorWithDomain:@"Invalid address for Wallet request" code:ZRequestErrorInvalidAddress userInfo:nil];
        
        //forward error to main
        if ([_delegate respondsToSelector:@selector(didFailedReceivingWalletData:)]) {
            [_delegate didFailedReceivingWalletData:error];
        }
        return;
    }
    
    //load the wallet explorer dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WalletSource" ofType:@"plist"];
    NSDictionary *walletDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *walletMetaData = [walletDictionary objectForKey:symbol];
    
    if (walletMetaData) {
        // wallet data available
        ZRRequestWalletDataOperation *operation = [[ZRRequestWalletDataOperation alloc] initWithTarget:_delegate address:[NSString stringWithFormat:[walletMetaData objectForKey:@"url"],address]];
        operation.address = address;
        [_requestQueue addOperation:operation];
        
    }else{
        //symbole not defined
        NSError *error = [NSError errorWithDomain:@"Symbol not supported" code:ZRequestErrorNotSupportSymbol userInfo:nil];
        
        //forward error to main
        if ([_delegate respondsToSelector:@selector(didFailedReceivingWalletData:)]) {
            [_delegate didFailedReceivingWalletData:error];
        }
        
        return;
    }
}


- (void)cancelAllWalletRequest{
    [self.requestQueue cancelAllOperations];
}

@end
