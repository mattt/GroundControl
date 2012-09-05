// NSUserDefaults+GroundControl.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSUserDefaults+GroundControl.h"


@interface NSUserDefaults (_GroundControl)
+ (NSOperationQueue *)gc_sharedPropertyListRequestOperationQueue;
@end

@implementation NSUserDefaults (GroundControl)

+ (NSOperationQueue *)gc_sharedPropertyListRequestOperationQueue {
    static NSOperationQueue *_sharedPropertyListRequestOperationQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPropertyListRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_sharedPropertyListRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _sharedPropertyListRequestOperationQueue;
}


- (void)registerDefaultsWithURL:(NSURL *)url {
    [self registerDefaultsWithURL:url success:nil failure:nil];
}

- (void)registerDefaultsWithURL:(NSURL *)url
                        success:(void (^)(NSDictionary *defaults))success
                        failure:(void (^)(NSError *error))failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
    
    [self registerDefaultsWithURLRequest:request success:^(__unused NSURLRequest *request, __unused NSHTTPURLResponse *response, NSDictionary *defaults) {
        if (success) {
            success(defaults);
        }
    } failure:^(__unused NSURLRequest *request, __unused NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)registerDefaultsWithURLRequest:(NSURLRequest *)urlRequest
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *defaults))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[self class] gc_sharedPropertyListRequestOperationQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        if (!error) {
            NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                        
            NSDictionary *myDictionary = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] propertyListFromStringsFileFormat];
            
            [self registerDefaults:myDictionary];
            [self synchronize];
            
            success(urlRequest, (NSHTTPURLResponse *)response, myDictionary);
        }
        else failure(urlRequest, (NSHTTPURLResponse *)response, error);
        
    }];}

@end
