/*
 
 ZRRequestWalletDataOperation.m
 
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

#import "ZRRequestWalletDataOperation.h"

@interface ZRRequestWalletDataOperation ()

/// target for callback
@property(nonatomic,weak) id<ZRequestConnectionDelegate> target;

/// address for the request
@property(nonatomic,strong) NSURL *url;

/// flag for execution status
@property(nonatomic,readwrite) BOOL execute, finishing;

@end

@implementation ZRRequestWalletDataOperation

- (ZRRequestWalletDataOperation*)initWithTarget:(id<ZRequestConnectionDelegate>)target address:(NSString*)address{
    self = [super init];
    
    //init
    if (self) {
        
        //init status to false
        _execute = _finishing = NO;
        
        _target = target;
        _url = [NSURL URLWithString:address];
        
        
    }
    return self;
}

- (void)dealloc{
    _target = nil;
    _url = nil;
    _address = nil;
}

- (void)main{
    
    //check missing information
    if (!_target || !_url) {
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
    
    //start server request
    NSMutableURLRequest *quotesRequest = [NSMutableURLRequest requestWithURL:_url
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                             timeoutInterval:ZREQ_CONNECTION_TIMEOUT];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *requestedData = [NSURLConnection sendSynchronousRequest:quotesRequest returningResponse:&response error:&error];

    //check wether request is succssful
    if (requestedData == nil || error != nil) {
        NSLog(@"**ERROR GETTING QUOTES** (%@) with error: %@ ", [quotesRequest URL], error);
        
        if ([_target respondsToSelector:@selector(didFailedReceivingWalletData:)]) {
            [_target didFailedReceivingWalletData:error];
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
    
    //try to extract the data as JSON
    id quotes = [NSJSONSerialization JSONObjectWithData:requestedData options:NSJSONReadingMutableContainers error:&error];
    
    NSMutableDictionary *responseData = nil;
    
    //check wether its an array
    if ([[quotes class] isSubclassOfClass:[NSArray class]]) {
        responseData = [NSMutableDictionary dictionaryWithDictionary:[quotes lastObject]];
    }
    
    //check wether response is a dictionary
    if ([[quotes class] isSubclassOfClass:[NSDictionary class]]) {
        responseData = [NSMutableDictionary dictionaryWithDictionary:quotes];
    }
    
    
    //parse it as string
    if (!responseData) {
        
        responseData = [NSMutableDictionary dictionary];
        
        NSString *response =[[NSString alloc] initWithData:requestedData encoding:NSUTF8StringEncoding];
        
        //remove quotes
        [responseData setObject:[response stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"value"];
    }
    
    //assign address
    [responseData setObject:_address forKey:@"address"];
    
    //forward information
    if ([_target respondsToSelector:@selector(didReceiveWalletData:)]) {
        [_target didReceiveWalletData:responseData];
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
