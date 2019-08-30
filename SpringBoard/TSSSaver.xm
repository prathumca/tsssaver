#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstdlibcxx-not-found"

#import "TSSUtils.h"
#import "TSSDeviceModelsDataController.h"

%hook SpringBoard

- (void)_midnightPassed {
    %orig;
    [TSSUtils startAutoSaveSHSHBlobs];
}

%end

%ctor {
    %init;
    freopen([@"/tmp/tsssaver.log" fileSystemRepresentation], "a+", stderr);
    //download and save the models from the internet..
    //load the data on startup..
    [[TSSDeviceModelsDataController sharedInstance] loadDevices:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        ******* startAutoSaveSHSHBlobs->lastiOS
//        NSLog(@"************************ Triggering 'startAutoSaveSHSHBlobs'.....");
//        [TSSUtils startAutoSaveSHSHBlobs];
//    });
}

#pragma clang diagnostic pop
