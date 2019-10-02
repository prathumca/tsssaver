//
//  TSSDeviceTableViewController.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "NSString+Utils.h"
#import "UIViewController+Utils.h"

#import "TSSUtils.h"
#import "TSSBlobSaver.h"
#import "TSSDeviceModelsDataController.h"
#import "TSSDeviceDataTableViewController.h"
#import "TSSSavedBlobsViewController.h"
#import "TSSDeviceTableViewController.h"

@interface TSSDeviceTableViewController () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL isDeviceEdited;

@end

@implementation TSSDeviceTableViewController
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.deviceViewModel.name? self.deviceViewModel.name : NSLocalizedString(@"Add Device", @"Add Device");
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isDeviceEdited) {
        [self update];
    }
    self.title = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListUpdated:) name:TSSSAVER_DEVICE_LIST_UPDATED_NOTIFICATION object:nil];
}
    
- (void)setup {
    self.view.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:39.0/255.0 blue:42.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = self.view.backgroundColor;
    if (self.deviceViewModel == nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        NSMutableDictionary* deviceData = [NSMutableDictionary new];
        deviceData[@"name"] =  NSLocalizedString(@"My iDevice", @"My iDevice");
        if (self.deviceViewModel.identifier == nil) {//choose first as device model
            NSDictionary* deviceModel = [[[TSSDeviceModelsDataController sharedInstance] allAvailableiDevices] firstObject];
            if (deviceModel != nil) {
                deviceData[@"type"] = deviceModel[@"name"];
                deviceData[@"identifier"] = deviceModel[@"identifier"];
                deviceData[@"boardconfig"] = [(NSString*)deviceModel[@"boardconfig"] uppercaseString];
            }
            deviceData[@"autoUpdate"] = @(YES);
            deviceData[@"showNotifications"] = @(YES);
        }
        self.deviceViewModel = [[TSSDeviceViewModel alloc] initWithDeviceData:deviceData];
    }
}
    
- (void)setDeviceViewModel:(TSSDeviceViewModel *)deviceViewModel {
    _deviceViewModel = deviceViewModel;
    [self.deviceViewModel.device addObserver:self forKeyPath:@"autoUpdate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
    
// MARK: - Notification
    
- (void)deviceListUpdated:(NSNotification*)notification {
    if (self.deviceViewModel.udid > 0 && [self.deviceListDelegate respondsToSelector:@selector(model:)]) {
        //get it form previous screen and refresh the current view..
        TSSDeviceViewModel* deviceModel = [self.deviceListDelegate model:self.deviceViewModel.udid];
        if (deviceModel != nil) {
            self.deviceViewModel = deviceModel;
            __weak __typeof(self)weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                //also reset navigation bar
                [weakSelf updateNavigationBarButtons:NO];
            });
        }
    }
}
    
#pragma mark - KVO
    
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"autoUpdate"]) {
        BOOL oldAutpoUpdate = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
        BOOL newAutpoUpdate = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (oldAutpoUpdate != newAutpoUpdate) {
            [self.tableView reloadData];//since this is a static table, better to reload
        }
    }
}
    
#pragma mark - Segue
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"details"]) {
        TSSDeviceDataTableViewController* deviceDetailsVC = (TSSDeviceDataTableViewController*)[segue destinationViewController];
        deviceDetailsVC.details = [[TSSDeviceModelsDataController sharedInstance] allAvailableiDevices];
        deviceDetailsVC.deviceViewModel = self.deviceViewModel;
        __weak __typeof(self)weakSelf = self;
        deviceDetailsVC.completion = ^(NSDictionary* selectedModel) {
            [weakSelf.deviceViewModel setValue:selectedModel[@"name"] forKey:@"type"];
            [weakSelf.deviceViewModel setValue:selectedModel[@"identifier"] forKey:@"identifier"];
            [weakSelf.deviceViewModel setValue:[(NSString*)selectedModel[@"boardconfig"] uppercaseString] forKey:@"boardConfig"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
            weakSelf.isDeviceEdited = weakSelf.deviceViewModel.udid > 0;
        };
    } else if ([segue.identifier isEqualToString:@"savedBlobs"]) {
        TSSSavedBlobsViewController* savedBlobsVC = (TSSSavedBlobsViewController*)[segue destinationViewController];
        savedBlobsVC.devicViewModel = self.deviceViewModel;
    }
}
    
