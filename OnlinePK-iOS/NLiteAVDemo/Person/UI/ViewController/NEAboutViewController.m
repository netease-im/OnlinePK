//
//  NEAboutViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEAboutViewController.h"
#import "NEPersonTableViewCell.h"
#import "NEBaseWebViewController.h"
#import "NEStatementVC.h"
#import <NERtcSDK/NERtcSDK.h>
@interface NEAboutViewController ()
@property(strong,nonatomic)NSArray *dataArray;
@property(strong,nonatomic)NSArray *valueArray;

@end

@implementation NEAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.dataArray = @[
        @[
            NSLocalizedString(@"App版本", nil),
            NSLocalizedString(@"IM版本", nil),
            NSLocalizedString(@"音视频SDK版本", nil)
        ],
        @[
            NSLocalizedString(@"隐私政策", nil),
            NSLocalizedString(@"用户协议", nil),
            NSLocalizedString(@"免责申明", nil)
        ]
    ];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *rtcVersion = [NSBundle bundleForClass:[NERtcEngine class]].infoDictionary[@"CFBundleShortVersionString"];
    self.valueArray = @[@[version,NIMSDK.sharedSDK.sdkVersion,rtcVersion],@[@"",@"",@""]];

}
- (void)setupUI {
    self.title = NSLocalizedString(@"关于", nil);
    [self.tableView registerClass:[NEPersonTableViewCell class] forCellReuseIdentifier:@"NEPersonTableViewCell"];
//    UIView *headView = [[UIView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"about_logo"];
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 218);
    imageView.contentMode = UIViewContentModeCenter;
    self.tableView.tableHeaderView = imageView;
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArray[section];
    return sectionArray.count;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTableViewCell" forIndexPath:indexPath];
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSString *content = sectionArray[indexPath.row];
    cell.personView.titleLabel.text = content;

    NSArray *valueArray = self.valueArray[indexPath.section];
    NSString *valueString = valueArray[indexPath.row];
    if (indexPath.section == 0) {
        cell.personView.detailLabel.text = valueString;
    }else {
        cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSArray *sectionArray = self.dataArray[indexPath.section];
        NSString *content = sectionArray[indexPath.row];
        NSString *url;
        switch (indexPath.row) {
            case 0:
            {
                url = @"https://yunxin.163.com/clauses?serviceType=3";
                NEBaseWebViewController *vc = [[NEBaseWebViewController alloc] initWithUrlString:url];
                vc.title = content;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
                
            {
                url = @"http://yunxin.163.com/clauses";
                NEBaseWebViewController *vc = [[NEBaseWebViewController alloc] initWithUrlString:url];
                vc.title = content;
                [self.navigationController pushViewController:vc animated:YES];
            }
                
                break;
            case 2:
            {
                NEStatementVC *vc = [[NEStatementVC alloc] init];
                vc.title = content;
                [self.navigationController pushViewController:vc animated:YES];
                
            }
                break;
                
            default:
                break;
        }
        
       
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
