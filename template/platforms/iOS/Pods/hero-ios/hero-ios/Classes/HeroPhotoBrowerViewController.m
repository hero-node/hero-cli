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
//  Created by 朱成尧 on 5/5/16.
//

#import "HeroPhotoBrowerViewController.h"
#import "HeroBrowserCell.h"

static NSString *checkedBase64 = @"iVBORw0KGgoAAAANSUhEUgAAAFAAAABQCAMAAAC5zwKfAAAAAXNSR0IArs4c6QAAAdFQTFRFAAAAAP//ANWqANuSAMaOAMaOAL+ZAL+SAMSRAL2UAL6QAL6OALyQAL2OAL6PAL2OAL2OAL2PAL6OAL6PAL2PAL2NAL2OAL6NALyNAL2NAL2NALyOAL2NAL2OALyOAL2NALyOAL2OALyNALyNALyOAL2OALyOALyNAL2OALyNAbyNAryNA7yOBL2OBb2PBr2PB72QCL6QCr6RDL+SDb+SDr+TEMCUE8CVFMGVFcGWFsGWF8KXGMKXGcKYGsKYG8OZHMOZHcOZHsOaH8SaIMSbIsScJcWdJ8aeKcafLMegMciiNcmkNsqlOcqmOsumPMunQ82qR86sSc+tSs+uTM+uTdCvWNO0XdS2X9S3YtW4Zda6Zta6a9i8b9m+dNrAetzDe9zDft3Fg97HiN/Jid/KjuHMk+LOmeTRpefWqujZr+nbsOrbtuveuuzgu+3gvO3hvu3hwu7jw+/kxO/kxe/lyPDmy/HnzPHozfHo0PLp0fLq0vPq0/Pr1PPr1fPs1vTs1/Tt2PTt2fXu2vXu2/Xu3PXv3fbv3vbw3/bw4Pbx4ffx5Pfy6Pj06vn16/n27Pr27fr27/r38vv59Pz69fz6+f38+v38+/39/f7+/v7+////eNqCTAAAACl0Uk5TAAEGBwkSFBweHyc/RU1SaGxtcXKPkpOUnbG6u8XR0tXd3+Ll7O/x+f4CaWuJAAADNElEQVRYw8WZ6V/TMBjHA2wgbGM3uzfGzqhDUUGd3Igo4n3ft+It3rdzgoAiKHiRv9Yx1pS1aZt02cffuz1pvmvaJ8/z5CkA6qo321r84Wg8lYpHw/4Wm7ke6JfB4gqloUTpkMti0EOrMXmTUEFJr6mGEVdnbYWqarXWsazVEYOaijmoV26JQipFLVS4Rh+klm+dNq85ARmUaNbA1boho9y1ajxjEDIraFTmNUSgDkUalHhNbVCX2poU7k8nr0Ak3qMxAnUrQniOtUFYgYLyd+2GFckt82dYoSQe3pioFJgo34U+WLF8ZfEFctCa2GOI8gBGxfjohFzkwPE+pmd65mC7NIYLWcGqh7fzNcr3SmzWUn5r1cHLvkMI5XskmWs1F5r08hDK7Sg3m4pALztv13u0qqvldm/RZ5LsvA8lHjonqQAMupy6G/PubCQ4t4uZlxN4Ex3SMVcBGGLk9XwUeG+7ZIOhQr2W1sv70icfTdcDMxuvNy/wvu8ljZuBnY33SeD9PEC8wAY8LLw+zPtznHyFBwRYeJMCD51RuCQAwgTr2eeXMwRz/xTmXVL6zzCQx9bMrcKMpwMy+4DIu6kcZUFcaup8UJyzcEzK+4x5tzcoAuMgJTVdKc1avl627EGR92iz8mNOyYHn8cQn/Wt409j8qhOqAWVLztzFUxeOCsYhkTfdreYIccJL2XQPT16+trrsoRls+rZHPfWR3KbjIZ6OHq9s2N2z+PfSfnVXDRMde8uESJw/AUdE3u8jGr7vJ2+9bc9EIpr5Kz6CU1qbqQXYiPaul4iki5q706YUvra/IfBuaG93s2KAzeZkvPH1mrxCgFVMAb1TEt79du0bDKklqcHZMt6LrRQBzqWaRoe/ruFNZmlrRJVEPzKHeXPDNLxiolcrRfbNl3iLo1Qh3atZLI3+KPJ+HabLESbtcm5scWWDnKTjlco59YLz0BJCFyiTmJWqJB4bP03JwyUxcHAu2vkfK7gffPgfzfgfHrkfb/kfwPm3CLg3Mfi3Wfg3gvi3qvg30/i3+/g3JKvQMuXf1F2Jj06atrPT8P8a41Vo3Vfh4wL+/GH3BITPHwGPXfPzxz9zJe1egla7hQAAAABJRU5ErkJggg==";
static NSString *unCheckBase64 = @"iVBORw0KGgoAAAANSUhEUgAAAFAAAABQCAMAAAC5zwKfAAAAAXNSR0IArs4c6QAAAgFQTFRFAAAA////////////////////////////////////////AAAABQUFCgoKDg4OExMTFxcXHBwcICAgKCgoKysrMDAwMzMzNjY2PT09QUFB////SUlJTExMU1NTVVVV////V1dXWlpaXV1da2trbW1t////cXFxeHh4////e3t7fn5+hISEj4+PkpKSmJiYm5ubnp6e////pqamqqqq////q6ur////rKysr6+v////sbGx////tbW1uLi4urq6vb29vr6+vr6+v7+/wsLCw8PDycnJycnJysrKzMzMzc3N////0NDQ////////////09PT09PT09PT1dXV2NjY2NjY////2tra29vb29vb3d3d39/f39/f39/f4ODg4ODg4eHh4eHh4uLi4uLi4uLi4+Pj4+Pj5OTk////5OTk5OTk5eXl5ubm5ubm5ubm5ubm5+fn5+fn////6Ojo6enp////6urq6+vr6+vr7e3t////7e3t7u7u8PDw8PDw8PDw8PDw8vLy////8vLy////8/Pz////8/Pz9PT09PT09PT09fX19vb29vb29vb2////////9/f3////9/f3+Pj4////+Pj4////+/v7+/v7/////Pz8/////f39/f39/f39/f39/f39/v7+/v7+/////v7+/v7+////////////////////ZipLEQAAAKp0Uk5TAAEGBwkSFBweHyczMzQ1Njc3ODo7Ozw9Pz8/QkNERUVGR0dMTU1PUVJTU1dbXmFjZGhqbGxtbW5wcXJydXd6fH1+f4KDiYqLjY+PkZKTlJWWl5mbnJ2foaOlp6ipqqurrK2ur6+wsbGys7O0tba3t7i6u7u7vr/AxcXHyMvMzc7R0dLS09XX19ja29vc3d3f4uLj5eXm7O3v7/Dx8vP19vf3+Pn6+/v8/f71WoPVAAAEHElEQVRYw8WZaVsbVRiG39KQ2h6SGnEjqQ0SU6pBDRqJCC61No0IWEHq1mrUtqh1Q0FFBYwJgqllpIEogkskFvP8Sj8kOZl95kyGy+db5lxzZ87Mux8ic3nDibGZnFTa3S1JuZmxRNhLzuWJjmSrUKmaHYl6nNAOBKe2AZQXM+lkLBIKBEKRWDKdWSwD2J4KHhDEHexfA5CfiAeYSoH4RB7AWv9Bkb0ObgDFyV5moN7JIrAxaHvnUQlYGfYxE/mGVwApagt3eBpYTTJLJVeB6VuseSe3sJPyMxvyp3awddIC1zYKzHUzm+qeA0bbzHjt86ikmIBSFcy3G/MOLWOzjwmpbxPLh4x4R9ZR6GGC6ilg/YjB861jqYsJq2sJ67rP2L6MpU7mQJ1LWNZ5j23zKHQxR+oqYF77rUex2cMcqmcToxp7RqWPOVZfBSoLP7yFFGtBKWwpvXAac6wlzWFaEV+w090asHsHstjjkVrbcG3TUjM+DmHV3yrQv4pBHu83kHSAuFMVH7HRyAr9WHHAO1/5/rjiwgr66/ltDcPivNcBXL9HfmUYa7VcGETRJ8x7AwBw7Zg8zxQRJCKiKUwK8y7U0/4V+cVJTBERebbRK4jruNioIxTu0IttDxFFkRflvdng/faAYiGPKBGNYEKQ91aDV35IuTKBESLKIi7GyzR4e4+rluLIEnmr5YAQ721eiJ3W1D3lqpfCWBDivcN5L2pXFxCmAWREeO9y3kWd5QwSNI60AO8S532u5wxpjNOsQGDwXea8b2/TLaAwSznEtCni3H26vPc478e7df8xhhxJiKgvn93DX8+a8or36m8hAolKCKkiZc2vrtyu5r3Peb8a+WoIJdqFygzP1+/6SelWvg84788HjV5yALta4Nf8vlNy3lXOu/kYMwNqtvzw3/zWy7zW8X3YbFROGZtBCCWdj/Johd987f76e/2o2fm8YGJXEUh6ZvPEzebreoYxxvwfN3mvmRlqDDldw35yrwm41Mn8nzR/ftph2hlgRt/1nv63ifj5pe+aP74xj0xpjFFCNzg8p2kaAQA/3GXumxkkKIxFvaUzerwbxy2cfRFhwwD7vJb3ywkLXqBc9RqngHNq3h+WFWkcWbMk9bKS988jluGtlqSM0+irik7+Ket4WUujJon+ggxoI67XE71JKSLLIK/YCOj1UoSCKBqZP48JVztsJIhGsWRWzvk/AwB8ddTGA/JyzrTgvPULAPk77KQwXnCal8SBL1E4ZocnK4lp0LRoP2GrHJUX7e63FW40Pr8jup+tmfvNo+vtrfsNuPsjAteHGO6PWdwfBLk/qnJ/mOb+uM/9geQ+jEz5ULfDraEuEXmG7Iydhzz/32BcPrpfUI7uFxyO7vfhcIEffwyMzzaOP2bHByyPP/4DBlkYYZmQo7YAAAAASUVORK5CYII=";

