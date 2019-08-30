//
//  TSSDevice.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSString+Utils.h"

#import "TSSDevice.h"
#import "TSSUtils.h"

#define numbersCharSet [NSCharacterSet characterSetWithCharactersInString:@"0123456789"]

@implementation TSSDevice
    
- (instancetype)init:(NSDictionary*)dictionary {
    if (self = [super init]) {
        self.udid = dictionary[@"udid"]? [dictionary[@"udid"] integerValue] : -1;
        self.name = dictionary[@"name"]? dictionary[@"name"] : @"My iPhone X";
        self.type = dictionary[@"type"]? dictionary[@"type"] : @"iPhone X";
        self.identifier = dictionary[@"identifier"]? dictionary[@"identifier"] : @"iPhone 10,3";
        self.ecid = dictionary[@"ecid"]? dictionary[@"ecid"] : @"1234567890";
        self.boardConfig = dictionary[@"boardconfig"]? dictionary[@"boardconfig"] : @"d22ap";
        self.lastUpdated = dictionary[@"lastUpdated"];
        self.autoUpdate = [dictionary[@"autoUpdate"] boolValue];
        self.showNotification = [dictionary[@"showNotifications"] boolValue];
        self.lastiOS = dictionary[@"lastiOS"]? [dictionary[@"lastiOS"] integerValue] : 0;
    }
    return self;
}
    
- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    dictionary[@"udid"] = self.udid > 0?@(self.udid) : @(-1);
    dictionary[@"name"] = self.name?self.name : @"NA";
    dictionary[@"type"] = self.type?self.type : @"NA";
    dictionary[@"identifier"] = self.identifier?self.identifier : @"NA";
    dictionary[@"ecid"] = self.ecid?self.ecid : @"NA";
    dictionary[@"boardconfig"] = self.boardConfig?self.boardConfig : @"NA";
    dictionary[@"lastUpdated"] = self.lastUpdated?self.lastUpdated : [NSDate date];
    dictionary[@"autoUpdate"] = @(self.autoUpdate);
    dictionary[@"showNotifications"] = @(self.isShowNotification);
    dictionary[@"lastiOS"] = self.lastiOS > 0?@(self.lastiOS) : @(0);
    return dictionary;
}
    
- (instancetype)copyWithZone:(nullable NSZone *)zone {
    TSSDevice *device = [[TSSDevice alloc] init];
    device.udid = [self udid];
    device.name = [[self name] copy];
    device.type = [[self type] copy];
    device.identifier = [[self identifier] copy];
    device.ecid = [[self ecid] copy];
    device.boardConfig = [[self boardConfig] copy];
    device.lastUpdated = [[self lastUpdated] copy];
    device.autoUpdate = self.isAutoUpdate;
    device.showNotification = self.isShowNotification;
    device.lastiOS = [self lastiOS];
    return device;
}
    
- (nullable id)valueForUndefinedKey:(NSString *)key {
    return nil;
}
    
- (NSDictionary*)blobParams {
    return @{@"ecid" : [self.ecid decimalString], @"boardConfig": self.boardConfig, @"deviceID": self.identifier};
}

- (NSUInteger)hash {
    return [self.ecid hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        TSSDevice* compDevice = (TSSDevice*)object;
        return [compDevice.ecid isEqualToString:self.ecid] && [compDevice.identifier isEqualToString:self.identifier] && [compDevice.boardConfig isEqualToString:self.boardConfig];
    }
    return NO;
}

// See the `Hardware strings` in https://en.wikipedia.org/wiki/List_of_iOS_devices
- (BOOL)isNotchiPhone {
    if ([self.identifier isEqualToString:@"iPhone10,3"] || [self.identifier isEqualToString:@"iPhone10,6"] || // iPhone X
        [self.identifier isEqualToString:@"iPhone11,2"] || [self.identifier isEqualToString:@"iPhone11,4"] || [self.identifier isEqualToString:@"iPhone11,6"] || // iPhone XS (Max)
        [self.identifier isEqualToString:@"iPhone11,8"]) { // iPhone XR
        return YES;
    } else {
        NSString* modelString = [[self.identifier componentsSeparatedByString:@","] firstObject];
        NSScanner *scanner = [NSScanner scannerWithString:modelString];
        
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbersCharSet intoString:NULL];
        
        // Collect numbers.
        NSString* modelNumberString;
        [scanner scanCharactersFromSet:numbersCharSet intoString:&modelNumberString];
        return modelNumberString.integerValue >= 11;
    }
    return NO;
}

- (BOOL)isiPad {
    NSString* modelString = [[self.identifier componentsSeparatedByString:@","] firstObject];
    return [modelString hasPrefix:@"iPad"];
}

- (UIImage*)deviceImage {
    if ([self isNotchiPhone]) {
        return [UIImage imageNamed:@"iPhone_X"];
    }
    if ([self isiPad]) {
        return [UIImage imageNamed:@"iPad"];
    }
    return [UIImage imageNamed:@"iPhone"];
}

@end
