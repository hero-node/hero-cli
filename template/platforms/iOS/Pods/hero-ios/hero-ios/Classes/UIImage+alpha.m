//
//  UIImage+alpha.m
//  CloudKnows
//
//  Created by atman on 13-6-7.
//  Copyright (c) 2013年 atman. All rights reserved.
//

#import "UIImage+alpha.h"
#import "common.h"
@implementation UIImage (alpha)
//return true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

//return a copy of the given image and add alpha channel(if donot)

- (UIImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}
//return a copy image with a transparent border of the given size,then if the image has no alpha layer, add it.

- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self createBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

//help method (3)
// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)createBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}
- (UIImage *) imageWithBackgroundColor:(UIColor *)bgColor
                           shadeAlpha1:(CGFloat)alpha1
                           shadeAlpha2:(CGFloat)alpha2
                           shadeAlpha3:(CGFloat)alpha3
                           shadowColor:(UIColor *)shadowColor
                          shadowOffset:(CGSize)shadowOffset
                            shadowBlur:(CGFloat)shadowBlur {
    UIImage *image = self;
    CGColorRef cgColor = [bgColor CGColor];
    CGColorRef cgShadowColor = [shadowColor CGColor];
    CGFloat components[16] = {1,1,1,alpha1,1,1,1,alpha1,1,1,1,alpha2,1,1,1,alpha3};
    CGFloat locations[4] = {0,0.5,0.6,1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, (size_t)4);
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [image size];
    //contextRect.size = CGSizeMake([image size].width+5,[image size].height+5);
    // Retrieve source image and begin image context
    UIImage *itemImage = image;
    CGSize itemImageSize = [itemImage size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) / 2);
    UIGraphicsBeginImageContext(contextRect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Setup shadow
    CGContextSetShadowWithColor(c, shadowOffset, shadowBlur, cgShadowColor);
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [itemImage CGImage]);
    // Fill and end the transparency layer
    CGContextSetFillColorWithColor(c, cgColor);
    contextRect.size.height = -contextRect.size.height;
    CGContextFillRect(c, contextRect);
    CGContextDrawLinearGradient(c, colorGradient,CGPointZero,CGPointMake(contextRect.size.width*1.0/4.0,contextRect.size.height),0);
    CGContextEndTransparencyLayer(c);
    //CGPointMake(contextRect.size.width*3.0/4.0, 0)
    // Set selected image and end context
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(colorGradient);
    return resultImage;
}
+ (UIImage*)thumbnailOfImage:(UIImage*)image withSize:(CGSize)aSize

{
    if (!image)
        return nil;
    CGImageRef imageRef = [image CGImage];
    UIImage *thumb = nil;
    float _width = CGImageGetWidth(imageRef);
    
    float _height = CGImageGetHeight(imageRef);
    
    float _resizeToWidth;
    float _resizeToHeight;
    
    _resizeToWidth = aSize.width;
    _resizeToHeight = aSize.height;
    
    float _moveX = 0.0f;
    float _moveY = 0.0f;

    if ( (_width > _resizeToWidth) || (_height > _resizeToHeight) )
    {
        float _amount = 0.0f;
        if (_width > _resizeToWidth)
        {
            _amount = _resizeToWidth / _width;
            
            _width *= _amount;
            
            _height *= _amount;
            
        }
        if (_height > _resizeToHeight)
        {
            _amount = _resizeToHeight / _height;
            
            _width *= _amount;
            
            _height *= _amount;
        }
    }
    _width = (NSInteger)_width;
    _height = (NSInteger)_height;
    _resizeToWidth = _width;
    _resizeToHeight = _height;
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                _resizeToWidth,
                                                _resizeToHeight,
                                                CGImageGetBitsPerComponent(imageRef),
                                                CGImageGetBitsPerPixel(imageRef)*_resizeToWidth,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)
                                                );
    _moveX = (_resizeToWidth - _width) / 2;
    _moveY = (_resizeToHeight - _height) / 2;
    CGContextSetRGBFillColor(bitmap, 1.f, 1.f, 1.f, 1.0f);
    CGContextFillRect( bitmap, CGRectMake(0, 0, _resizeToWidth, _resizeToHeight));
    CGContextDrawImage( bitmap, CGRectMake(_moveX, _moveY, _width, _height), imageRef );
    CGImageRef ref = CGBitmapContextCreateImage( bitmap );
    thumb = [UIImage imageWithCGImage:ref];
    CGContextRelease( bitmap );
    CGImageRelease( ref );
    return thumb;
}
+(UIImage *)rotateImage:(UIImage *)aImage origention:(UIImageOrientation)orientation
{
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat scaleRatio = 1;
    
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

+ (UIImage *)createGrayCopy:(UIImage *)sourceImage
{
    CGSize wSourceSize = sourceImage.size;
    
    CGColorSpaceRef wColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef wContext = CGBitmapContextCreate(nil, wSourceSize.width, wSourceSize.height, 8, 0, wColorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(wColorSpace);
    if (wContext == nil)
    {
        CGContextRelease(wContext);
        return nil;
    }
    else
    {
        CGContextDrawImage(wContext, CGRectMake(0, 0, wSourceSize.width, wSourceSize.height), sourceImage.CGImage);
        CGImageRef wImage = CGBitmapContextCreateImage(wContext);
        UIImage * wGrayImage = [UIImage imageWithCGImage:wImage];
        CFRelease(wImage);
        CGContextRelease(wContext);
        return wGrayImage;
    }
}
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage*) drawGradientInRect:(CGSize)size withColors:(NSArray*)colors
{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) [ar addObject:(id)c.CGColor];
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    //     CGContextClipToRect(context, rect);
    
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(0.0, size.height);
    
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
    // Clean up
    CGColorSpaceRelease(colorSpace); // Necessary?
    UIGraphicsEndImageContext(); // Clean up
    return image;
}
+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)color1 endColor:(UIColor *)color2 {
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    //CGContextDrawImage(context, rect, img.CGImage);
    
    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color2.CGColor, (id)color1.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    // Apply gradient
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, img.size.height), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}
@end


