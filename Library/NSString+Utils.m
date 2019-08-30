//
//  NSString+Utils.m
//  TSSSaver
//
//  Created by Prathap Dodla on 12/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
    
- (NSString*)hexString {
    if ([self integerValue] > 0) {
        return [NSString stringWithFormat:@"%lX", (unsigned long)[self integerValue]];
    }
    return self;
}
    
- (NSString*)decimalString {
    NSInteger hextVal = 0;
    NSInteger length = [self length];
    for (NSInteger i = 0; i < length; i++) {
        NSString *hex = [self substringWithRange:NSMakeRange(i, 1)];
        int decimalValue = 0;
        sscanf([hex UTF8String], "%x", &decimalValue);
        hextVal += decimalValue * pow(16, length - 1 - i);
    }
    return [NSString stringWithFormat:@"%ld", (long)hextVal];
}

@end
