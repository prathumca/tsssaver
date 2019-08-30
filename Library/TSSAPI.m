//
//  TSSAPI.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSDictionary+Utils.h"

#import "TSSAPI.h"

@interface TSSAPI ()
    
@property (nonatomic, strong) NSURL* baseURL;
    
@end

@implementation TSSAPI
    
- (instancetype)init:(NSURL*)baseURL {
    if (self = [super init]) {
        self.baseURL = baseURL;
    }
    return self;
}
    
+ (instancetype)sharedAPI {
    static id _sharedAPI;
    static dispatch_once_t onceAPIToken;
    dispatch_once(&onceAPIToken, ^{
        NSURL* baseURL = [NSURL URLWithString:@"https://tsssaver.1conan.com"];
        _sharedAPI = [[[self class] alloc] init:baseURL];
    });
    return _sharedAPI;
}
    
- (NSString*)httpMethodDescription:(HTTPMethod)method {
    switch (method) {
        case GET:
            return @"GET";
            break;
        case POST:
            return @"POST";
            break;
        case PUT:
            return @"POST";
            break;
        case DELETE:
            return @"DELETE";
            break;
        case OPTIONS:
            return @"OPTIONS";
            break;
        default:
            return @"GET";
            break;
    }
}
    
- (NSData*)encode:(NSDictionary*)data parameterEncoding:(ParameterEncoding)encoding {
    switch (encoding) {
        case FormURLEncoded:
            return [[data urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
            break;
        case JSON:
            return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
            break;
    }
}
    
- (NSString*)contentType:(ParameterEncoding)encoding {
    switch (encoding) {
        case FormURLEncoded:
            return @"application/x-www-form-urlencoded; charset=utf-8";
            break;
        case JSON:
            return @"application/json; charset=utf-8";
            break;
    }
}
    
- (NSString*)userAgent {
    NSString* userAgentString = @"App";
    NSString* bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (bundleDisplayName == nil) {
        bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    if (bundleDisplayName != nil) {
        userAgentString = bundleDisplayName;
    }
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (version != nil) {
        
    }
    return userAgentString;
}
    
- (void)makeRequest:(NSURL*)url endPoint:(NSString*)endPoint method:(HTTPMethod)method encoding:(ParameterEncoding)encoding headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(NSData* data, NSError* error))complete {
    NSString* finalURL = [NSString stringWithFormat:@"%@/%@", [url absoluteString], endPoint];
    finalURL = [finalURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    request.HTTPMethod = [self httpMethodDescription:method];
    if (body) {
        request.HTTPBody = [self encode:body parameterEncoding:encoding];
    }
    [request addValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    NSString* content = [self contentType:encoding];
    if (content) {
        [request addValue:content forHTTPHeaderField:@"Content-Type"];
    }
    for (NSString* key in headers.allKeys) {
        [request addValue:headers[key] forHTTPHeaderField:key];
    }
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            if (complete) {
                complete(data, error);
            }
        } else {
            if (complete) {
                complete(nil, error);
            }
        }
    }];
    [sessionDataTask resume];
}
    
- (void)makeRequest:(NSString*)endPoint method:(HTTPMethod)method encoding:(ParameterEncoding)encoding headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(NSData* data, NSError* error))complete {
    [self makeRequest:self.baseURL endPoint:endPoint method:method encoding:encoding headers:headers body:body onComplete:complete];
}
    
- (void)makeJSONRequest:(NSString*)endPoint method:(HTTPMethod)method headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(id, NSError*))complete {
    [self makeRequest:endPoint method:method encoding:JSON headers:headers body:body onComplete:^(NSData *data, NSError *error) {
        if (data != nil) {
            NSError* jsonError = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (complete) {
                complete(result, jsonError);
            }
        } else {
            if (complete) {
                complete(nil, error);
            }
        }
    }];
}
    
- (void)makeJSONRequest:(NSString*)urlString endPoint:(NSString*)endPoint method:(HTTPMethod)method headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(id data, NSError* error))complete {
    NSURL* url = [NSURL URLWithString:urlString];
    if (url) {
        [self makeRequest:url endPoint:endPoint method:method encoding:JSON headers:headers body:body onComplete:^(NSData *data, NSError *error) {
            if (data != nil) {
                NSError* jsonError = nil;
                id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (complete) {
                    complete(result, jsonError);
                }
            } else {
                if (complete) {
                    complete(nil, error);
                }
            }
        }];
    } else {
        if (complete) {
            complete(nil, [NSError errorWithDomain:@"iarrays.com" code:1001 userInfo:@{NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"Invalid URL '%@'.", urlString]}]);
        }
    }
}

@end
