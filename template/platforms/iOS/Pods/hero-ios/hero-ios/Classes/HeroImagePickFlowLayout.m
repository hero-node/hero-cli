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
//  Created by 朱成尧 on 5/3/16.
//

#import "HeroImagePickFlowLayout.h"
#import "common.h"
#define kImageHeight   79
#define kSpacingPadding 9.5
#define kTotalImageWidth 84
#define kOutSizeWidth 5

@implementation HeroImagePickFlowLayout

- (instancetype)init {
    if (!(self = [super init])) return nil;
    self.itemSize = CGSizeMake((SCREEN_W - 3) / 4, (SCREEN_W - 3) / 4);
    self.minimumLineSpacing = 1;
    self.minimumInteritemSpacing = 1;
    return self;
}

//- (void)prepareLayout {
//    [super prepareLayout];
//}
//
//- (CGSize)collectionViewContentSize {
//    return self.collectionView.frame.size;
//}
//
//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    return NO;
//}
//
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray *attributes = [NSMutableArray array];
//    for (NSUInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i ++) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//    }
//    return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *cellAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    cellAttributes.size = CGSizeMake(kTotalImageWidth, kTotalImageWidth);
//
//    return cellAttributes;
//}
//
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    attributes.alpha = 0;
//    return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    attributes.alpha = 0;
//    attributes.transform3D = CATransform3DMakeScale(.1, .1, .1);
//    return attributes;
//}


@end
