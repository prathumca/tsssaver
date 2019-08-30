//
//  TSSDeviceModelsDataController.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "TSSAPI.h"
#import "TSSUtils.h"

#import "TSSDeviceModelsDataController.h"

@interface TSSDeviceModelsDataController ()
    
@property (nonatomic, readwrite, strong) NSArray* allAvailableDevices;//Including iPhone, iPod, iPad, Apple TV, iWatch, Home Pod, etc..
@property (nonatomic, readwrite, strong) NSArray* allAvailableiDevices;//iPhone/iPod/iPad
    
@end

@implementation TSSDeviceModelsDataController
    
+ (instancetype)sharedInstance {
    static id _sharedManager;
    static dispatch_once_t onceModelsToken;
    dispatch_once(&onceModelsToken, ^{
        _sharedManager = [[[self class] alloc] init];
    });
    return _sharedManager;
}
    
- (void)loadDevices:(void (^ _Nullable )(void))completion {
    NSString* deviceModelsLocation = [TSSUtils devicesModlesFileLocation];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:deviceModelsLocation] == NO) {
//
//    } else {
//        self.allAvailableiDevices = [[NSArray alloc] initWithContentsOfFile:deviceModelsLocation];
//        if (completion) {
//            completion();
//        }
//    }
    __weak __typeof(self)weakSelf = self;
    [[TSSAPI sharedAPI] makeRequest:[NSURL URLWithString:@"https://api.ipsw.me"] endPoint:@"v4/devices" method:GET encoding:JSON headers:@{@"User-Agent" : @"ios", @"Content-Type" : @"application/json;"} body:nil onComplete:^(NSData *data, NSError *error) {
        NSError* jsonError = nil;
        if (error) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:deviceModelsLocation]) {
                self.allAvailableiDevices = [[NSArray alloc] initWithContentsOfFile:deviceModelsLocation];
            }
        } else {
            if (data) {
                weakSelf.allAvailableDevices = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                weakSelf.allAvailableiDevices = [weakSelf.allAvailableDevices filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* dictionary, NSDictionary *bindings) {
                    return ([dictionary[@"name"] containsString:@"iPhone"] || [dictionary[@"name"] containsString:@"iPod"] ||  [dictionary[@"name"] containsString:@"iPad"]);  // Return YES for each object you want in filteredArray.
                }]];
                [weakSelf saveiDevicesToFile];
            }
        }
        if (completion) {
            completion();
        }
    }];
}
    
- (void)loadAvailableOS:(NSString*)identifier completion:(void (^ _Nullable )(NSArray* _Nullable))completion {
    [[TSSAPI sharedAPI] makeRequest:[NSURL URLWithString:@"https://api.ipsw.me"] endPoint:[NSString stringWithFormat:@"v4/device/%@?type=ipsw", identifier] method:GET encoding:JSON headers:nil body:nil onComplete:^(NSData *data, NSError *error) {
        NSError* jsonError = nil;
        if (data) {
            NSDictionary* deviceIPSWDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            NSArray* firmwares = deviceIPSWDetails[@"firmwares"];
            if (completion) {
                completion(firmwares);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}
    
- (void)saveiDevicesToFile {
    if (self.allAvailableiDevices.count > 0) {
        [self.allAvailableiDevices writeToFile:[TSSUtils devicesModlesFileLocation] atomically:YES];
    }
}

//Supply the identifier like iPhone 7,2 and get the model as iPhone 6
- (NSString*)deviceModel:(NSString*)deviceIdentifier {
    for (NSDictionary* device in self.allAvailableiDevices) {
        if ([device[@"identifier"] isEqualToString:deviceIdentifier]) {
            return device[@"name"];
        }
    }
    return [UIDevice currentDevice].model;//worst case scenario
}

@end
