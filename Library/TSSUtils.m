//
//  TSSUtils.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <objc/runtime.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/utsname.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "dlfcn.h"

#import <UIKit/UIKit.h>
#if !TARGET_OS_SIMULATOR
#import <IOKit/IOKitLib.h>
#endif

#include "math.h"
#import "TSSUtils.h"
#import "NSString+Utils.h"
#import "TSSDevice.h"
#import "TSSBlobSaver.h"
#import "TSSDeviceModelsDataController.h"

static UIImage* tssImage = nil;

@implementation TSSUtils
    
+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding];
}
    
+ (NSString *)sysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}
    
+ (NSString *)deviceModel {
    return [self sysInfoByName:"hw.machine"];
}
    
+ (NSString *)boardConfig {
    return [self sysInfoByName:"hw.model"];
}
    
+ (NSString *)ecid {
#if !TARGET_OS_SIMULATOR
    CFMutableDictionaryRef matching = IOServiceMatching("IOPlatformExpertDevice");
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    if (!service) {
        NSLog(@"unable to find platform expert service");
        return NULL;
    }
    
    CFDataRef ecidData = IORegistryEntrySearchCFProperty(service, kIODeviceTreePlane, CFSTR("unique-chip-id"), kCFAllocatorDefault, kIORegistryIterateRecursively);
    if (!ecidData) {
        NSLog(@"unable to find unique-chip-id property");
        IOObjectRelease(service);
        return NULL;
    }
    
    const UInt8 *bytes = CFDataGetBytePtr(ecidData);
    UInt64* b = (UInt64*)bytes;
    CFStringRef ecidString = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%llu"),*b);
    CFRelease(ecidData);
    IOObjectRelease(service);
    return (__bridge NSString*)ecidString;
#endif
    return @"7349540021076014";
}
    
+ (NSString*)devicesFileLocation {
    if ([self isRunningOnSandbox]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        return [documentsDirectory stringByAppendingPathComponent:@"com.iarrays.tsssaver-devices.plist"];
    }
    return @"/var/mobile/Library/Preferences/com.iarrays.tsssaver-devices.plist";
}
    
+ (NSString*)devicesModlesFileLocation {
    if ([self isRunningOnSandbox]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        return [documentsDirectory stringByAppendingPathComponent:@"com.iarrays.tsssaver-device-models.plist"];
    }
    return @"/var/mobile/Library/Preferences/com.iarrays.tsssaver-device-models.plist";
}
    
+ (BOOL)isRunningOnSandbox {
    return ([[[NSBundle mainBundle] resourcePath] containsString:@"/var/mobile/Applications/"] || [[[NSBundle mainBundle] resourcePath] containsString:@"/Containers/Data"] || [[[NSBundle mainBundle] resourcePath] containsString:@"/data/Containers/Bundle/Application/"]);
}

+ (NSDictionary*)currentDeviceData {
    NSInteger udid = [[NSDate date] timeIntervalSince1970];
    NSString* deviceModel = self.deviceModel;
    return @{@"udid" : @(udid),
             @"name" : [UIDevice currentDevice].name,
             @"type" : [[TSSDeviceModelsDataController sharedInstance] deviceModel:deviceModel],
             @"identifier": deviceModel,
             @"ecid": [self.ecid hexString],
             @"boardconfig": self.boardConfig,
             @"autoUpdate": @(YES),
             @"showNotifications": @(YES)
             };
}
    
+ (void)addCurrentDevice:(NSString*)devicesLocation {
    [@[[self currentDeviceData]] writeToFile:devicesLocation atomically:YES];
}
    
+ (void)loadStoredDevices:(void (^)(NSArray*))completion {
    NSString* devicesLocation = [self devicesFileLocation];
    if ([[NSFileManager defaultManager] fileExistsAtPath:devicesLocation] == NO) {
        [self addCurrentDevice:devicesLocation];
    }
    NSMutableArray* devicesData = [[NSMutableArray alloc] initWithContentsOfFile:devicesLocation];
    //remove duplicate:- worst case scenario
    //does it have current device?
    BOOL isCurrentDeviceExists = NO;
    for (NSDictionary* device in devicesData) {
        if ([device[@"ecid"] isEqualToString:[self.ecid hexString]]) {
            isCurrentDeviceExists = YES;
            break;
        }
    }
    if (!isCurrentDeviceExists) {
        [devicesData insertObject:[self currentDeviceData] atIndex:0];
    }
    completion([devicesData copy]);
}
    
