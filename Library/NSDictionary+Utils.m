//
//  NSDictionary+Utils.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSDictionary+Utils.h"

static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

@implementation NSDictionary (Utils)

+(NSString *)urlencode:(NSString *)unencodedString {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}
    
-(NSString*)urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [[self class] urlencode:key], [[self class] urlencode:toString(value)]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}


@end