#define GOLDEN_RATIO (0.618)

@implementation UIImage (BetterFace)

- (UIImage *)betterFaceImageForSize:(CGSize)size
                           accuracy:(BFAccuracy)accurary;
{
    NSArray *features = [UIImage _faceFeaturesInImage:self accuracy:accurary];
    
    if ([features count]==0) {
        NSLog(@"no faces");
        return nil;
    } else {
        NSLog(@"succeed %lu faces", (unsigned long)[features count]);
        return [self _subImageForFaceFeatures:features
                                         size:size];
    }
}

- (UIImage *)_subImageForFaceFeatures:(NSArray *)faceFeatures size:(CGSize)size
{
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *faceFeature in faceFeatures){
        CGRect oneRect = faceFeature.bounds;
        oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height;
        
        fixedRect.origin.x = MIN(oneRect.origin.x, fixedRect.origin.x);
        fixedRect.origin.y = MIN(oneRect.origin.y, fixedRect.origin.y);
        
        rightBorder = MAX(oneRect.origin.x + oneRect.size.width, rightBorder);
        bottomBorder = MAX(oneRect.origin.y + oneRect.size.height, bottomBorder);
    }
    
    fixedRect.size.width = rightBorder - fixedRect.origin.x;
    fixedRect.size.height = bottomBorder - fixedRect.origin.y;
    
    CGPoint fixedCenter = CGPointMake(fixedRect.origin.x + fixedRect.size.width / 2.0,
                                      fixedRect.origin.y + fixedRect.size.height / 2.0);
    CGPoint offset = CGPointZero;
    CGSize finalSize = size;
    if (size.width / size.height > self.size.width / self.size.height) {
        //move horizonal
        finalSize.height = self.size.height;
        finalSize.width = size.width/size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.x = fixedCenter.x - self.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.size.width > finalSize.width) {
            offset.x = finalSize.width - self.size.width;
        }
        offset.x = - offset.x;
    } else {
        //move vertical
        finalSize.width = self.size.width;
        finalSize.height = size.height/size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.y = fixedCenter.y - self.size.height * (1-GOLDEN_RATIO);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.size.height > finalSize.height){
            offset.y = finalSize.height = self.size.height;
        }
        offset.y = - offset.y;
    }
    
    CGRect finalRect = CGRectApplyAffineTransform(CGRectMake(offset.x, offset.y, finalSize.width, finalSize.height),
                                                  CGAffineTransformMakeScale(self.scale, self.scale));
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], finalRect);
    UIImage *subImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return subImage;
}

#pragma mark - Util

+ (NSArray *)_faceFeaturesInImage:(UIImage *)image accuracy:(BFAccuracy)accurary
{
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSString *accuraryStr = (accurary == kBFAccuracyLow) ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh;
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy: accuraryStr}];
    
    return [detector featuresInImage:ciImage];
}

@end


#import <Accelerate/Accelerate.h>
#import <float.h>

@implementation UIImage (ImageEffects)


- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    int componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        
        
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

