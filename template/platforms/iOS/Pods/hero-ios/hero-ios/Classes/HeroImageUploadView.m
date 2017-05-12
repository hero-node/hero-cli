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

//  Created by 朱成尧 on 4/26/16.
//
#import "hero.h"
#import "HeroImageUploadView.h"
#import "HeroUploadCell.h"
#import "HeroUploadFlowLayout.h"
#import "HeroAddCell.h"
#import "HeroImagePickViewController.h"
#import "UIAlertView+blockDelegate.h"
#import "HeroUploadItem.h"
#import "HeroImageUploadManager.h"
#import <AssetsLibrary/ALAsset.h>

#define kMaxRowsNum   2
#define kTopPadding    15
#define kLeftPadding   15

#define kPixsLevel   0.3 // 照片上传质量
/*
 topPad
 leftPad image >spacingPad image leftPad
 spacingPad
 leftPad image >spacingPad image leftPad
 topPad
 */

@interface HeroImageUploadView () <UICollectionViewDelegate, UICollectionViewDataSource, HeroImageUploaderDelegate, HeroUploadItemDelegate, HeroUploadCellDelegate> {
    NSUInteger _lastRow;
    id actionObject;
}

@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSMutableArray *uploadArray;

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) HeroImageUploadManager *manager;

@property (nonatomic) NSString *uploadName;
@property (nonatomic) NSString *uploadUrl;
@property (nonatomic) NSUInteger maxLines;

@property (nonatomic) UICollectionViewCell *deleteCell; // 代码已经面目全非


@end

@implementation HeroImageUploadView

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *addIdentifier = @"addIdentifier";

- (instancetype)init {
    if (self = [super init]) {
        _lastRow = 0;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[HeroUploadFlowLayout alloc] init]];
        [self.collectionView registerClass:[HeroUploadCell class] forCellWithReuseIdentifier:cellIdentifier];
        [self.collectionView registerClass:[HeroAddCell class] forCellWithReuseIdentifier:addIdentifier];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self addSubview:self.collectionView];
        self.maxLines = kMaxRowsNum;
        _imageArray = [NSMutableArray array];
        _uploadArray = [NSMutableArray array];
        _manager = [HeroImageUploadManager sharedInstance];
        [_manager setMaxConcurrentUploads:2];
    }
    return self;
}

- (void)dealloc {
    [_manager cancelAllUploads];
    _manager = nil;
}

- (void)on:(NSDictionary *)json {
    [super on:json];

    if (json[@"maxLines"]) {
        self.maxLines = [json[@"maxLines"] integerValue];
    }
    if (json[@"uploadAction"]) {
        actionObject = json[@"uploadAction"];
    }
    if (json[@"uploadName"]) {
        _uploadName = json[@"uploadName"];
    }
    if (json[@"uploadUrl"]) {
        _uploadUrl = json[@"uploadUrl"];
    }
    if (json[@"images"]) {
        NSArray *array = json[@"images"];
        NSMutableArray *arrayRet = [NSMutableArray array];
        NSMutableArray *arrayUp = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HeroUploadItem *item = [HeroUploadItem new];
            if(![obj isKindOfClass:[NSURL class]]) {
                item.imgUrl = obj[@"imgUrl"]?:@"";
                item.thumbImgUrl = obj[@"thumbImgUrl"]?:@"";
                item.createdDate = obj[@"createdDate"]?:@"";
                item.docId = obj[@"docId"]?:@"";
                item.fileId = obj[@"fileId"]?:@"";
                item.filename = obj[@"filename"]?:@"";
                [arrayRet addObject:obj];
            } else {
                item.localImgURL = [NSURL URLWithString:obj];
                [arrayRet addObject:[NSURL URLWithString:obj]];
            }
            [arrayUp addObject:item];
        }];
        self.imageArray = arrayRet;
        self.uploadArray = arrayUp;
    }
    if (json[@"deleteItem"]) {
        [self.collectionView performBatchUpdates:^{
            [self removeUploadCelltAtIndex:[self.collectionView indexPathForCell:_deleteCell].row];
            [self.collectionView deleteItemsAtIndexPaths:@[[self.collectionView indexPathForCell:_deleteCell]]];
            [self reloadHeight];
            [self updateTotal];
        } completion:nil];
    }
    if (!json[@"deleteItem"]) {
        [self reloadData];
    }
}

- (void)reloadData {
    [self reloadHeight];
    [self.collectionView reloadData];
}

