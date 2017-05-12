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
//  Copyright © 2016 Liu Guoping. All rights reserved.
//


#import "HeroUploadCell.h"
#import "HeroUploadFlowLayout.h"
#import "NSURL+HeroUrlEqual.h"
#import "HeroUploadItem.h"
#import "common.h"
#import "UILazyImageView.h"

static NSString *deleteIconBase64 = @"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";

@interface HeroUploadCell ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *deleteView;

@property (nonatomic) UIView *maskView;
@property (nonatomic) UILabel *persentLbl;

@property (nonatomic) UIImageView *bigImageView;
@property (nonatomic) UIImage *bigImage;

@property (nonatomic) BOOL canDelete; // 暂时全部可以删除

@property (nonatomic) NSTimer *timer;


@end

@implementation HeroUploadCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:CGRectZero])) return nil;

    self.backgroundColor = [UIColor clearColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kOutSizeWidth, kOutSizeWidth, kImageHeight, kImageHeight)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTapped)]];

    self.deleteView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.deleteView.contentMode = UIViewContentModeScaleAspectFill;
    self.deleteView.image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:deleteIconBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    self.deleteView.clipsToBounds = YES;
    [self addSubview:self.deleteView];
    self.deleteView.userInteractionEnabled = YES;
    [self.deleteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeleteTapped)]];
    self.canDelete = YES;
    self.maskView = [[UIView alloc] initWithFrame:self.imageView.bounds];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.imageView addSubview:self.maskView];
    self.persentLbl = [[UILabel alloc] initWithFrame:self.imageView.bounds];
    self.persentLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.persentLbl.font = [UIFont systemFontOfSize:13];
    self.persentLbl.textColor = [UIColor colorWithWhite:.9 alpha:1];
    self.persentLbl.textAlignment = NSTextAlignmentCenter;
    self.persentLbl.numberOfLines = 0;
    [self.imageView addSubview:self.persentLbl];
    [self startTimer];
    return self;
}

- (void)willMoveToWindow:(UIWindow*)newWindow{
    [super willMoveToWindow:newWindow];
    if(newWindow == (id)[NSNull null] || newWindow ==nil){
        [self stopTimer];
    }
}

