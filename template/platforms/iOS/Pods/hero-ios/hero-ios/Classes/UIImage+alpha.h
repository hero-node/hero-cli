//
//  UIImage+alpha.h
//  CloudKnows
//
//  Created by atman on 13-6-7.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (alpha)
- (BOOL)hasAlpha ;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize ;
- (CGImageRef)createBorderMask:(NSUInteger)borderSize size:(CGSize)size;
- (UIImage *) imageWithBackgroundColor:(UIColor *)bgColor
                           shadeAlpha1:(CGFloat)alpha1
                           shadeAlpha2:(CGFloat)alpha2
                           shadeAlpha3:(CGFloat)alpha3
                           shadowColor:(UIColor *)shadowColor
                          shadowOffset:(CGSize)shadowOffset
                            shadowBlur:(CGFloat)shadowBlur;
+ (UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize;
+(UIImage *)rotateImage:(UIImage *)aImage origention:(UIImageOrientation)orientation;
+ (UIImage *)createGrayCopy:(UIImage *)sourceImage;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage*) drawGradientInRect:(CGSize)size withColors:(NSArray*)colors ;
+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)color1 endColor:(UIColor *)color2;
@end

typedef NS_ENUM(NSUInteger, BFAccuracy) {
    kBFAccuracyLow = 0,
    kBFAccuracyHigh,
};

@interface UIImage (BetterFace)

- (UIImage *)betterFaceImageForSize:(CGSize)size
                           accuracy:(BFAccuracy)accurary;

@end



@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

-(UIImage*)halfSize;
-(UIImage*)withRoam:(NSString*)finger;
-(UIImage*)withNoRoam:(NSString*)finger;
+(UIImage*)markWithNumber:(NSString*)finger;
+(UIImage*)markWithContent:(UIImage*)image;

-(UIImage*)round;
@end

@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
@end



@interface UIImage (Rounded)


/*
 用于将目标图片转成圆形图片
 */
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r withBoarderImage:(UIImage*)boarder;
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r withBoarderImage:(UIImage*)boarder andFingerImage:(UIImage*)finger;

/*
 图片等比例缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
/*
 图片适配缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image toBounds:(CGRect)rect;

@end
@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

@interface UIImage (Utility)

+ (UIImage*)fastImageWithData:(NSData*)data;
+ (UIImage*)fastImageWithContentsOfFile:(NSString*)path;

- (UIImage*)deepCopy;

- (UIImage*)resize:(CGSize)size;
- (UIImage*)aspectFit:(CGSize)size;
- (UIImage*)aspectFill:(CGSize)size;
- (UIImage*)aspectFill:(CGSize)size offset:(CGFloat)offset;

- (UIImage*)crop:(CGRect)rect;

- (UIImage*)maskedImage:(UIImage*)maskImage;

- (UIImage*)gaussBlur:(CGFloat)blurLevel;       //  {blurLevel | 0 ≤ t ≤ 1}

@end

