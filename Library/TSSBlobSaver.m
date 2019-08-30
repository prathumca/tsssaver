//
//  TSSBlobSaver.m
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "TSSUtils.h"
#import "TSSAPI.h"

#import "TSSBlobSaver.h"

@interface TSSBlob ()
    
@property (nonatomic, strong, readwrite) NSString* urlString;

@end

@implementation TSSBlob
    
- (instancetype)init:(NSString*)urlString {
    if (self = [super init]) {
        self.urlString = urlString;
    }
    return self;
}
    
- (NSURL*)blobURL {
    return [NSURL URLWithString:self.urlString];
}
    
@end

@implementation TSSBlobSaver
    
+ (instancetype)sharedInstance {
    static id _sharedInstance;
    static dispatch_once_t onceBlobSaverToken;
    dispatch_once(&onceBlobSaverToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}
    
- (void)saveBlob:(NSDictionary*)blobParams completion:(void (^)(TSSBlob*, NSError*))completion {
    [[TSSAPI sharedAPI] makeRequest:@"app.php" method:POST encoding:FormURLEncoded headers:nil body:blobParams onComplete:^(NSData *data, NSError *error) {
        if (data == nil) {
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"sssaver.1conan.com" code:9999 userInfo:@{NSLocalizedDescriptionKey : @"Server sent no response."}]);
            }
            return;
        }
        if (error != nil) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        NSError* jsonError = nil;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (jsonError != nil) {
            NSLog(@"************** JSON Error while processing request for SHSH blobs for %@, jsonDict: %@ and error is %@", blobParams, jsonDict, jsonError);
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"************** JSON Error and data string: %@.", dataString);
            if (completion) {
                completion(nil, jsonError);
            }
            return;
        }
        if ([jsonDict[@"success"] boolValue] == false) {
            NSDictionary* errorDict = jsonDict[@"error"];
            NSError *serverError = nil;
            if (errorDict) {
                serverError = [NSError errorWithDomain:@"sssaver.1conan.com" code:[errorDict[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey : errorDict[@"message"], @"error" : errorDict}];
            } else {
                serverError = [NSError errorWithDomain:@"sssaver.1conan.com" code:9997 userInfo:@{NSLocalizedDescriptionKey : @"An unknown error occured."}];
            }
            if (completion) {
                completion(nil, serverError);
            }
            return;
        }
        NSString* urlString = jsonDict[@"url"];
        if (completion) {
            completion([[TSSBlob alloc] init:urlString], error);
        }
    }];
}

@end
