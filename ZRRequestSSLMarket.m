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

#import "ZRRequestSSLMarket.h"

@interface ZRRequestSSLMarket ()

/// actual connection
@property(nonatomic,strong) NSURLConnection *connection;

/// index of the market from the list
@property(nonatomic,readwrite) NSUInteger marketID;

///target for handling response
@property(nonatomic,weak) id<ZRequestConnectionDelegate> delegate;

/// receiving data
@property(nonatomic,strong) NSMutableData *receive;

@end

@implementation ZRRequestSSLMarket

- (ZRRequestSSLMarket*)initWithTarget:(id<ZRequestConnectionDelegate>)target market:(NSUInteger)marketID{
    self = [super init];
    
    if (self) {
        _delegate = target;
        _marketID = marketID;
    }
    return self;
    
}

- (void)start{
    //load the market explorer dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:ZREQ_MARKET_LIST_PLIST ofType:@"plist"];
    NSArray *marketList = [NSArray arrayWithContentsOfFile:path];
    
    //check missing information
    if (!_delegate||[marketList count]<_marketID) {
        return;
    }
    
    //read the market URL
    NSDictionary *selectedMarket = [marketList objectAtIndex:_marketID];
    NSString *serverURL = [selectedMarket objectForKey:@"url"];
    
    //start server request
    NSMutableURLRequest *quotesRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                             timeoutInterval:ZREQ_CONNECTION_TIMEOUT];
    
    [quotesRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    // Create url connection and fire request
    _connection = [[NSURLConnection alloc] initWithRequest:quotesRequest delegate:self startImmediately:YES];
}

- (void)cancel{
    if (_connection) {
        [_connection cancel];
        _connection = nil;
    }
}

#pragma mark - NSURL Connection delegate methods

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
   [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    //NSLog(@"response %@",response);
    _receive = [NSMutableData data];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    
    [_receive appendData:data];

}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    if ([_delegate respondsToSelector:@selector(didFailedReceivingMarketData:)]) {
        [_delegate didFailedReceivingMarketData:error];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    
    
    //forward information
    if ([_delegate respondsToSelector:@selector(didReceiveMarketData:market:)]) {
        [_delegate didReceiveMarketData:_receive market:_marketID];
    }
    connection = nil;
}

@end
