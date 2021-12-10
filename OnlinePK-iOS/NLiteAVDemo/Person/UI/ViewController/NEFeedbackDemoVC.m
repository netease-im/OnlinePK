//
//  NEFeedbackDemoVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/23.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEFeedbackDemoVC.h"
#import "NEFeedbackListCell.h"

@interface NEFeedbackDemoVC ()
@property(strong,nonatomic)NSArray *dataArray;
@property(strong,nonatomic)NEFeedbackListCell *selectedCell;

@end

@implementation NEFeedbackDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableview];
}
- (void)setupTableview {
    self.title = NSLocalizedString(@"Demo类型", nil);
    [self.tableView registerClass:[NEFeedbackListCell class] forCellReuseIdentifier:@"NEFeedbackListCell"];
    //一对一视频通话Demo“ ”多人视频通话Demo“ ”主播PK Demo“
    self.dataArray = @[NSLocalizedString(@"一对一视频通话Demo", nil), NSLocalizedString(@"多人视频通话Demo", nil)];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NEFeedbackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEFeedbackListCell" forIndexPath:indexPath];
    NSString *title =  self.dataArray[indexPath.row];
    if ([title isEqualToString:self.selectedDemo]) {
        cell.arrowButton.selected = YES;
        self.selectedCell = cell;
    }
    cell.titleLabel.text = title;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NEFeedbackListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.selectedCell) {
        self.selectedCell.arrowButton.selected = NO;
    }
    cell.arrowButton.selected = YES;
    self.selectedCell = cell;
    if (self.didSelectDemo) {
        self.didSelectDemo(cell.titleLabel.text);
    }
}

@end