#pragma mark - Save Blobs
    
- (BOOL)validateDeviceDetails {
    if (self.deviceViewModel.name.length <= 0) {
        [self tss__showError:NSLocalizedString(@"Please enter device name.", @"Please enter device name.")];
        return NO;
    }
    if (self.deviceViewModel.ecid.length <= 0) {
        [self tss__showError:NSLocalizedString(@"Please enter device's ECID in Hex format.", @"Please enter device's ECID in Hex format.")];
        return NO;
    }
    //check if device already exists.
    //Device uniqueness is identified by device's ECID
    if ([self.deviceListDelegate respondsToSelector:@selector(isDeviceAlreadyExists:ecid:)]) {
        if ([self.deviceListDelegate isDeviceAlreadyExists:self.deviceViewModel.udid ecid:self.deviceViewModel.ecid]) {
            [self tss__showError:[NSString stringWithFormat:NSLocalizedString(@"Device with ECID '%@' already exists.", @"Device with ECID already exists."), self.deviceViewModel.ecid]];
            return NO;
        }
    }
    return YES;
}
    
- (IBAction)verifyAndSave {
    //verify the data with TSS Server and save the detials to device list..
    if ([self validateDeviceDetails]) {
        __block UIAlertController* activityAlertcontroller = nil;
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"Confirm") message:NSLocalizedString(@"This will save you SHSH blobs with TSS Server and save/update your device details locally. Do you want to continue?", @"This will save you SHSH blobs with TSS Server and save/update your device details locally. Do you want to continue?") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        __weak __typeof(self)weakSelf = self;
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            activityAlertcontroller = [weakSelf tss__showActivityIndicator:NSLocalizedString(@"Verifying", @"Verifying") message:NSLocalizedString(@"Please wait...", @"Please wait...")];
            [[TSSBlobSaver sharedInstance] saveBlob:self.deviceViewModel.blobParams completion:^(TSSBlob *blob, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if (error != nil) {
                            [weakSelf tss__showError:error.localizedDescription];
                            if ([error.userInfo[@"code"] integerValue] <= 0) {
                                //then you can save/update device details.
                                [weakSelf.deviceViewModel setValue:[NSDate date] forKey:@"lastUpdated"];
                                [weakSelf.tableView reloadData];
                                [self.deviceViewModel.device removeObserver:self forKeyPath:@"autoUpdate"];
                                [self update];
                            }
                        } else {
                            if (blob != nil) {
                                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"%@'s blobs saved successfully.", @"blobs saved successfully"), weakSelf.deviceViewModel.name];
                                [weakSelf tss__showInformation:message];
                                [weakSelf.deviceViewModel setValue:[NSDate date] forKey:@"lastUpdated"];
                                BOOL isAddDevice = weakSelf.deviceViewModel.udid <= 0;
                                [weakSelf.tableView reloadData];
                                [weakSelf.deviceViewModel.device removeObserver:self forKeyPath:@"autoUpdate"];
                                [weakSelf update];
                                if (isAddDevice) {
                                    [weakSelf.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStyleDone target:weakSelf action:@selector(cancel)] animated:YES];
                                }
                            }
                        }
                    }];
                });
            }];
        }];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
    
#pragma mark - Cancel
    