@interface HeroPhotoBrowerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    BOOL _didSavePreviousStateOfNavBar;
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
}


@property (nonatomic, strong) UICollectionView *browserCollectionView;
@property (nonatomic, strong) UIButton *checkButton;

@property (nonatomic, strong) NSMutableArray *photoDataSources;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, getter=isFullImage) BOOL fullImage;


@end

@implementation HeroPhotoBrowerViewController

- (instancetype)initWithPhotos:(NSArray *)photoArray currentIndex:(NSInteger)index {
    if (self = [super init]) {
        _photoDataSources = [[NSMutableArray alloc] initWithArray:photoArray];
        _currentIndex = index;
        _fullImage = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self updateNavigationBarAndToolBar];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.backItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    [self setNavBarAppearance:animated];

    [self.browserCollectionView setContentOffset:CGPointMake(self.browserCollectionView.frame.size.width * self.currentIndex,0)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setControlsHidden:NO animated:NO];

    // Super
    [super viewWillDisappear:animated];
}


#pragma mark - priviate
- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    [self browserCollectionView];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.checkButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self backButton]];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)setupData {
    self.photoDataSources = [NSMutableArray new];
}

- (void)updateNavigationBarAndToolBar {
    NSUInteger totalNumber = self.photoDataSources.count;
    self.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex+1),@(totalNumber)];
    BOOL isSeleted = NO;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:currentPhotoAssetURLIsSeleted:)]) {
        isSeleted = [self.delegate photoBrowser:self currentPhotoAssetURLIsSeleted:[self.photoDataSources objectAtIndex:self.currentIndex]];
    }
    self.checkButton.selected = isSeleted;
}

