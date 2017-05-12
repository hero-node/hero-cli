/**
 * UILazyImageView
 *
 * Copyright 2012 Daniel Lupiañez Casares <lupidan@gmail.com>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 **/

#import <UIKit/UIKit.h>
typedef void (^LazyBasicBlock)(NSData * data);

@interface AnimatedGifFrame : NSObject
{
	NSData *data;
	NSData *header;
	double delay;
	int disposalMethod;
	CGRect area;
}

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic) double delay;
@property (nonatomic) int disposalMethod;
@property (nonatomic) CGRect area;

@end
@class UILazyImageView;
@protocol UILazyImageViewDelegate <NSObject>

@optional
- (void)downloadDataFail;
- (void)didFinishLoadingImage;
- (void)downloadDataFail:(UILazyImageView*)imageView;
- (void)didFinishLoadingImage:(UILazyImageView*)imageView;

@end

/**
	This class works as a normal UIImageView, but offers also the possibility to load images from the internet asynchronously.
 */
@interface UILazyImageView : UIImageView <NSURLConnectionDataDelegate, UILazyImageViewDelegate>
{
    NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableArray *GIF_frames;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;

}
@property (nonatomic, strong) NSMutableArray *GIF_frames;
@property (nonatomic, assign) BOOL isGifImage;
- (id)initWithGIFFile:(NSString*)gifFilePath;
- (id)initWithGIFData:(NSData*)gifImageData;
- (id)initWithGIFName:(NSString *)gifName;

- (void)loadImageData;
- (void)gifImageStartAnimating;
- (void)gifImageStartAnimating:(int)count;
- (void)gifImageStopAnimating;

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData;
+ (BOOL)isGifImage:(NSData*)imageData;

- (void) decodeGIF:(NSData *)GIFData;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(long)length;
- (bool) GIFSkipBytes: (NSInteger) length;
- (NSData*) getFrameAsDataAtIndex:(NSInteger)index;
- (UIImage*) getFrameAsImageAtIndex:(NSInteger)index;

/**
	Set this image URL member to start downloading the image from the web
 */
@property (nonatomic,retain) NSURL * imageURL;

@property (nonatomic,retain) NSString * imageURL_AfterLoad;

@property (nonatomic) BOOL isProgressBarNecessary;

@property (weak, nonatomic) id<UILazyImageViewDelegate> delegate;
+ (void) registerForURL:(NSURL*)url block:(LazyBasicBlock)block;
+ (void) registerForName:(NSString*)url block:(LazyBasicBlock)block;

/**
	Clears the temp cache for all the images
 */
+ (void) clearCache;
/**
	Clears the cache entry for an URL
	@param url The url to clear the caché
 */
+ (void) clearsCacheEntryForURL:(NSURL*)url;
+ (NSData*) getCachedImageDataForURL:(NSURL*)url;
+ (void) updateCacheForURL:(NSURL*)url withDownloadedData:(NSData*)data;

+ (NSString*) getFilenameForCacheEntryWithURL:(NSURL*)url;

/**
 This method returns the path of the cache folder
 @returns The path of the cache folder
 */
+ (NSString*) getCacheFolder;

@end
