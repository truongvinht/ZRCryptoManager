/*
 
 ZRRquestMarketDataOperation.m
 
 Copyright (c) 14/01/2015 Truong Vinh Tran
 
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

#import "ZRRequestMarketDataOperation.h"

@interface ZRRequestMarketDataOperation ()

/// target for callback
@property(nonatomic,weak) id<ZRequestConnectionDelegate> target;

/// flag for execution status
@property(nonatomic,readwrite) BOOL execute, finishing;

/// target market for data
@property(nonatomic,readonly) NSUInteger market;

@end

@implementation ZRRequestMarketDataOperation

- (ZRRequestMarketDataOperation*)initWithTarget:(id<ZRequestConnectionDelegate>)target market:(NSUInteger)market{
    self = [super init];
    
    //init
    if (self) {
        
        //init status to false
        _execute = _finishing = NO;
        
        _target = target;
        _market = market;
        
    }
    return self;
}

- (void)dealloc{
    _target = nil;
}

- (void)main{
    
    //load the wallet explorer dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:ZREQ_MARKET_LIST_PLIST ofType:@"plist"];
    NSArray *marketList = [NSArray arrayWithContentsOfFile:path];
    
    //check missing information
    if (!_target||[marketList count]<_market) {
        return;
    }
    
    //operation started
    [self setOperationStarted:YES];
    
    //update status
    [self willChangeValueForKey:@"isFinished"];
    _finishing = NO;
    [self didChangeValueForKey:@"isFinished"];
    
    if ([self isCancelled]) {
        return;
    }
    
    // Set executing state in KVO-compliance.
    [self willChangeValueForKey:@"isExecuting"];
    _execute = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    //read the market URL
    NSDictionary *selectedMarket = [marketList objectAtIndex:_market];
    NSString *serverURL = [selectedMarket objectForKey:@"url"];
    
    //start server request
    NSMutableURLRequest *quotesRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                             timeoutInterval:30.0f];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *requestedData = [NSURLConnection sendSynchronousRequest:quotesRequest returningResponse:&response error:&error];
    
    //check wether request is succssful
    if (requestedData == nil || error != nil) {
        NSLog(@"**ERROR GETTING QUOTES** (%@) with error: %@ ", [quotesRequest URL], error);
        
        if ([_target respondsToSelector:@selector(didFailedReceivingMarketData:)]) {
            [_target didFailedReceivingMarketData:error];
        }
        
        // Set executing and finished states in KVO-compliance.
        [self willChangeValueForKey:@"isExecuting"];
        _execute = NO;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self willChangeValueForKey:@"isFinished"];
        _finishing = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    //forward information
    if ([_target respondsToSelector:@selector(didReceiveMarketData:market:)]) {
        [_target didReceiveMarketData:requestedData market:_market];
    }
    
    
    // Set executing and finished states in KVO-compliance.
    [self willChangeValueForKey:@"isExecuting"];
    _execute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finishing = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)cancel {
    
    //check wether operation started
    if (![self isOperationStarted]) {
        return;
    }
    
    // Set executing and finished states in KVO-compliance.
    [self willChangeValueForKey:@"isExecuting"];
    _execute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finishing = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [super cancel]; // Don't forget to call cancel on superclass.
}

@end