+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t formatterToken;
    dispatch_once(&formatterToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    return formatter;
}
    
+ (void)saveDeviceToDisk:(NSDictionary*)deviceData {
    [self loadStoredDevices:^(NSArray *devices) {
        NSInteger deviceToUpdateIdx = -1;
        for (NSInteger i = 0; i < devices.count; i++) {
            NSDictionary* device = devices[i];
            if ([device[@"udid"] integerValue] == [deviceData[@"udid"] integerValue]) {
                //then its an update
                deviceToUpdateIdx = i;
                break;
            }
        }
        NSString* devicesLocation = [self devicesFileLocation];
        NSMutableArray* devicesToUpdate = [[NSMutableArray alloc] initWithArray:devices];
        if (deviceToUpdateIdx >= 0) {
            [devicesToUpdate replaceObjectAtIndex:deviceToUpdateIdx withObject:deviceData];
        } else {
            //new list save
            NSInteger udid = [[NSDate date] timeIntervalSince1970];
            ((NSMutableDictionary*)deviceData)[@"udid"] = @(udid);
            [devicesToUpdate addObject:deviceData];
        }
        [devicesToUpdate writeToFile:devicesLocation atomically:YES];
        //post notification
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)TSSSAVER_DEVICE_LIST_UPDATED_NOTIFICATION, nil, nil, TRUE);
    }];
}
    
+ (BOOL)deleteDevice:(NSInteger)udid {
    __block NSInteger deviceToUpdateIdx = -1;
    [self loadStoredDevices:^(NSArray *devices) {
        for (NSInteger i = 0; i < devices.count; i++) {
            NSDictionary* device = devices[i];
            if ([device[@"udid"] integerValue] == udid) {
                deviceToUpdateIdx = i;
                break;
            }
        }
        if (deviceToUpdateIdx >= 0) {
            NSString* devicesLocation = [self devicesFileLocation];
            NSMutableArray* devicesToUpdate = [[NSMutableArray alloc] initWithArray:devices];
            [devicesToUpdate removeObjectAtIndex:deviceToUpdateIdx];
            [devicesToUpdate writeToFile:devicesLocation atomically:YES];
        }
    }];
    return (deviceToUpdateIdx >= 0);
}

+ (void)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(UIImage *)overridBundleImage {
    //get function from RBS
    void* handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/libbulletin.dylib", RTLD_NOW);
    if (handle) {
        NSLog(@"****** [JBBulletinManager sharedInstance]: %@", [objc_getClass("JBBulletinManager") sharedInstance]);
        [[objc_getClass("JBBulletinManager") sharedInstance] showBulletinWithTitle:title message:message overrideBundleImage:tssImage];
    } else {
        NSLog(@"************ Unable to load 'libbulletin.dylib'***");
    }
}
    
