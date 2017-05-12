//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//  Created by atman on 14/12/18.
//  Copyright (c) 2014年 GPLIU. All rights reserved.
//

#import "HeroTableView.h"
#import "UILazyImageView.h"
#import "UIImage+alpha.h"
#import "HeroTableViewCell.h"
#import "MJRefresh.h"
@interface HeroTableView()

@end
@implementation HeroTableView
{
    NSMutableDictionary *_headerViews; //复用headviews始终不行才自己缓存
    NSInteger refeshTimes;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 0)];
        head.backgroundColor = [UIColor clearColor];
        self.tableHeaderView = head;
        
        UIView *foot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 0)];
        foot.backgroundColor = [UIColor clearColor];
        self.tableFooterView = foot;
        
        self.rowHeight = 44;
        refeshTimes = 0;
    }
    return self;
}
-(void)on:(NSDictionary *)json
{
    [super on:json];
    self.dataSource = self;
    self.delegate  = self;
    if (json[@"header"]) {
        NSDictionary *header = json[@"header"];
        UIView *view = [[NSClassFromString(header[@"class"]) alloc]init];
        view.controller = self.controller;
        [view on:header];
        self.tableHeaderView = view;
    }
    if (json[@"footer"]) {
        NSDictionary *footer = json[@"footer"];
        UIView *view = [[NSClassFromString(footer[@"class"]) alloc]init];
        view.controller = self.controller;
        [view on:footer];
        self.tableFooterView = view;
    }
    if (json[@"dataIndex"]) {
        self.dataIndex = json[@"dataIndex"];
    }
    if (json[@"data"]) {
        self.data = json[@"data"];
        [self reloadData];
        refeshTimes++;
    }
    if (json[@"height"]) {
        self.rowHeight = ((NSNumber*)json[@"height"]).floatValue;
    }
    if (json[@"contentOffset"]) {
        NSString *x = json[@"contentOffset"][@"x"];
        NSString *y = json[@"contentOffset"][@"y"];
        CGPoint point = CGPointMake(x.floatValue, y.floatValue);
        if ([x hasSuffix:@"x"]) {
            point.x = SCREEN_W*x.floatValue;
        }
        if ([y hasSuffix:@"x"]) {
            point.y = SCREEN_H*x.floatValue;
        }
        self.contentOffset = CGPointMake(MIN(x.floatValue,MAX(0,self.contentSize.width-self.bounds.size.width)), MIN(y.floatValue,MAX(0,self.contentSize.height-self.bounds.size.height)));
    }
//    if (json[@"pullRefresh"]) {
//        NSDictionary *pull = json[@"pullRefresh"];
//        NSString *idle = pull[@"idle"]?pull[@"idle"]:LS(@"下拉刷新");
//        NSString *pulling = pull[@"pulling"]?pull[@"pulling"]:LS(@"松开立即刷新");
//        NSString *refreshing = pull[@"refreshing"]?pull[@"refreshing"]:LS(@"加载数据中...");
//        
//        __block HeroTableView *selfBlock = self;
//        
//        [self addLegendHeaderWithRefreshingBlock:^{
//            [selfBlock.controller on:pull[@"action"]];
//        }];
//        self.header.updatedTimeHidden = YES;
//        [self.header setTitle:idle forState:MJRefreshHeaderStateIdle];
//        [self.header setTitle:pulling forState:MJRefreshHeaderStatePulling];
//        [self.header setTitle:refreshing forState:MJRefreshHeaderStateRefreshing];
//        self.header.font = [UIFont boldSystemFontOfSize:13];
//        self.header.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
//    }
//    if (json[@"drawMore"]) {
//        NSDictionary *drawMore = json[@"drawMore"];
//        NSString *idle = drawMore[@"idle"]?drawMore[@"idle"]:LS(@"上拉加载更多");
//        NSString *loading = drawMore[@"loading"]?drawMore[@"loading"]:LS(@"正在加载");
//        NSString *noMoreData = drawMore[@"noMoreData"]?drawMore[@"noMoreData"]:LS(@"无更多数据");
//        
//        __block HeroTableView *selfBlock = self;
//        if (!self.footer) {
//            [self addLegendFooterWithRefreshingBlock:^{
//                [selfBlock.controller on:drawMore[@"action"]];
//            }];
//            self.footer.font = [UIFont boldSystemFontOfSize:13];
//            self.footer.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
//        }else{
//            self.footer.refreshingBlock = ^{
//                [selfBlock.controller on:drawMore[@"action"]];
//            };
//        }
//        [self.footer setTitle:idle forState:MJRefreshFooterStateIdle];
//        [self.footer setTitle:loading forState:MJRefreshFooterStateRefreshing];
//        [self.footer setTitle:noMoreData forState:MJRefreshFooterStateNoMoreData];
//    }
    if (json[@"separatorColor"]) {
        self.separatorColor = UIColorFromStr(json[@"separatorColor"]);
    }
    if (json[@"fragmentData"]) {
        NSDictionary *fragmentData = json[@"fragmentData"];
        NSString *dataCommand = fragmentData[@"command"];
        NSInteger section = ((NSNumber*)fragmentData[@"section"]).integerValue;
        if ([@"replace" isEqualToString:dataCommand]) {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.data];
            if ([temp[section] isKindOfClass:[NSArray class]] ) {
                [temp replaceObjectAtIndex:section withObject:fragmentData[@"data"]];
            }else if ([temp[section] isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary *sectionTemp = [NSMutableDictionary dictionaryWithDictionary:temp[section]];
                [sectionTemp setObject:fragmentData[@"data"] forKey:@"rows"];
                [temp replaceObjectAtIndex:section withObject:sectionTemp];
            }
            self.data = temp;
            [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else if ([@"append" isEqualToString:dataCommand]){
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.data];
            if ([temp[section] isKindOfClass:[NSArray class]] ) {
                NSMutableArray *sectionTemp = [NSMutableArray arrayWithArray:temp[section]];
                [sectionTemp addObjectsFromArray:fragmentData[@"data"]];
                [temp replaceObjectAtIndex:section withObject:sectionTemp];
            }else if ([temp[section] isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary *sectionTemp = [NSMutableDictionary dictionaryWithDictionary:temp[section]];
                NSMutableArray *arr = [NSMutableArray arrayWithArray:sectionTemp[@"rows"]];
                [arr addObjectsFromArray:fragmentData[@"data"]];
                [sectionTemp setObject:arr forKey:@"rows"];
                [temp replaceObjectAtIndex:section withObject:sectionTemp];
            }
            self.data = temp;
            [self reloadData];
        }
    }
    if (json[@"method"]) {
        NSString *method = json[@"method"];
        if ([@"closeRefresh" isEqualToString:method]) {
            if (self.header) {
                [self.header endRefreshing];
            }
        }
        if ([@"closeLoadMore" isEqualToString:method]) {
            if (self.footer) {
                [self.footer endRefreshing];
            }
        }
        if ([@"noMoreData" isEqualToString:method]) {
            if (self.footer) {
                [self.footer noticeNoMoreData];
            }
        }
        if ([@"resetMoreData" isEqualToString:method]) {
            if (self.footer) {
                [self.footer resetNoMoreData];
            }
        }
//        if ([@"removeLoadMore" isEqualToString:method]) {
//            if (self.footer) {
//                [self removeFooter];
//            }
//        }
        if ([@"showLoadMore" isEqualToString:method]) {
            if (self.footer) {
                [self.footer setHidden:NO];
            }
        }
        return;
    }
}
//tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.data[section] isKindOfClass:[NSArray class]]) {
        return ((NSArray*)self.data[section]).count;
    }
    else
    {
        return ((NSArray*)self.data[section][@"rows"]).count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem;
    if ([self.data[indexPath.section] isKindOfClass:[NSArray class]]) {
        cellItem = self.data[indexPath.section][indexPath.row];
    }
    else
    {
        cellItem = self.data[indexPath.section][@"rows"][indexPath.row];
    }
    if (cellItem[@"height"]) {
        return ((NSNumber*)cellItem[@"height"]).floatValue;
    }
    return tableView.rowHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem;
    if ([self.data[indexPath.section] isKindOfClass:[NSArray class]]) {
        cellItem = self.data[indexPath.section][indexPath.row];
    }
    else
    {
        cellItem = self.data[indexPath.section][@"rows"][indexPath.row];
    }
    NSString *type = cellItem[@"class"];
    NSString *res = cellItem[@"res"];
    NSString *reuseIdentifier = type?type:cellItem[@"res"];
    reuseIdentifier = reuseIdentifier?reuseIdentifier:@"HeroTableViewCell";
    HeroTableViewCell *cell = nil;
    if (res || ![type isEqualToString:@"UIView"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    } else {
        reuseIdentifier = [NSString stringWithFormat:@"%d-%d-%d",refeshTimes, indexPath.section, indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    if (!cell) {
        if (!type && !res) {
            cell = [[HeroTableViewCell alloc]initWithJson:cellItem];
            cell.controller = self.controller;
            [cell on:cellItem];
        }
        else
        {
            if (type) {
                cell = [[NSClassFromString(type) alloc]init];
            }else
            {
                cell = [[NSBundle mainBundle] loadNibNamed:res owner:nil options:nil][0];
            }
            if([cell isKindOfClass:[UITableViewCell class]]){
                cell.controller = self.controller;
                [cell on:cellItem];
            }else{
                cell.controller = self.controller;
                [cell on:cellItem];
                HeroTableViewCell *anotherCell = [[HeroTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                anotherCell.heroContentView = cell;
                anotherCell.backgroundColor = [UIColor clearColor];
                anotherCell.frame = cell.bounds;
                [anotherCell addSubview:cell];
                anotherCell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell = anotherCell;
            }
        }
    }else{
        if (cell.heroContentView) {
//            [cell.heroContentView on:cellItem];
        }else{
            [cell on:cellItem];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.data[section] isKindOfClass:[NSArray class]]) {
        return 0;
    }
    NSDictionary *sectionView = self.data[section][@"sectionView"];
    if (sectionView) {
        return ((NSNumber*)sectionView[@"height"]).floatValue;
    }
    NSString *sectionTitle = self.data[section][@"sectionTitle"];
    if (sectionTitle) {
        return 44;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self.data[section] isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSDictionary *sectionView = self.data[section][@"sectionView"];
    if (sectionView[@"class"]) {
        if (!_headerViews) {
            _headerViews = [NSMutableDictionary dictionary];
        }
        NSString *reuseIdentifer = [NSString stringWithFormat:@"%@_%ld",sectionView[@"class"],section];
        if ([_headerViews valueForKey:reuseIdentifer]) {
            return [_headerViews valueForKey:reuseIdentifer];
        }
        UIView *view = [[NSClassFromString(sectionView[@"class"]) alloc]init];
        view.controller = self.controller;
        view.json = sectionView;
        
        [_headerViews setObject:view forKey:reuseIdentifer];
        return view;
    }
    return nil;
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.data[section] isKindOfClass:[NSDictionary class]]) {
        NSString *sectionTitle = self.data[section][@"sectionTitle"];
        if (sectionTitle) {
            return sectionTitle;
        }
    }
    return NULL;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if ([self.data[section] isKindOfClass:[NSDictionary class]]) {
        NSString *sectionTitle = self.data[section][@"sectionFootTitle"];
        if (sectionTitle) {
            return sectionTitle;
        }
    }
    return NULL;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem;
    if ([self.data[indexPath.section] isKindOfClass:[NSArray class]]) {
        cellItem = self.data[indexPath.section][indexPath.row];
    }
    else
    {
        cellItem = self.data[indexPath.section][@"rows"][indexPath.row];
    }
    if (cellItem[@"canEdit"]) {
        return YES;
    }
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem;
    if ([self.data[indexPath.section] isKindOfClass:[NSArray class]]) {
        cellItem = self.data[indexPath.section][indexPath.row];
    }
    else
    {
        cellItem = self.data[indexPath.section][@"rows"][indexPath.row];
    }
    if (cellItem[@"canMove"]) {
        return YES;
    }
    return NO;
    
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem;
    if ([self.data[indexPath.section] isKindOfClass:[NSArray class]]) {
        cellItem = self.data[indexPath.section][indexPath.row];
    }
    else
    {
        cellItem = self.data[indexPath.section][@"rows"][indexPath.row];
    }
    if (cellItem[@"action"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.controller on:cellItem[@"action"]];
        });
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.controller on:cellItem];
        });
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];
    }
}
//index
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.dataIndex;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    for (int i = 0;i< self.dataIndex.count;i++) {
        if ([title isEqualToString:self.dataIndex[i]]) {
            return i;
        }
    }
    return 0;
}
#pragma mark scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self endEditing:YES];
}

@end
