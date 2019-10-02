//
//  ViewController.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <Social/Social.h>

#import "NSString+Utils.h"
#import "UIViewController+Utils.h"
#import "TSSUtils.h"
#import "TSSDeviceTableViewCell.h"
#import "TSSDevicesListViewModel.h"
#import "TSSDeviceTableViewController.h"
#import "TSSDevicesTableViewController.h"

static void devicesListUpdated(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:(__bridge NSNotificationName _Nonnull)(name) object:nil];
}

@implementation TSSNavigationController
    
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
    
@end

@interface TSSDevicesTableViewController () <TSSDeviceTableViewControllerDelegate>
    
@property (nonatomic, strong) TSSDevicesListViewModel* devicesViewModel;

@end

@implementation TSSDevicesTableViewController
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"TSS Saver", @"TSS Saver");
    self.navigationController.navigationBar.topItem.title = self.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshDevices:) forControlEvents:UIControlEventValueChanged];
    if (@available(iOS 10.0, *)) {
        self.tableView.refreshControl = refreshControl;
    } else {
        [self.tableView addSubview:refreshControl];
    }
    self.view.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:39.0/255.0 blue:42.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.devicesViewModel = [[TSSDevicesListViewModel alloc] init];
    [self deviceListUpdated:nil];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, devicesListUpdated, (CFStringRef) TSSSAVER_DEVICE_LIST_UPDATED_NOTIFICATION, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListUpdated:) name:TSSSAVER_DEVICE_LIST_UPDATED_NOTIFICATION object:nil];
#if TARGET_OS_SIMULATOR
    //just to check it on simulator..
    [TSSUtils startAutoSaveSHSHBlobs];
#endif
}
    
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// MARK: -

- (void)refreshDevices:(UIRefreshControl*)refreshControl {
    __weak __typeof(self)weakSelf = self;
    [self.devicesViewModel loadDevices:^{
        [[weakSelf tableView] reloadData];
        [refreshControl endRefreshing];
    }];
}
    
- (IBAction)twitterAction:(id)sender {
    SLComposeViewController *composeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeSheet setInitialText:NSLocalizedString(@"I'm Loving #TSSSaver, which automatically saves SHSH blos to TSS Server.", nil)];
    [composeSheet addURL:[NSURL URLWithString:@"cydia://package/com.iarrays.tssserver"]];
    [self presentViewController:composeSheet animated:YES completion:nil];
}
    
- (IBAction)addDevice:(id)sender {
    TSSDeviceTableViewController* addDeviceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TSSDeviceTableViewController"];
    addDeviceVC.deviceListDelegate = self;
    UINavigationController* navigationVC = [[TSSNavigationController alloc] initWithRootViewController:addDeviceVC];
    [self presentViewController:navigationVC animated:YES completion:nil];
}
    
// MARK: - Notification

- (void)deviceListUpdated:(NSNotification*)notification {
    __weak __typeof(self)weakSelf = self;
    [self.devicesViewModel loadDevices:^{
        [[weakSelf tableView] reloadData];
    }];
}
    
// MARK: - TSSDeviceTableViewControllerDelegate
    
- (TSSDeviceViewModel*)model:(NSInteger)byUDID {
    return [self.devicesViewModel deviceModelByUDID:byUDID];
}
    
- (BOOL)isDeviceAlreadyExists:(NSInteger)udid ecid:(NSString*)ecid {
    return [self.devicesViewModel isDeviceAlreadyExists:udid ecid:ecid];
}
    
// MARK: - Segue
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"deviceInfo"]) {
        TSSDeviceTableViewController* deviceVC = (TSSDeviceTableViewController*)[segue destinationViewController];
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row >= 0) {
            TSSDeviceViewModel* deviceModel = [self.devicesViewModel deviceModelAtIndex:(indexPath.section - 1) + indexPath.row];
            deviceVC.deviceViewModel = deviceModel;
            deviceVC.deviceListDelegate = self;
        }
    }
}
    
// MARK: - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.devicesViewModel.devicesCount > 1 ? 3 : 2;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= 1) {
        return 1;
    }
    return self.devicesViewModel.devicesCount - 1;
}
    
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"paypal" forIndexPath:indexPath];
        return cell;
    }
    TSSDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"device" forIndexPath:indexPath];
    TSSDeviceViewModel* deviceModel = [self.devicesViewModel deviceModelAtIndex:(indexPath.section - 1) + indexPath.row];
    if (deviceModel != nil) {
        cell.nameLabel.text = deviceModel.name;
        cell.modelLabel.text = deviceModel.type;
        cell.ecidLabel.text = deviceModel.descriptiveECID;
        cell.lastUpdatedDateLabel.text = [deviceModel lastUpdated:NSLocalizedString(@"Last Updated: ", @"Last Updated: ")];
        cell.deviceImageView.image = [deviceModel deviceImage];
    }
    return cell;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //this for donate
        void (^donate)(NSString*) = ^(NSString* identifier) {
            NSString* url = [NSString stringWithFormat:@"http://iarrays.com/donate/tsssaver/?option=%@", identifier];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        };
        UIAlertController* donationsController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Donate with love", @"Donate with love") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* coffeeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Buy me a Coffee (☕) $2", @"Buy me a Coffee") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            donate(@"tsssaver_2");
        }];
        [donationsController addAction:coffeeAction];
        
        UIAlertAction* pizzaAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Buy me a Pizza (🍕) $5", @"Buy me a Pizza") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            donate(@"tsssaver_5");
        }];
        [donationsController addAction:pizzaAction];
        
        UIAlertAction* beerAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Buy me a Beer (🍺) $10", @"Buy me a Beer") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            donate(@"tsssaver_10");
        }];
        [donationsController addAction:beerAction];
        
        UIAlertAction* buyMeSomethingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Buy me somehting else", @"Buy me somehting else") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            donate(@"tsssaver_0");
        }];
        [donationsController addAction:buyMeSomethingAction];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDestructive handler:nil];
        [donationsController addAction:cancelAction];
        [self presentViewController:donationsController animated:YES completion:nil];
    }
}
    
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.05];
    UIView* selectionView = [UIView new];
    selectionView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = selectionView;
}
    
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 1) {
        return YES;
    }
    return NO;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0) {
        return 80.f;
    }
    return 44.f;
}
    
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TSSDeviceViewModel* deviceModel = [self.devicesViewModel deviceModelAtIndex:(indexPath.section - 1) + indexPath.row];
    if ([self.devicesViewModel deleteDevice:deviceModel]) {
        [tableView beginUpdates];
        if (self.devicesViewModel.devicesCount <= 1) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [tableView endUpdates];
    } else {
        [self tss__showError:NSLocalizedString(@"Error while deleting device.", @"Error while deleting device.")];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section <= 0) {
        return nil;
    }
    TSSDeviceViewModel* deviceModel = [self.devicesViewModel deviceModelAtIndex:section - 1];
    if (deviceModel != nil && section == 1 && [deviceModel.ecid isEqualToString:[[TSSUtils ecid] hexString]]) {
        return NSLocalizedString(@"Current Device", @"Current Device");
    }
    return NSLocalizedString(@"Other Devices", @"Other Devices");
}
    
    
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* headerView = (UITableViewHeaderFooterView*)view;
    UIColor* color = [UIColor.whiteColor colorWithAlphaComponent:0.8];
    headerView.detailTextLabel.textColor = color;
    headerView.textLabel.textColor = color;
}

@end
