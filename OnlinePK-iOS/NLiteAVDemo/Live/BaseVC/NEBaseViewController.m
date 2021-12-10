//
//  NEBaseViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEBaseViewController.h"

@interface NEBaseViewController ()

@end

@implementation NEBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.view.backgroundColor = HEXCOLOR(0x1A1A24);
//    self.navigationController.navigationBar.hidden = NO;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:47/255.0 alpha:1.0];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
//
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setImage:[UIImage imageNamed:@"menu_arrow_left"] forState:UIControlStateNormal];
//    btn.frame = CGRectMake(0, 0, 30, 30);
//    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
//    [btn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
//    btn.userInteractionEnabled = YES;
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.leftBarButtonItem = backItem;
}
//- (void)backAction:(UIButton *)backButton {
//    [self.navigationController popViewControllerAnimated:YES];
//}
- (void)setupViews
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = HEXCOLOR(0x1A1A24);
//    self.navigationController.navigationBar.topItem.title = @"";

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
