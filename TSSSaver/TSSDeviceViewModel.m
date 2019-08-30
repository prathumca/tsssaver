//
//  TSSDeviceViewModel.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSString+Utils.h"

#import "TSSUtils.h"

#import "TSSDeviceModelsDataController.h"
#import "TSSDeviceViewModel.h"

@interface TSSDeviceViewModel ()
    
@property (nonatomic, strong) TSSDevice* device;
    
@end

@implementation TSSDeviceViewModel
    
- (instancetype)init:(TSSDevice*)device {
    if (self = [super init]) {
        self.device = device;
    }
    return self;
}
    
- (instancetype)copyWithZone:(nullable NSZone *)zone {
    TSSDeviceViewModel *viewModel = [[TSSDeviceViewModel alloc] init];
    viewModel.device = [self.device copyWithZone:zone];
    return viewModel;
}
    
- (instancetype)initWithDeviceData:(NSDictionary*)deviceData {
    TSSDevice* device = [[TSSDevice alloc] init:deviceData];
    return [self init:device];
}
    
- (NSInteger)udid {
    return self.device.udid;
}
    
- (NSString*)name {
    return self.device.name;
}
    
- (NSString*)type {
    return [[TSSDeviceModelsDataController sharedInstance] deviceModel:self.device.identifier];//self.device.type;
}
    
- (NSString*)identifier {
    return self.device.identifier;
}
    
- (NSString*)ecid {
    return self.device.ecid;
}
    
- (NSString*)descriptiveECID {
    return [NSString stringWithFormat:@"ECID: %@", self.device.ecid];
}
    
- (NSString*)lastUpdated {
    if (self.device.lastUpdated != nil) {
        NSDateFormatter* df = [TSSUtils dateFormatter];
        df.dateStyle = NSDateFormatterLongStyle;
        return [df stringFromDate:self.device.lastUpdated];
    }
    return @"NA";
}
    
- (NSString*)lastUpdated:(NSString*)prefix {
    if (self.device.lastUpdated != nil) {
        NSDateFormatter* df = [TSSUtils dateFormatter];
        df.dateStyle = NSDateFormatterMediumStyle;
        df.timeStyle = kCFDateFormatterShortStyle;
        return [NSString stringWithFormat:@"%@ %@", prefix, [df stringFromDate:self.device.lastUpdated]];
    }
    return [NSString stringWithFormat:@"%@ NA", prefix];
}
    
- (NSString*)boardConfig {
    return self.device.boardConfig;
}
    
- (UIImage*)image {
    return self.device.image;
}
    
- (BOOL)autoUpdate {
    return self.device.isAutoUpdate;
}
    
- (BOOL)showNotification {
    return self.device.isShowNotification;
}
    
- (void)setValue:(id)value forKey:(NSString *)key {
    [self.device setValue:value forKey:key];
}
    
- (NSDictionary*)blobParams {
    return [self.device blobParams];
}

- (UIImage*)deviceImage {
    return [self.device deviceImage];
}

@end
