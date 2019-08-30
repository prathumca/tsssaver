//
//  TSSUtils.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TSSSAVER_DEVICE_LIST_UPDATED_NOTIFICATION @"com.iarrays.TSSSaverDeviceListUpdatedNotification"

@interface JBBulletinManager : NSObject
+(id)sharedInstance;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID soundPath:(NSString *)soundPath;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID soundID:(int)inSoundID;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(id)overridBundleImage;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(id)overridBundleImage soundPath:(NSString *)soundPath;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overridBundleImage:(id)overridBundleImage soundID:(int)inSoundID;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID hasSound:(BOOL)hasSound soundID:(int)soundID vibrateMode:(int)vibrate soundPath:(NSString *)soundPath attachmentImage:(id)attachmentImage overrideBundleImage:(id)overrideBundleImage;
@end

@interface TSSUtils : NSObject
    
+ (NSDateFormatter*)dateFormatter;
+ (NSString *)ecid;

+ (BOOL)isRunningOnSandbox;
+ (NSString*)devicesFileLocation;
+ (NSString*)devicesModlesFileLocation;
+ (void)loadStoredDevices:(void (^)(NSArray* devices))completion;
+ (void)saveDeviceToDisk:(NSDictionary*)deviceData;
+ (BOOL)deleteDevice:(NSInteger)udid;
+ (void)startAutoSaveSHSHBlobs;

@end
