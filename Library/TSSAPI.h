//
//  TSSAPI.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HTTPMethod) {
    GET,
    DELETE,
    OPTIONS,
    POST,
    PUT
};

typedef NS_ENUM(NSInteger, ParameterEncoding) {
    FormURLEncoded,
    JSON
};

@interface TSSAPI : NSObject
    
+ (instancetype)sharedAPI;
    
- (void)makeRequest:(NSURL*)url endPoint:(NSString*)endPoint method:(HTTPMethod)method encoding:(ParameterEncoding)encoding headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(NSData* data, NSError* error))complete;
- (void)makeRequest:(NSString*)endPoint method:(HTTPMethod)method encoding:(ParameterEncoding)encoding headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(NSData* data, NSError* error))complete;
- (void)makeJSONRequest:(NSString*)endPoint method:(HTTPMethod)method headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(id data, NSError* error))complete;
- (void)makeJSONRequest:(NSString*)urlString endPoint:(NSString*)endPoint method:(HTTPMethod)method headers:(NSDictionary*)headers body:(NSDictionary*)body onComplete:(void (^)(id data, NSError* error))complete;

@end
