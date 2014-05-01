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
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"

#import <objc/runtime.h>

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

- (id <AFURLRequestSerialization>)requestSerializer {
    return objc_getAssociatedObject(self, @selector(requestSerializer));
}

- (void)setRequestSerializer:(id <AFURLRequestSerialization>)requestSerializer {
    objc_setAssociatedObject(self, @selector(requestSerializer), requestSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <AFURLResponseSerialization>)responseSerializer {
    return objc_getAssociatedObject(self, @selector(responseSerializer));
}

- (void)setResponseSerializer:(id <AFURLResponseSerialization>)responseSerializer {
    objc_setAssociatedObject(self, @selector(responseSerializer), responseSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)registerDefaultsWithURL:(NSURL *)url {
    [self registerDefaultsWithURL:url success:nil failure:nil];
}

- (void)registerDefaultsWithURL:(NSURL *)url
                        success:(void (^)(NSDictionary *defaults))success
                        failure:(void (^)(NSError *error))failure
{
    id <AFURLRequestSerialization> requestSerializer = self.requestSerializer ? self.requestSerializer : [AFPropertyListRequestSerializer serializer];

    NSError *error = nil;
    NSURLRequest *urlRequest = [requestSerializer requestBySerializingRequest:[NSURLRequest requestWithURL:url] withParameters:nil error:&error];
    if (error) {
        if (failure) {
            failure(error);
        }

        return;
    }
    
    [self registerDefaultsWithURLRequest:urlRequest success:^(__unused NSURLRequest *request, __unused NSHTTPURLResponse *response, NSDictionary *defaults) {
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
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = self.responseSerializer ? self.responseSerializer : [AFPropertyListResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setValuesForKeysWithDictionary:responseObject];
        [self synchronize];
        
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error);
        }
    }];
    
    [[[self class] gc_sharedPropertyListRequestOperationQueue] addOperation:requestOperation];
}

@end