-(UIImage*)halfSize
{
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * 0.5, self.size.height * 0.5));
    [self drawInRect:CGRectMake(0, 0, self.size.width * 0.5, self.size.height * 0.5)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(UIImage*)withRoam:(NSString*)finger
{
    UIImage *image = [UIImage imageNamed:@"img_avatar_outline_b"];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width+20 , image.size.height+20 ));
    [image drawInRect:CGRectMake(10, 10, image.size.width , image.size.height )];
    UIImage *content = [UIImage createRoundedRectImage:self size:CGSizeMake(self.size.width, self.size.height) radius:self.size.width/2];
    [content drawInRect:CGRectMake(16, 15, image.size.width-12, image.size.width-12)];
    if (finger) {
        if (finger.integerValue > 99) {
            finger = @"99";
        }
        UIImage *fingerImage = [UIImage imageNamed:@"img_avatar_outline_numbg_b"];
        [fingerImage drawInRect:CGRectMake(0, 0, 40, 40)];
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0xfc5d7d).CGColor);
        if (finger.length == 1) {
            [finger drawAtPoint:CGPointMake(12, 8) withFont:[UIFont systemFontOfSize:22]];
        }
        else
        {
            [finger drawAtPoint:CGPointMake(10, 8) withFont:[UIFont systemFontOfSize:18]];
        }
    }
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(UIImage*)withNoRoam:(NSString*)finger
{
    UIImage *image = [UIImage imageNamed:@"img_avatar_outline_a"];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width + 20 , image.size.height +20));
    [image drawInRect:CGRectMake(10, 10, image.size.width , image.size.height )];
    UIImage *content = [UIImage createRoundedRectImage:self size:CGSizeMake(self.size.width, self.size.height) radius:self.size.width/2];
    [content drawInRect:CGRectMake(16, 15, image.size.width-12, image.size.width-12)];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0x15b9d6).CGColor);
    if (finger) {
        if (finger.integerValue > 99) {
            finger = @"99";
        }
        UIImage *fingerImage = [UIImage imageNamed:@"img_avatar_outline_numbg_a"];
        [fingerImage drawInRect:CGRectMake(0, 0, 40, 40)];
        if (finger.length == 1) {
            [finger drawAtPoint:CGPointMake(12, 8) withFont:[UIFont systemFontOfSize:22]];
        }
        else
        {
            [finger drawAtPoint:CGPointMake(10, 8) withFont:[UIFont systemFontOfSize:18]];
        }
    }
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+(UIImage*)markWithNumber:(NSString*)finger
{
    UIImage *image = [UIImage imageNamed:@"img_icon_event_map_c"];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0, 0, image.size.width , image.size.height )];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0x15b9d6).CGColor);
    if (finger) {
        if (finger.integerValue > 99) {
            finger = @"99";
        }
        if (finger.length == 1) {
            [finger drawAtPoint:CGPointMake(90, 20) withFont:[UIFont systemFontOfSize:22]];
        }
        else
        {
            [finger drawAtPoint:CGPointMake(80, 20) withFont:[UIFont systemFontOfSize:18]];
        }
    }
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImage alloc]initWithCGImage:scaledImage.CGImage scale:2 orientation:UIImageOrientationUp];
}
+(UIImage*)markWithContent:(UIImage*)image1
{
    UIImage *image = [UIImage imageNamed:@"img_icon_event_map_a"];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0, 0, image.size.width , image.size.height )];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0x15b9d6).CGColor);
    if (image1) {
        [image1 drawInRect:CGRectMake(3.5, 3.5, 67, 57)];
    }
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImage alloc]initWithCGImage:scaledImage.CGImage scale:2 orientation:UIImageOrientationUp];
}

-(UIImage*)round
{
    return (UIImage*)[UIImage createRoundedRectImage:self size:CGSizeMake(self.size.width , self.size.height) radius:self.size.width];
}
@end



@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality {
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
    
    return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // In iOS 5 the image is already correctly rotated. See Eran Sandler's
    // addition here: http://eran.sandler.co.il/2011/11/07/uiimage-in-ios-5-orientation-and-resize/
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0 )
    {
        drawTransposed = NO;
    }
    else
    {
        switch ( self.imageOrientation )
        {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                drawTransposed = YES;
                break;
            default:
                drawTransposed = NO;
        }
        
        transform = [self transformForOrientation:newSize];
    }
    
    return [self resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark -
#pragma mark Private helper methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Fix for a colorspace / transparency issue that affects some types of
    // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap =CGBitmapContextCreate( NULL,
                                               newRect.size.width,
                                               newRect.size.height,
                                               8,
                                               0,
                                               colorSpace,
                                               kCGImageAlphaPremultipliedLast );
    CGColorSpaceRelease(colorSpace);
	
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

@end


