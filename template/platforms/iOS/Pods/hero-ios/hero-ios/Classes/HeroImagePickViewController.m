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

//
//  Created by 朱成尧 on 4/26/16.
//

#import "hero.h"
#import "UIImage+alpha.h"
#import "HeroBadgeLabel.h"
#import "HeroImagePickViewController.h"
#import "HeroImagePickFlowLayout.h"
#import "HeroImageCell.h"
#import "NSURL+HeroUrlEqual.h"
#import "HeroTakePicCell.h"
#import "HeroPhotoBrowerViewController.h"
#import <AssetsLibrary/ALAssetsGroup.h>

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *addIdentifier = @"addIdentifier"; // 相机

@interface HeroImagePickViewController () <UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, HeroAsssetViewCellDelegate> {

    NSUInteger _maxSelectNum;
}

@property (nonatomic) HeroBadgeLabel *badgeView;
@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) ALAssetsGroupType assetsGroupType;
@property (nonatomic) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, weak) id delegate;


@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *selectedAssetsArray;

@property (nonatomic) UIImagePickerController *picker;


@end

@implementation HeroImagePickViewController

- (instancetype)init {
    NSAssert(NO, @"no support");
    return nil;
}

- (instancetype)initWithGroupType:(ALAssetsGroupType)groupType delegate:(id)delegate {
    return [self initWithGroupType:groupType maxSelect:NSUIntegerMax delegate:delegate];
}

- (instancetype)initWithGroupType:(ALAssetsGroupType)groupType maxSelect:(NSUInteger)nums delegate:(id)delegate {
    if (self = [super init]) {
        _maxSelectNum = nums;
        _assetsGroupType = groupType;
        _assetsArray = [NSMutableArray array];
        _selectedAssetsArray = [NSMutableArray array];
        _delegate = delegate;
    }
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [leftBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(onCancelTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];

    UIView *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];

    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 40, 40)];
    [rightBtn setTitle:NSLocalizedString(@"添加", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onGoTapped) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBtn];
    _badgeView = [[HeroBadgeLabel alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    _badgeView.title = @"0";
    [rightView addSubview:_badgeView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[HeroImagePickFlowLayout alloc] init]];
    [self.collectionView registerClass:[HeroImageCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[HeroTakePicCell class] forCellWithReuseIdentifier:addIdentifier];

    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];

    _assetsLibrary = [[ALAssetsLibrary alloc] init];

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x212124)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)onCancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onGoTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(heroImagePickViewController:imagesAssets:)]) {
        [_delegate heroImagePickViewController:self imagesAssets:self.selectedAssetsArray];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData {
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [self.assetsArray insertObject:[result valueForProperty:ALAssetPropertyAssetURL] atIndex:0];
            }
        }
    };
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [self.collectionView reloadData];
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:self.assetsGroupType usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (BOOL)assetIsSelected:(NSURL *)targetAssetURL {
    for (NSURL *assetURL in self.selectedAssetsArray) {
        if ([assetURL isEqualToOther:targetAssetURL]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeAssetsObject:(NSURL *)assetURL {
    if ([self assetIsSelected:assetURL]) {
        [self.selectedAssetsArray removeObject:assetURL];
    }
}

- (void)addAssetsObject:(NSURL *)assetURL {
    [self.selectedAssetsArray addObject:assetURL];
}


#pragma mark <HeroAsssetViewCellDelegate>

- (void)didUpdateItemAssetsViewCell:(HeroImageCell *)assetsCell {
    if (assetsCell.isSelected) {
        if (![self assetIsSelected:assetsCell.assetURL]) {
            [self addAssetsObject:assetsCell.assetURL];
        }
    } else {
        [self removeAssetsObject:assetsCell.assetURL];
    }
    self.badgeView.title = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssetsArray.count];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HeroTakePicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:addIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        HeroImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell setAssetURL:self.assetsArray[indexPath.row - 1] isSelected:[self assetIsSelected:self.assetsArray[indexPath.row - 1]]];
        cell.delegate = self;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // take photo
        [self takePhoto];
    } else {
        HeroPhotoBrowerViewController *vc = [[HeroPhotoBrowerViewController alloc] initWithPhotos:self.assetsArray currentIndex:indexPath.row - 1];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)takePhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        _picker.sourceType = sourceType;
        [self presentViewController:_picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法打开相机，请确认权限" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            } else {
                [self.assetsArray insertObject:assetURL atIndex:0];
                [self addAssetsObject:assetURL];
                [self.collectionView reloadData];
            }
        }];

        [self.picker dismissViewControllerAnimated:NO completion:nil];

        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _picker = [[UIImagePickerController alloc] init];
            _picker.delegate = self;
            _picker.allowsEditing = NO;
            _picker.sourceType = sourceType;
            [self presentViewController:_picker animated:NO completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法打开相机，请确认权限" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - HeroPhotoBrowserDelegate

- (BOOL)photoBrowser:(HeroPhotoBrowerViewController *)photoBrowser currentPhotoAssetURLIsSeleted:(NSURL *)assetURL{
    return [self assetIsSelected:assetURL];
}

- (void)photoBrowser:(HeroPhotoBrowerViewController *)photoBrowser seletedAssetURL:(NSURL *)assetURL {
    [self addAssetsObject:assetURL];
    [self.collectionView reloadData];
}

- (void)photoBrowser:(HeroPhotoBrowerViewController *)photoBrowser deseletedAssetURL:(NSURL *)assetURL {
    [self removeAssetsObject:assetURL];
    [self.collectionView reloadData];
}

@end