+ (void)verifyAndCheckBlobsUpdate:(TSSDevice*)device saveNow:(BOOL)saveNow {
    //get the latest updates...
    [[TSSDeviceModelsDataController sharedInstance] loadAvailableOS:device.identifier completion:^(NSArray *firmwares) {
        NSInteger topFirmWare = 0;
        for (NSDictionary* firmware in firmwares) {
            NSInteger firWareVer = 0;
//            NSLog(@"************* Checking firmware  %@ for identifier: %@", firmware, device.identifier);
            if ([firmware[@"signed"] boolValue] == YES) {
                NSString* firmwareVersion = firmware[@"version"];
                NSInteger dotCount = [[firmwareVersion componentsSeparatedByString:@"."] count] - 1;
                firmwareVersion = [firmwareVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                firmwareVersion = [firmwareVersion stringByReplacingOccurrencesOfString:@"-" withString:@""];
                firmwareVersion = [firmwareVersion stringByReplacingOccurrencesOfString:@"_" withString:@""];
                firWareVer = [firmwareVersion integerValue];
                firWareVer *= (100000 / pow(10, dotCount));
                if (firWareVer > topFirmWare) {
                    topFirmWare = firWareVer;
                }
            }
        }
        NSLog(@"************* topFirmWare : %ld for device: %@", (long)topFirmWare, device.name);
        if (saveNow) {
            NSLog(@"************ Called save now.....");
            if (topFirmWare > 0) {
                NSLog(@"************* Setting topFirmWare : %ld for key: %@", (long)topFirmWare, device.ecid);
                device.lastiOS = topFirmWare;
                //update device...
                [self saveDeviceToDisk:[device dictionaryRepresentation]];
            }
        } else {
//            NSInteger lastiOS = [[NSUserDefaults standardUserDefaults] integerForKey:device.ecid];
            NSLog(@"************* lastiOS (%ld) < topFirmWare (%ld) updated for device '%@'.", (long)device.lastiOS, (long)topFirmWare, device.name);
            if (device.lastiOS < topFirmWare) {
                NSLog(@"************ Calling blobs update for device %@", device.name);
                [self callBlobsAutoUpdate:device saveNow:YES];
            } else {
                NSLog(@"************* Device '%@' already has signed blobs.", device.name);
            }
        }
    }];
}
    
+ (void)callBlobsAutoUpdate:(TSSDevice*)device saveNow:(BOOL)saveNow {
    if (tssImage == nil) {
        tssImage = [UIImage imageWithContentsOfFile:@"Applications/TSSSaver.app/AppIcon20x20@2x.png"];
    }
    NSInteger daysBetween = [[NSDate date] timeIntervalSinceDate:[device lastUpdated]] / 86400;
    NSLog(@"******* Device '%@' last updated on %@...", device.name, [device lastUpdated]);
    NSLog(@"******* daysBetween %ld for Device '%@'...", (long)daysBetween, device.name);
    if (daysBetween >= 7) {
        NSLog(@"******* Calling save blob for Device '%@'.", device.name);
        [[TSSBlobSaver sharedInstance] saveBlob:[device blobParams] completion:^(TSSBlob *blob, NSError *error) {
            NSLog(@"******* Got blob data as %@ and error %@ for Device '%@'.", blob, error, device.name);
            if (blob && error == nil) {
                NSLog(@"******** Updating 'lastUpdated'.....");
                [device setValue:[NSDate date] forKey:@"lastUpdated"];
                [TSSUtils saveDeviceToDisk:[device dictionaryRepresentation]];
                [self verifyAndCheckBlobsUpdate:device saveNow:saveNow];
                //show notification
                if ([device isShowNotification]) {
                    [self showBulletinWithTitle:@"TSSSaver" message:[NSString stringWithFormat:@"Device %@'s SHSH blobs saved successfully.", device.name] overrideBundleImage:tssImage];
                }
            } else {
                //error
                if ([error code] <= 0) {
                    //ignore error, since it is over loaded error..
                    NSLog(@"*****Too many requests error: %@", error);
                } else if ([device isShowNotification]) {
                    [self showBulletinWithTitle:@"TSSSaver" message:[NSString stringWithFormat:@"Error while updating Device %@'s SHSH blobs. Error: %@", device.name, error] overrideBundleImage:tssImage];
                }
            }
        }];
    } else {
        NSLog(@"************* Ignoring the update request, since the '%@' is last updated on : %@.", [device name], [device lastUpdated]);
    }
}
    
+ (void)startAutoSaveSHSHBlobs {
    [[TSSDeviceModelsDataController sharedInstance] loadDevices:^{
        NSLog(@"******* startAutoSaveSHSHBlobs->Loading of devices done...");
        //now get all devices, and start auto save process
        [TSSUtils loadStoredDevices:^(NSArray *devices) {
            NSLog(@"******* startAutoSaveSHSHBlobs->Loading of stored devices done...");
            for (NSDictionary* deviceData in devices) {
                NSLog(@"************* startAutoSaveSHSHBlobs->Loaded device : %@", deviceData);
                TSSDevice* device = [[TSSDevice alloc] init:deviceData];
                if ([device isAutoUpdate]) {
#if TARGET_OS_SIMULATOR
//                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:device.ecid];
                    device.lastiOS = 0;
#endif
//                    NSInteger lastiOS = [[NSUserDefaults standardUserDefaults] integerForKey:device.ecid];
                    NSLog(@"******* startAutoSaveSHSHBlobs->lastiOS %ld for Device '%@'...", (long)device.lastiOS, device.name);
                    if (device.lastiOS <= 0) {
                        NSLog(@"******* startAutoSaveSHSHBlobs->Calling 'callBlobsAutoUpdate' for Device '%@'...", device.name);
                        [self callBlobsAutoUpdate:device saveNow:YES];
                    } else {
                        NSLog(@"******* startAutoSaveSHSHBlobs->Calling 'verifyAndCheckBlobsUpdate' for Device '%@'...", device.name);
                        [self verifyAndCheckBlobsUpdate:device saveNow:NO];
                    }
                } else {
                    NSLog(@"******* Auto update is turned off for Device '%@'...", device.name);
                }
            }
        }];
    }];
}

@end