- (void)reloadHeight {
    // 行数高度计算
    self.collectionView.frame = CGRectMake(kLeftPadding - kOutSizeWidth, kTopPadding - kOutSizeWidth, self.bounds.size.width - 2 * (kLeftPadding - kOutSizeWidth), self.bounds.size.height - 2 * (kTopPadding - kOutSizeWidth));

    NSUInteger row = [self numberOfRows];
    if (_lastRow != row) {
        _lastRow = row;
        if (row > 1) {
            NSMutableArray *mut = [NSMutableArray array];
            [self.imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![obj isKindOfClass:[NSURL class]]) {
                    [mut addObject:obj];
                } else {
                    [mut addObject:((NSURL *)obj).absoluteString];
                }
            }];
            CGFloat height = kImageHeight * row + 2 * kTopPadding + kSpacingPadding * (row - 1);
            [self on:@{@"frame":@{@"x":[@(self.frame.origin.x) description],@"y":[@(self.frame.origin.y) description],@"w":[@(self.frame.size.width) description],@"h":[@(height) description],@"animation":@(0.25),@"images":mut}}];
        } else {
            [self on:@{@"animation":@(0.25),@"frame":@{@"x":[@(self.frame.origin.x) description],@"y":[@(self.frame.origin.y) description],@"w":[@(self.frame.size.width) description],@"h":[@(kImageHeight + 2 * kTopPadding) description],}}];
        }
    }
}

- (NSUInteger)numberOfRows {
    if (self.imageArray.count > 0) {
        // 一行最多显示个数
        NSUInteger numOfRow = ((NSUInteger)(self.frame.size.width - 2 * kLeftPadding + kSpacingPadding)) / (kImageHeight + kSpacingPadding);
        if (numOfRow == 0) { // 设置不对宽度问题
            return 1;
        }
        NSUInteger numOfRows = (self.imageArray.count + 1 + (numOfRow - 1)) / numOfRow;
        return MIN(numOfRows, self.maxLines);
    } else {
        return 1;
    }
}

- (void)removeUploadCelltAtIndex:(NSUInteger)index {
    [_imageArray removeObjectAtIndex:index];
    [((HeroUploadItem *)(_uploadArray[index])).uploader cancel];
    [_uploadArray removeObjectAtIndex:index];
}

#pragma mark <HeroUploadCellDeleget>

- (void)didDeleteItemUploadCell:(HeroUploadCell *)uploadCell {
    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"删除", nil) message:@"确认删除此图片" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] onDismiss:^(NSInteger buttonIndex) {
        if (uploadCell.uploaderItem.uploader && uploadCell.uploaderItem.uploader.state != HeroUploadStateUploaded) {
            [self.collectionView performBatchUpdates:^{
                [self removeUploadCelltAtIndex:[self.collectionView indexPathForCell:uploadCell].row];
                [self.collectionView deleteItemsAtIndexPaths:@[[self.collectionView indexPathForCell:uploadCell]]];
                [self reloadHeight];
            } completion:nil];
            [self updateTotal];
        } else {
            _deleteCell = uploadCell;
            NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithDictionary:actionObject];
            retDic[@"value"] = @NO;
            retDic[@"delete"] = @{@"docId":uploadCell.uploaderItem.docId,
                                  @"docFileId":uploadCell.uploaderItem.fileId,};
            [self.controller on:retDic];
        }
    } onCancel:nil];
}

- (void)didReUploadCell:(HeroUploadCell *)uploadCell {
    NSUInteger index = [self.collectionView indexPathForCell:uploadCell].row;

    NSURL *obj = [self.uploadArray[index] localImgURL];

    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    __weak typeof(self) weakSelf = self;
    [lib assetForURL:obj resultBlock:^(ALAsset *asset){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (asset) {
            [strongSelf setReUploadAssetImage:asset cell:uploadCell];
        } else {
            [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                               usingBlock:^(ALAssetsGroup *group, BOOL *stop)
             {
                 [group enumerateAssetsWithOptions:NSEnumerationReverse
                                        usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {

                                            if([[result valueForProperty:ALAssetPropertyAssetURL] isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]])
                                            {
                                                [strongSelf setReUploadAssetImage:result cell:uploadCell];
                                                *stop = YES;
                                            }
                                        }];
             }
                             failureBlock:^(NSError *error)
             {
                 [strongSelf setReUploadAssetImage:nil cell:uploadCell];
             }];
        }

    } failureBlock:^(NSError *error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setReUploadAssetImage:nil cell:uploadCell];
    }];
    [self updateTotal];
}