- (void)cancel {
    if (self.deviceViewModel.udid > 0) {
//        [self updateNavigationBarButtons:NO];
//        //reload the device too
//        self.deviceViewModel = [self.deviceListDelegate model:self.deviceViewModel.udid];
//        [self.tableView reloadData];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
    
#pragma mark -
    
- (BOOL)showAlertsSection {
    return self.deviceViewModel.autoUpdate;
}
    
- (IBAction)switchAction:(UISwitch *)sender {
    UITableViewCell* cell = (UITableViewCell*)[sender.superview superview];
    [self.deviceViewModel.device setValue:@(sender.isOn) forKey:cell.reuseIdentifier];
    if (self.deviceViewModel.udid > 0) {
        //remove observer
        [self.deviceViewModel.device removeObserver:self forKeyPath:@"autoUpdate"];
        [self update];
    }
}

#pragma mark - Table view data source
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2 && ![self showAlertsSection]) {
        return 0.1;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2 && ![self showAlertsSection]) {
        return 0.1;
    }
    return [super tableView:tableView heightForFooterInSection:section];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2 && ![self showAlertsSection]) { //Index number of interested section
        return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section]; //keeps inalterate all other rows
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView* infoView = [cell viewWithTag:2];
    if ([infoView respondsToSelector:@selector(setText:)] && [self.deviceViewModel valueForKey:cell.reuseIdentifier] != nil) {
        [infoView performSelector:@selector(setText:) withObject:[self.deviceViewModel valueForKey:cell.reuseIdentifier]];
    } else if ([infoView respondsToSelector:@selector(setOn:)]) {
        [(UISwitch*)infoView setOn:[[self.deviceViewModel valueForKey:cell.reuseIdentifier] boolValue]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.05];
    UIView* selectionView = [UIView new];
    selectionView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = selectionView;
}
    
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return NSLocalizedString(@"Automatically saves this device's blobs to TSSServer whenever there is a new iOS available.", @"Automatically saves this device's blobs to TSSServer whenever there is a new iOS available.");
    } else if (section == 2 && [self showAlertsSection]) {
        return NSLocalizedString(@"Shows notifications when SHSH blobs of this device are saved to TSSServer automatically.", @"Shows notifications when SHSH blobs of this device are saved to TSSServer automatically.");
    }
    return nil;
}
    
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* headerView = (UITableViewHeaderFooterView*)view;
    UIColor* color = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    headerView.detailTextLabel.textColor = color;
    headerView.textLabel.textColor = color;
}
    
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* footerView = (UITableViewHeaderFooterView*)view;
    UIColor* color = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    footerView.detailTextLabel.textColor = color;
    footerView.textLabel.textColor = color;
}
    
#pragma mark - TextField Delegate
    
- (void)textFieldDidChange:(UITextField *)textField {
    UITableViewCell* cell = (UITableViewCell*)[textField.superview superview];
    if (cell) {
        [self.deviceViewModel setValue:textField.text forKey:[cell reuseIdentifier]];
//        [self updateNavigationBarButtons:YES];
        if ([[cell reuseIdentifier] isEqualToString:@"name"]) {
            self.title = self.deviceViewModel.name;
        }
        self.isDeviceEdited = self.deviceViewModel.udid > 0;
    }
}
    
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITableViewCell* cell = (UITableViewCell*)[textField.superview superview];
    if (cell) {
        if ([[cell reuseIdentifier] isEqualToString:@"name"]) {
            //move it to next text field..
            UITableViewCell* ecidCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
            if (ecidCell != nil) {
                UITextField* ecidTextFeild = (UITextField*)[ecidCell viewWithTag:2];
                [ecidTextFeild becomeFirstResponder];
            }
        } else {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

#pragma mark -

- (void)updateNavigationBarButtons:(BOOL)isEditing {
//    if (isEditing) {
//        if (self.navigationItem.leftBarButtonItem == nil) {
//            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] animated:YES];
//        }
//        if (self.navigationItem.rightBarButtonItem == nil) {
//            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(update)] animated:YES];
//        }
//    } else {
//        [self setEditing:NO animated:YES];
//        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
//        [self.navigationItem setRightBarButtonItem:nil animated:YES];
//    }
}

- (void)update {
    [TSSUtils saveDeviceToDisk:[self.deviceViewModel.device dictionaryRepresentation]];
    self.isDeviceEdited = NO;
}
    
#pragma mark - Dealloc
    
- (void)dealloc {
    if ([self.deviceViewModel.device observationInfo]) {
        [self.deviceViewModel.device removeObserver:self forKeyPath:@"autoUpdate"];
    }
}

@end
