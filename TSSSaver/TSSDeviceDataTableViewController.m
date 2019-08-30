//
//  TSSDeviceDataTableViewController.m
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "UIViewController+Utils.h"

#import "TSSDeviceDataTableViewController.h"

@interface TSSDeviceDataTableViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
    
@property (nonatomic, strong) NSMutableArray<NSDictionary*>* searchDetails;
@property (nonatomic, assign) NSInteger selectedRow;
@property (strong, nonatomic) UISearchController *searchController;
    
@end

@implementation TSSDeviceDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:39.0/255.0 blue:42.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.backgroundColor = [UIColor clearColor];
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
}
    
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
    
- (BOOL)isSearching {
    return self.searchController.isActive && self.searchController.searchBar.text.length > 0;
}
    
- (NSDictionary*)dataModelAtIndex:(NSInteger)index {
    if ([self isSearching] && self.searchDetails.count > index) {
        return self.searchDetails[index];
    }
    if (self.details.count > index) {
        return self.details[index];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isSearching]) {
        return self.searchDetails != nil? 1 : 0;
    }
    return self.details != nil? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearching]) {
        return self.searchDetails.count;
    }
    return self.details.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    NSDictionary* data = [self dataModelAtIndex:indexPath.row];
    if (data != nil) {
        cell.textLabel.text = data[@"name"];
        cell.detailTextLabel.text = data[@"identifier"];
        if ([data[@"identifier"] isEqualToString:self.deviceViewModel.identifier]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedRow = indexPath.row;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedRow = -1;
        }
        cell.tintColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.05];
    UIView* selectionView = [UIView new];
    selectionView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = selectionView;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedRow != indexPath.row && self.selectedRow >= 0) {
        UITableViewCell* prevSelCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:indexPath.section]];
        prevSelCell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSDictionary* data = [self dataModelAtIndex:indexPath.row];
    void (^completion)(void) = ^{
        if (self.completion) {
            self.completion(data);
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    if ([self isSearching]) {
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            completion();
        }];
    } else {
        completion();
    }
}
    
#pragma mark - Search
    
- (void)searchData {
    if (self.searchDetails == nil) {
        self.searchDetails = [NSMutableArray new];
    }
    [self.searchDetails removeAllObjects];
    NSString *searchText = self.searchController.searchBar.text;
    for (NSDictionary *data in self.details) {
        NSString* name = data[@"name"];
        NSString* identifier = data[@"identifier"];
        if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0 || [identifier rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
            [self.searchDetails addObject:data];
        }
    }
}
    
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if ([searchText length] > 0) {
        [self searchData];
        [self.tableView reloadData];
    } else {
        [self.searchDetails removeAllObjects];
        [self.tableView reloadData];
    }
}
    
- (void)dealloc {
    self.completion = nil;
    [self.searchDetails removeAllObjects];
    self.searchDetails = nil;
}

@end