#pragma mark - Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - ui actions
- (void)checkButtonAction {
    if (self.checkButton.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:deseletedAssetURL:)]) {
            [self.delegate photoBrowser:self deseletedAssetURL:self.photoDataSources[self.currentIndex]];
            self.checkButton.selected = NO;
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:seletedAssetURL:)]) {
            [self.delegate photoBrowser:self seletedAssetURL:self.photoDataSources[self.currentIndex]];
            self.checkButton.selected = YES;
        }
    }
}

- (void)onBackTapped {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - get/set
- (UIButton *)checkButton {
    if (nil == _checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(0, 0, 25, 25);
        [_checkButton setBackgroundImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:unCheckBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters]] forState:UIControlStateNormal];
        [_checkButton setBackgroundImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:checkedBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters]] forState:UIControlStateSelected];
        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (UIButton *)backButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackTapped) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

- (UICollectionView *)browserCollectionView {
    if (nil == _browserCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _browserCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height+1) collectionViewLayout:layout];
        _browserCollectionView.backgroundColor = [UIColor blackColor];
        [_browserCollectionView registerClass:[HeroBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([HeroBrowserCell class])];
        _browserCollectionView.delegate = self;
        _browserCollectionView.dataSource = self;
        _browserCollectionView.pagingEnabled = YES;
        _browserCollectionView.showsHorizontalScrollIndicator = NO;
        _browserCollectionView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_browserCollectionView];
    }
    return _browserCollectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoDataSources count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HeroBrowserCell *cell = (HeroBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HeroBrowserCell class]) forIndexPath:indexPath];

    cell.assetURL = [self.photoDataSources objectAtIndex:indexPath.row];
    cell.photoBrowser = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width + 20, self.view.bounds.size.height);
}

#pragma mark - scrollerViewDelegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.browserCollectionView.frame);
    if (offsetX >= 0){
        NSInteger page = offsetX / itemWidth;
        [self didScrollToPage:page];
    }
}

- (void)didScrollToPage:(NSInteger)page {
    self.currentIndex = page;
    [self updateNavigationBarAndToolBar];
}

#pragma mark - Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    if (nil == self.photoDataSources || self.photoDataSources.count == 0)
        hidden = NO;
    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);

    [UIView animateWithDuration:animationDuration animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
    } completion:nil];
}

- (BOOL)areControlsHidden {
    return (self.navigationController.navigationBar.alpha == 0);
}
- (void)toggleControls {
    [self setControlsHidden:![self areControlsHidden] animated:YES];
}

@end