- (void)setReUploadAssetImage:(ALAsset *)asset cell:(HeroUploadCell *)uploadCell {
    if (!asset) {
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    HeroUploadItem *item = _uploadArray[[self.collectionView indexPathForCell:uploadCell].row];
    HeroImageUploader *uploader = [[HeroImageUploader alloc] initWithURL:[NSURL URLWithString:_uploadUrl] data:UIImageJPEGRepresentation(image, kPixsLevel) fileName:[self uploadFileName] delegate:self];
    item.itemDelegate = self;
    item.uploader = uploader;
    uploader.delegate = item;
    uploadCell.delegate = self;
    uploadCell.uploaderItem = item;
    [_manager startUpload:uploader];
}

- (void)didUpdateItemUploadItem:(HeroUploadItem *)uploadItem {
    [self updateTotal];
}

- (void)didUploadItem:(HeroUploadItem *)uploadItem error:(NSError *)error {
    [self.controller on:@{@"datas":@{@"name":@"toast",@"text":error.localizedDescription}}];
    NSLog(@"%@",error.localizedDescription);
}

- (void)updateTotal {
    NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithDictionary:actionObject];
    NSMutableArray *success = [NSMutableArray array];
    NSMutableArray *failure = [NSMutableArray array];
    [self.uploadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HeroUploadItem *item = obj;
        if (!item.uploader) {
            [success addObject:@{
                                 @"imgUrl":[item imgUrl]?:@"",
                                 @"thumbImgUrl":[item thumbImgUrl]?:@"",
                                 @"createdDate":[item createdDate]?:@"",
                                 @"docId":[item docId]?:@"",
                                 @"fileId":[item fileId]?:@"",
                                 @"filename":[item filename]?:@"",
                                 }];
        }
        if (item.uploader.state == HeroUploadStateUploaded) {
            [success addObject:@{
                                 @"imgUrl":[item imgUrl]?:@"",
                                 @"thumbImgUrl":[item thumbImgUrl]?:@"",
                                 @"createdDate":[item createdDate]?:@"",
                                 @"docId":[item docId]?:@"",
                                 @"fileId":[item fileId]?:@"",
                                 @"filename":[item filename]?:@"",
                                 }];
        }
        if (item.uploader.state == HeroUploadStateFailed) {
            [failure addObject:@{
                                 @"imgUrl":[item imgUrl]?:@"",
                                 @"thumbImgUrl":[item thumbImgUrl]?:@"",
                                 @"createdDate":[item createdDate]?:@"",
                                 @"docId":[item docId]?:@"",
                                 @"fileId":[item fileId]?:@"",
                                 @"filename":[item filename]?:@"",
                                 }];
        }
    }];
    NSDictionary *tmpDic = @{
                             @"success":success,
                             @"failure":failure,
                             @"completed":@(success.count + failure.count == self.imageArray.count),
                            };
    [retDic setObject:tmpDic forKey:@"value"];
    [self.controller on:retDic];
}

- (void)heroImagePickViewController:(HeroImagePickViewController *)imagePick imagesAssets:(NSArray *)imagesAssets {
    [imagesAssets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_imageArray addObject:obj];
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        __weak typeof(self) weakSelf = self;
        [lib assetForURL:obj resultBlock:^(ALAsset *asset){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (asset) {
                [strongSelf setALAssetImage:asset];
            } else {
                [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                   usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                 {
                     [group enumerateAssetsWithOptions:NSEnumerationReverse
                                            usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {

                                                if([[result valueForProperty:ALAssetPropertyAssetURL] isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]])
                                                {
                                                    [strongSelf setALAssetImage:result];
                                                    *stop = YES;
                                                }
                                            }];
                 }
                                 failureBlock:^(NSError *error)
                 {
                     [strongSelf setALAssetImage:nil];
                 }];
            }
        } failureBlock:^(NSError *error){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setALAssetImage:nil];
        }];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateTotal];
        [self reloadData];
        // 移至最底部
        NSInteger rows = [self.collectionView numberOfItemsInSection:0] - 1;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:rows inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    });
}

- (void)setALAssetImage:(ALAsset *)asset {
    if (!asset) {
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    HeroUploadItem *item = [HeroUploadItem new];
    HeroImageUploader *uploader = [[HeroImageUploader alloc] initWithURL:[NSURL URLWithString:_uploadUrl] data:UIImageJPEGRepresentation(image, kPixsLevel) fileName:[self uploadFileName] delegate:self];
    item.itemDelegate = self;
    item.uploader = uploader;
    uploader.delegate = item; // 如果使用cell作为delegate 在复用时候可能数据丢失
    item.localImgURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [_manager startUpload:uploader];
    [_uploadArray addObject:item];
}

- (void)heroImagePickViewControllerDidCancel:(HeroImagePickViewController *)imagePick {
    NSLog(@"cancel");
}

- (NSString *)uploadFileName {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
    return [NSString stringWithFormat:@"%@%d",_uploadName,dTime];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.imageArray.count) {
        HeroAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:addIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        HeroUploadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        ((HeroUploadItem *)(self.uploadArray[indexPath.row])).delegate = cell; // 作为代理
        cell.uploaderItem = self.uploadArray[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.imageArray.count) {
        HeroImagePickViewController *imagePickVC = [[HeroImagePickViewController alloc] initWithGroupType:ALAssetsGroupSavedPhotos delegate:self];
        [self.controller presentViewController:[[UINavigationController alloc] initWithRootViewController:imagePickVC] animated:YES completion:nil];
    }
}

@end