@implementation UIImage (Rounded)

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return img;
}
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r withBoarderImage:(UIImage*)boarder
{
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), boarder.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return img;
    
}
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r withBoarderImage:(UIImage*)boarder andFingerImage:(UIImage*)finger
{
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), boarder.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, w, h)];
    [finger drawInRect:CGRectMake(w-finger.size.width/2, 0, finger.size.width/2, finger.size.height/2)];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return screenshot;
    
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
    
}
/*
 图片适配缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image toBounds:(CGRect)rect
{
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width  , rect.size.height));
    CGRect imageRect;
    if (image.size.width/rect.size.width > image.size.height/rect.size.height) {
        imageRect = CGRectMake(0, (rect.size.height-image.size.height/(image.size.width/rect.size.width))/2, rect.size.width, image.size.height/(image.size.width/rect.size.width));
    }
    else
    {
        imageRect = CGRectMake((rect.size.width-image.size.width/image.size.height/rect.size.height)/2, 0, image.size.width/(image.size.height/rect.size.height), rect.size.height);
    }
    [image drawInRect:imageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end

@implementation UIImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width,
                                                 image.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize
                    ovalHeight:cornerSize];
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

#pragma mark -
#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end

#import <Accelerate/Accelerate.h>

@implementation UIImage (Utility)

+ (UIImage*)decode:(UIImage*)image
{
    if(image==nil){  return nil; }
    
    UIGraphicsBeginImageContext(image.size);
    {
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)fastImageWithData:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    return [self decode:image];
}

+ (UIImage*)fastImageWithContentsOfFile:(NSString*)path
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    return [self decode:image];
}

#pragma mark- Copy

- (UIImage*)deepCopy
{
    return [UIImage decode:self];
}

#pragma mark- Resizing

- (UIImage*)resize:(CGSize)size
{
    int W = size.width;
    int H = size.height;
    
    CGImageRef   imageRef   = self.CGImage;
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight){
        W = size.height;
        H = size.width;
    }
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored){
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -H);
    }
    else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored){
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -W, 0);
    }
    else if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored){
        // Nothing
    }
    else if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored){
        CGContextTranslateCTM (bitmap, W, H);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, W, H), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return newImage;
}

- (UIImage*)aspectFit:(CGSize)size
{
    CGFloat ratio = MIN(size.width/self.size.width, size.height/self.size.height);
    return [self resize:CGSizeMake(self.size.width*ratio, self.size.height*ratio)];
}

- (UIImage*)aspectFill:(CGSize)size
{
    return [self aspectFill:size offset:0];
}

- (UIImage*)aspectFill:(CGSize)size offset:(CGFloat)offset
{
    int W  = size.width;
    int H  = size.height;
    int W0 = self.size.width;
    int H0 = self.size.height;
    
    CGImageRef   imageRef = self.CGImage;
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight){
        W  = size.height;
        H  = size.width;
        W0 = self.size.height;
        H0 = self.size.width;
    }
    
    double ratio = MAX(W/(double)W0, H/(double)H0);
    W0 = ratio * W0;
    H0 = ratio * H0;
    
    int dW = abs((W0-W)/2);
    int dH = abs((H0-H)/2);
    
    if(dW==0){ dH += offset; }
    if(dH==0){ dW += offset; }
    
    if(self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored){
        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -H);
    }
    else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored){
        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -W, 0);
    }
    else if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored){
        // Nothing
    }
    else if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored){
        CGContextTranslateCTM (bitmap, W, H);
        CGContextRotateCTM (bitmap, -M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(-dW, -dH, W0, H0), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

#pragma mark- Clipping

- (UIImage*)crop:(CGRect)rect
{
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [self drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark- Masking

- (UIImage*)maskedImage:(UIImage*)maskImage
{
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskImage.CGImage),
                                        CGImageGetHeight(maskImage.CGImage),
                                        CGImageGetBitsPerComponent(maskImage.CGImage),
                                        CGImageGetBitsPerPixel(maskImage.CGImage),
                                        CGImageGetBytesPerRow(maskImage.CGImage),
                                        CGImageGetDataProvider(maskImage.CGImage), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
    
    UIImage *result = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return result;
}

#pragma mark- Blur

- (UIImage*)gaussBlur:(CGFloat)blurLevel
{
    blurLevel = MIN(1.0, MAX(0.0, blurLevel));
    
    int boxSize = (int)(blurLevel * 0.1 * MIN(self.size.width, self.size.height));
    boxSize = boxSize - (boxSize % 2) + 1;
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    UIImage *tmpImage = [UIImage imageWithData:imageData];
    
    CGImageRef img = tmpImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    NSInteger windowR = boxSize/2;
    CGFloat sig2 = windowR / 3.0;
    if(windowR>0){ sig2 = -1/(2*sig2*sig2); }
    
    int16_t *kernel = (int16_t*)malloc(boxSize*sizeof(int16_t));
    int32_t  sum = 0;
    for(NSInteger i=0; i<boxSize; ++i){
        kernel[i] = 255*exp(sig2*(i-windowR)*(i-windowR));
        sum += kernel[i];
    }
    
    // convolution
    error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, kernel, boxSize, 1, sum, NULL, kvImageEdgeExtend);
    error = vImageConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, kernel, 1, boxSize, sum, NULL, kvImageEdgeExtend);
    outBuffer = inBuffer;
    
    if (error) {
        NSLog(@"error from convolution %tu", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end