-(void)startTimer{
    if(_timer == nil){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)refresh {
    if (self.uploaderItem && self.uploaderItem.uploader || self.uploaderItem.uploader.state == HeroUploadStateUploading) {
        switch (self.uploaderItem.uploader.state) {
            case HeroUploadStateReady: {
                CGRect frame = self.imageView.bounds;
                self.maskView.frame = frame;
                self.persentLbl.text = @"等待上传";
                break;
            }
            case HeroUploadStateUploading: {
                CGRect frame = self.imageView.bounds;
                frame.origin.y = frame.size.height * self.uploaderItem.uploader.percentage;
                frame.size.height = frame.size.height - frame.size.height * self.uploaderItem.uploader.percentage;
                self.maskView.frame = frame;
                int persent = (int)(self.uploaderItem.uploader.percentage * 100);
                if (persent == 100) {
                    persent = 99;
                }
                self.persentLbl.text = [NSString stringWithFormat:@"%d%%",persent];
                break;
            }
            case HeroUploadStateUploaded: {
                self.maskView.frame = CGRectZero;
                self.persentLbl.text = @"";
                break;
            }
            case HeroUploadStateFailed: {
                CGRect frame = self.imageView.bounds;
                self.maskView.frame = frame;
                self.persentLbl.text = @"上传失败";
                break;
            }
            default:
                break;
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    self.uploaderItem = nil;
    self.persentLbl.text = @"";
    self.maskView.frame = CGRectZero;
}

- (void)setAssetURL:(NSURL *)assetURL {
    ALAssetsLibrary *lib = [ALAssetsLibrary new];

    __weak typeof(self) weakSelf = self;
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (asset) {
            [strongSelf setALAssetImage:asset];

        } else {
            // On iOS 8.1 [library assetForUrl] Photo Streams always returns nil. Try to obtain it in an alternative way
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
}


- (void)setALAssetImage:(ALAsset *)asset {
    if (!asset) {
        self.imageView.backgroundColor = [UIColor blueColor];
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
    self.bigImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    self.imageView.image = image;
}

- (void)setUploaderItem:(HeroUploadItem *)uploaderItem {
    if (uploaderItem.localImgURL) {
        [self setAssetURL:uploaderItem.localImgURL];
    } else {
        int scale = [[UIScreen mainScreen]scale];
        [UILazyImageView registerForName:uploaderItem.thumbImgUrl block:^(NSData *data) {
            self.imageView.alpha = 0.0f;
            self.imageView.image = [UIImage imageWithData:data scale:scale];
            [UIView animateWithDuration:0 animations:^{
                self.imageView.alpha = 1.0f;
            }];
        }];
    }
    if (uploaderItem.uploader) {
        switch (uploaderItem.uploader.state) {
            case HeroUploadStateReady: {
                CGRect frame = self.imageView.bounds;
                self.maskView.frame = frame;
                self.persentLbl.text = @"等待上传";
                break;
            }
            case HeroUploadStateUploading: {
                CGRect frame = self.imageView.bounds;
                frame.origin.y = frame.size.height * self.uploaderItem.uploader.percentage;
                frame.size.height = frame.size.height - frame.size.height * self.uploaderItem.uploader.percentage;
                self.maskView.frame = frame;
                int persent = (int)(uploaderItem.uploader.percentage * 100);
                if (persent == 100) {
                    persent = 99;
                }
                self.persentLbl.text = [NSString stringWithFormat:@"%d%%",persent];
                break;
            }
            case HeroUploadStateUploaded: {
                self.maskView.frame = CGRectZero;
                self.persentLbl.text = @"";
                break;
            }
            case HeroUploadStateFailed: {
                CGRect frame = self.imageView.bounds;
                self.maskView.frame = frame;
                self.persentLbl.text = @"上传失败";
                break;
            }
            default:
                break;
        }
    } else {
        self.maskView.frame = CGRectZero;
    }
    _uploaderItem = uploaderItem;
}

- (void)setCanDelete:(BOOL)canDelete {
    _canDelete = canDelete;
    self.deleteView.hidden = !canDelete;
}

- (void)onDeleteTapped {
    if (_canDelete) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteItemUploadCell:)]) {
            [self.delegate didDeleteItemUploadCell:self];
        }
    }
}

- (void)onImageTapped {
    if (self.uploaderItem.uploader && self.uploaderItem.uploader.state == HeroUploadStateFailed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReUploadCell:)]) {
            [self.delegate didReUploadCell:self];
        }
    }
    if (!self.uploaderItem.uploader || self.uploaderItem.uploader.state == HeroUploadStateUploaded) {
        CGRect rect = [self.superview convertRect:self.frame toView:KEY_WINDOW];
        UIScrollView *backgroundView = [[UIScrollView alloc]initWithFrame:rect];
        backgroundView.scrollEnabled = YES;
        backgroundView.maximumZoomScale = 2.0f;
        backgroundView.minimumZoomScale = 0.2f;
        backgroundView.bouncesZoom = false;
        backgroundView.delegate = self;
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        backgroundView.tag = 8989778;
        backgroundView.alpha = 0.1f;
        self.bigImageView = [[UIImageView alloc]initWithFrame:backgroundView.bounds];

        if (_uploaderItem.localImgURL) {
            self.bigImageView.image = self.bigImage;
        } else {
            int scale = [[UIScreen mainScreen]scale];
            [UILazyImageView registerForName:_uploaderItem.imgUrl block:^(NSData *data) {
                self.bigImageView.alpha = 0.0f;
                self.bigImageView.image = [UIImage imageWithData:data scale:scale];
                [UIView animateWithDuration:0.2 animations:^{
                    self.bigImageView.alpha = 1.0f;
                }];
            }];
        }
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        [backgroundView addSubview:self.bigImageView];
        UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapDone:)];
        doneTap.delaysTouchesBegan = true;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapDouble:)];
        doubleTap.numberOfTapsRequired = 2;
        [doneTap requireGestureRecognizerToFail:doubleTap];
        [backgroundView addGestureRecognizer:doneTap];
        [backgroundView addGestureRecognizer:doubleTap];
        [KEY_WINDOW addSubview:backgroundView];
        [UIView animateWithDuration:0.3 animations:^{
            backgroundView.alpha = 1.0f;
            backgroundView.frame= [UIScreen mainScreen].bounds;
            self.bigImageView.frame= [UIScreen mainScreen].bounds;
        }];
    }
}

-(void)onTapDone:(id)sender{
    UIView *view = [KEY_WINDOW viewWithTag:8989778];
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha= 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
-(void)onTapDouble:(UITapGestureRecognizer*)sender{
    [((UIScrollView*)sender.view) setZoomScale:1.5f animated:YES];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.bigImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.bigImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale < .5f) {
        [self onTapDone:nil];
    }
}

- (void)upload:(HeroImageUploader *)uploader didSendFirstRespone:(NSURLResponse *)response {
    [self refresh];
}

- (void)upload:(HeroImageUploader *)uploader didSendData:(uint64_t)sendLength onTotal:(uint64_t)totalLength progress:(float)progress {
    [self refresh];
}

- (void)upload:(HeroImageUploader *)uploader didStopWithError:(NSError *)error {
    [self refresh];
}

- (void)upload:(HeroImageUploader *)uploader didFinishWithData:(id)data {
    [self refresh];
}

@end
