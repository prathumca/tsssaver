//
//  TSSSavedBlobsViewController.m
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//
#import "TFHpple.h"

#import "TSSUtils.h"
#import "NSString+Utils.h"
#import "UIViewController+Utils.h"
#import "TSSSavedBlobsViewController.h"

@interface TSSSavedBlobsViewController () <UIWebViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray* shshBlobsSavedHistory;

@end

@implementation TSSSavedBlobsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:39.0/255.0 blue:42.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = self.view.backgroundColor;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self tss__showActivityIndicator:NSLocalizedString(@"Loading", @"Loading") message:NSLocalizedString(@"Please wait...", @"Please wait...")];
    self.shshBlobsSavedHistory = [NSMutableArray new];
    __weak __typeof(self)weakSelf = self;
    void (^hideActivityIndicatorView)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://stor.1conan.com/tsssaver/shsh/%@?C=N&O=D", (weakSelf.devicViewModel.ecid.length > 0?[weakSelf.devicViewModel.ecid decimalString]:@"NA")]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray* elements = [doc searchWithXPathQuery:@"//tbody"];
        if (elements.count > 0) {
            TFHppleElement* element = [elements firstObject];
            NSString* content = [element content];
            if (content) {
                NSArray* contents = [content componentsSeparatedByString:@"\r"];
                for (NSString* blobsData in contents) {
                    NSArray* blobsDatas = [blobsData componentsSeparatedByString:@"/--"];
                    NSString* data = [blobsDatas lastObject];//Parent directory/--11.4/-2018-May-29 22:51 -> eliminates the first 'Parent directory/--'
                    data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    if (data.length > 0) {
                        [weakSelf.shshBlobsSavedHistory addObject:data];
                    }
                }
                hideActivityIndicatorView();
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            } else {
                hideActivityIndicatorView();
            }
        } else {
            hideActivityIndicatorView();
            [weakSelf tss__showError:[NSString stringWithFormat:NSLocalizedString(@"Unable to load the SHSH blobs history for device '%@' with ECID '%@' from '%@'.", @"unable to load SHSH blobs."), weakSelf.devicViewModel.name, weakSelf.devicViewModel.ecid, url.absoluteString]];
        }
    });
}
    
#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self shshBlobsSavedHistory] count] > 0 ? 1 : 0;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self shshBlobsSavedHistory] count];
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    NSString* data = self.shshBlobsSavedHistory[indexPath.row];
    NSArray* dataComponents = [data componentsSeparatedByString:@"/-"];
    if (dataComponents.count > 1) {
        cell.textLabel.text = [dataComponents firstObject];
        NSString* dateStr = [dataComponents lastObject];
        NSDateFormatter* dateFormatter = [TSSUtils dateFormatter];
        [dateFormatter setDateFormat:@"yyyy-MMM-dd HH:mm"];
        NSDate* date = [dateFormatter dateFromString:dateStr];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    return cell;
}
    
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.05];
    UIView* selectionView = [UIView new];
    selectionView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = selectionView;
}
    
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.devicViewModel.name;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* headerView = (UITableViewHeaderFooterView*)view;
    UIColor* color = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    headerView.detailTextLabel.textColor = color;
    headerView.textLabel.textColor = color;
}
    
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, 100)];
    NSString* footerInfo = [NSString stringWithFormat:NSLocalizedString(@"Data shown above retrieved from https://tsssaver.1conan.com/. You can check '%@' SHSH blobs manually by visiting here.", @"SHSH Blobs footer"), self.devicViewModel.name];
    NSMutableAttributedString* footerAttrText = [[NSMutableAttributedString alloc] initWithString:footerInfo attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
    
    NSRange linkRange = [footerInfo rangeOfString:@"https://tsssaver.1conan.com/"];
    [footerAttrText addAttribute:NSLinkAttributeName value:@"https://tsssaver.1conan.com/" range:linkRange];
    [footerAttrText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:114.0/255.0 green:137.0/255.0 blue:218.0/255.0 alpha:1.0] range:linkRange];
    
    linkRange = [footerInfo rangeOfString:NSLocalizedString(@"here",@"here")];
    [footerAttrText addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"https://stor.1conan.com/tsssaver/shsh/%@?C=N&O=D", (self.devicViewModel.ecid.length > 0?[self.devicViewModel.ecid decimalString]:@"NA")] range:linkRange];
    [footerAttrText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:114.0/255.0 green:137.0/255.0 blue:218.0/255.0 alpha:1.0] range:linkRange];
    textView.attributedText = footerAttrText;
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.selectable = YES;
    textView.delegate = self;
    textView.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    textView.userInteractionEnabled = YES;
    textView.backgroundColor = [UIColor clearColor];
    return textView;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [[self shshBlobsSavedHistory] count] > 0 ? 100.f : 0.f;
}
    
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* footerView = (UITableViewHeaderFooterView*)view;
    UIColor* color = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    if ([footerView respondsToSelector:@selector(detailTextLabel)]) {
        footerView.detailTextLabel.textColor = color;
    }
    if ([footerView respondsToSelector:@selector(textLabel)]) {
        footerView.textLabel.textColor = color;
    }
}
    
#pragma mark - TextView Delegate
    
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}

@end
