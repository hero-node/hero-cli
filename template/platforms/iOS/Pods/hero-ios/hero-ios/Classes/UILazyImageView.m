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

#import "UILazyImageView.h"
#import "NSData+HashMD5.h"
#import "NSDate+ToString.h"
#import "UIImage+alpha.h"
#import "common.h"
/**
	The name of the folder in the temp folder to store the image cache
 */
#define UILazyImageViewCacheFolder @"UILazyImageViewCache"

@implementation AnimatedGifFrame
{
}
@synthesize data, delay, disposalMethod, area, header;


@end

@interface UILazyImageView ()


/**
	Checks if the image cache folder exists
	@returns YES if it exists, NO otherwise
 */
+ (BOOL) imageCacheFolderExists;
/**
	Method to delete the cache folder if it exists
 */
+ (void) deleteImageCacheFolder;
/**
	Method to create the cache folder, if it does not exist
 */
+ (void) createImageCacheFolder;
/**
	Method to get the unique filename to store an image with an URL
	@param url The url containing the file
	@returns The string with the file path where the image data will be cached
 */
+ (NSString*) getFilenameForCacheEntryWithURL:(NSURL*)url;
/**
	Get the cached image data for an url
	@param url The image url
	@returns the cached data or nil if no data is found 
 */
+ (NSData*) getCachedImageDataForURL:(NSURL*)url;
/**
	Updates the cache by adding a file for a certain url with the downloaded data
	@param url The url of the image
	@param data The data to store
 */
+ (void) updateCacheForURL:(NSURL*)url withDownloadedData:(NSData*)data;




/**
	The progress view to show up when the image is being downloaded
 */
@property (nonatomic,strong) UIProgressView * progressView;
/**
	The main request to ask for the image data
 */
@property (nonatomic,strong) NSURLRequest * imageRequest;
/**
	The connection in charge of downloading the image data
 */
@property (nonatomic,strong) NSURLConnection * imageRequestConnection;
/**
	The cumulative data structure, at the end of the request, it will contain the full image data
 */
@property (nonatomic,strong) NSMutableData * downloadedImage;
/**
	The number of downloaded bytes
 */
@property (nonatomic,assign) NSUInteger downloadedByteCount;
/**
	The expected number of bytes to download for the request
 */
@property (nonatomic,assign) NSUInteger expectedByteCount;





/**
	Common init for all the init methods
 */
- (void) lazyImageViewInit;
/**
	This method cancels any previous connection, and starts a new download if the imageURL is not nil
    @param imageURL the URL containing the image
 */
- (void) startDownloading:(NSURL*)imageURL;
/**
	This method is executed in the main thread when the connection fails the download
 */
- (void) downloadDidFail;
/**
	This method is executed in the main thread when the connection sucess the download
    @param downloadedImage The downloaded image
 */
- (void) downloadDidSuccess:(NSData*)downloadedImage;
/**
	This method is executed in the main thread, it updates the progress bar value
 */
- (void) updateProgressBar;
/**
	Starts loading the data in the background thread by attempting to get the data from cache. If not cached, download starts in main thread
    @param imageURL the URL containing the image
 */
- (void) loadDataInBackground:(NSURL*)imageURL;


@end







@implementation UILazyImageView
{
    BOOL hasLoad;
}
@synthesize GIF_frames;
@synthesize imageURL = _imageURL;
@synthesize progressView = _progressView;
@synthesize imageRequest = _imageRequest;
@synthesize imageRequestConnection = _imageRequestConnection;
@synthesize downloadedImage = _downloadedImage;
@synthesize downloadedByteCount = _downloadedByteCount;
@synthesize expectedByteCount = _expectedByteCount;


#pragma mark - Static class members and methods

/**
 * The string containing the folder where we will store the images
 */
static NSString * cacheFolder;

+ (NSString*) getCacheFolder{
    if (!cacheFolder)
        cacheFolder = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), UILazyImageViewCacheFolder];
    return cacheFolder;
}



+ (BOOL) imageCacheFolderExists{
    //Delete the main folder if it exists
    NSFileManager * fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:[self getCacheFolder]];
}



+ (void) deleteImageCacheFolder{
    
    //Delete the main folder if it exists
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if ([self imageCacheFolderExists]){
        if (![fm removeItemAtPath:[self getCacheFolder] error:&error]){
        }
    }
    
    
}


+ (void) createImageCacheFolder{
    //Create the folder
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![self imageCacheFolderExists]){
        if (![fm createDirectoryAtPath:[self getCacheFolder] withIntermediateDirectories:YES attributes:nil error:&error]){
        }
    }
    
}


+ (NSString*) getFilenameForCacheEntryWithURL:(NSURL*)url{
    NSString * urlMD5 = [[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding] hashMD5String];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",[self getCacheFolder],urlMD5];
    return filePath;
}

+ (NSString *)getCacheFileNameFromImageURL:(NSURL *)url {
    NSArray *arr = [[url absoluteString] componentsSeparatedByString:@"/"];
    if ([arr count] > 0) {
        NSString *lastString = [arr lastObject];
        NSString *targetSTR = [[lastString componentsSeparatedByString:@"."] firstObject];
        return targetSTR;
    }
    return @"";
}


+ (NSData*) getCachedImageDataForURL:(NSURL*)url{
    
    //If file exists with this hash as filename, return the data asociated
    NSFileManager * fm = [NSFileManager defaultManager];
    return [fm contentsAtPath:[self getFilenameForCacheEntryWithURL:url]];
    
}
+ (void) registerForName:(NSString*)url block:(LazyBasicBlock)block
{
    [UILazyImageView registerForURL:[NSURL URLWithString:url] block:block];
}
+ (void) registerForURL:(NSURL*)url block:(LazyBasicBlock)block;
{
    if (!url) {
        block(NULL);
        return;
    }
    NSData *data = [self getCachedImageDataForURL:url];
    if (!data) {
        if (!imageDownloadQuene) {
            imageDownloadQuene = [[NSOperationQueue alloc]init];
            [imageDownloadQuene setMaxConcurrentOperationCount:4];
        }
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"]) {
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"];
            for (NSString *key in [dic allKeys]) {
                [req setValue:dic[key] forHTTPHeaderField:key];
            }
        }
        NSURLSession *session = [NSURLSession sharedSession];
        req.timeoutInterval = 30.0;
        
        [[session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable d, NSURLResponse * _Nullable response, NSError * _Nullable e) {
            if (d &&(!e)) {
                if (d.length > 100)
                {
                    [UILazyImageView updateCacheForURL:url withDownloadedData:d];
                    if ([NSThread isMainThread]) {
                        block(d);
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(d);
                        });
                    }
                }
                else
                {
                    if ([NSThread isMainThread]) {
                        block(NULL);
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(NULL);
                        });
                    }
                }
            }
            else
            {
                if ([NSThread isMainThread]) {
                    block(NULL);
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(NULL);
                    });
                }
            }
        }] resume];
        
    }
    else
    {
        if ([NSThread isMainThread]) {
            block(data);
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block(data);
            });
        }
    }
}



+ (void) updateCacheForURL:(NSURL*)url withDownloadedData:(NSData*)data{
    
    //First create if needed the image cache folder
    [self createImageCacheFolder];
    
    //Save data in file
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm createFileAtPath:[self getFilenameForCacheEntryWithURL:url] contents:data attributes:nil]){
        NSLog(@"UILazyImageViewCache: ERROR when creating file at %@", [self getFilenameForCacheEntryWithURL:url]);
    }
    
}

+ (void) clearCache{
    //Delete folder and create it again
    [self deleteImageCacheFolder];
    [self createImageCacheFolder];
}

+ (void) clearsCacheEntryForURL:(NSURL*)url{
    
    //Just delete the file
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![fm removeItemAtPath:[self getFilenameForCacheEntryWithURL:url] error:&error]){
        NSLog(@"UILazyImageViewCache: ERROR when deleting cache entry for %@ %@", [self getFilenameForCacheEntryWithURL:url], error.description);
    }

}


#pragma mark - Init and Dealloc methods

- (id) init{
    self = [super init];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}


- (void) lazyImageViewInit{
    
    //Progress view
    UIProgressView * tempProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [tempProgressView setHidden:YES];
    self.progressView = tempProgressView;

    [self addSubview:self.progressView];
    [self setUserInteractionEnabled:YES];
    [self setIsProgressBarNecessary:NO];
}


#pragma mark - Overrides

- (void) setImageURL:(NSURL *)imageURL{
    if (_imageURL == imageURL) {
        return;
    }
    if ([_imageURL.absoluteString isEqualToString:imageURL.absoluteString]) {
        _imageURL = imageURL;
        return;
    }
    if (!imageURL) {
        self.image = nil;
        _imageURL = nil;
        return;
    }
    _imageURL = imageURL;
    
    if (self.imageURL){
        
        //Reset progress bar
        self.downloadedByteCount = 0;
        self.expectedByteCount = 0;
        
        //Update progress bar
        [self updateProgressBar];
        if (self.isProgressBarNecessary) {
            [self.progressView setHidden:NO];
        }
        
        //Cancel previous request if needed
        [self.imageRequestConnection cancel];
        
        //Load data in background
        [self performSelectorInBackground:@selector(loadDataInBackground:) withObject:self.imageURL];
        
        
    }
    
}




- (void) layoutSubviews{
    [super layoutSubviews];
    
    //Set frame of progress view
    CGFloat rightMargin = 20.0;
    CGFloat leftMargin = 20.0;
    CGFloat width = self.frame.size.width - leftMargin - rightMargin;
    CGFloat height = 5.0;
    CGFloat yPos = self.center.y - (height / 2.0);
    if (width < 0)
        width = 0;
    self.progressView.frame = CGRectMake(leftMargin, yPos, width, height);
    
    
}











#pragma mark - Private methods
- (void) updateProgressBar{
    if (!self.isProgressBarNecessary) {
        [self.progressView setHidden:YES];
        return;
    }
    if (self.expectedByteCount > 0)
        [self.progressView setProgress: ((CGFloat)self.downloadedByteCount/(CGFloat)self.expectedByteCount)];
    else
        [self.progressView setProgress:0.0f];
}



- (void) loadDataInBackground:(NSURL*)imageURL{
    NSData * cachedData = [UILazyImageView getCachedImageDataForURL:imageURL];
    if (!cachedData || cachedData.length < 200){
        self.alpha = 0.0f;
        [self performSelectorOnMainThread:@selector(startDownloading:) withObject:imageURL waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(downloadDidSuccess:) withObject:cachedData waitUntilDone:YES];
    
    }
}


static NSOperationQueue *imageDownloadQuene;
- (void) startDownloading:(NSURL*)imageURL{
    if (self.isProgressBarNecessary) {
        //Start new request
        if (self.imageRequestConnection) {
            [self.imageRequestConnection cancel];
        }
        self.imageRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0];
        self.imageRequestConnection = [NSURLConnection connectionWithRequest:self.imageRequest delegate:self];
    }
    else
    {
        if (!imageDownloadQuene) {
            imageDownloadQuene = [[NSOperationQueue alloc]init];
            [imageDownloadQuene setMaxConcurrentOperationCount:4];
        }
        __block UILazyImageView *blockSelf = self;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL] queue:imageDownloadQuene completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
            if (d &&(!e)) {
                if (d.length > 400)
                {
                    [UILazyImageView updateCacheForURL:imageURL withDownloadedData:d];
                    if (blockSelf.imageURL == imageURL) {
                        [self performSelectorOnMainThread:@selector(downloadDidSuccess:) withObject:d waitUntilDone:YES];
                    }
                }
                else
                    [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
            }
        }];
    }
}

- (void) downloadDidSuccess:(NSData*)downloadedImage{

    if (!_imageURL) {
        return;
    }
    //Update progres bar
    [self updateProgressBar];
    //Set image
    [self initWithGIFData:downloadedImage];
    //Clear memory
    self.imageRequest = nil;
    self.imageRequestConnection = nil;
    self.downloadedImage = nil;
    //Hide progress bar
    [self.progressView setHidden:YES];
    if (self.isGifImage) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingImage)]) {
        [self.delegate performSelector:@selector(didFinishLoadingImage)];
    }
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingImage:)]) {
        [self.delegate performSelector:@selector(didFinishLoadingImage:) withObject:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    }];

}
-(void)tap:(UITapGestureRecognizer*)recognizer
{
    [self gifImageStartAnimating:1];
}

- (void) downloadDidFail{
    //Clear image
    [self setImage:nil];
    //Hide progress bar
    [self.progressView setHidden:YES];
    if ([self.delegate respondsToSelector:@selector(downloadDataFail)]) {
        [self.delegate performSelector:@selector(downloadDataFail)];
    }
    if ([self.delegate respondsToSelector:@selector(downloadDataFail:)]) {
        [self.delegate performSelector:@selector(downloadDataFail:) withObject:self];
    }
}



 










#pragma mark - Url Connection Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (self.imageRequestConnection == connection){
        NSMutableData * newData = [[NSMutableData alloc] init];
        self.downloadedImage = newData;
        self.expectedByteCount = [response expectedContentLength];
        self.downloadedByteCount = 0;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (self.imageRequestConnection == connection){
        [self.downloadedImage appendData:data];
        self.downloadedByteCount += data.length;
        [self performSelectorOnMainThread:@selector(updateProgressBar) withObject:nil waitUntilDone:YES];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.imageRequestConnection == connection){
        if (self.downloadedImage.length > 400) {
            [UILazyImageView updateCacheForURL:self.imageURL withDownloadedData:self.downloadedImage];
        }
        if (self.downloadedImage)
            [self performSelectorOnMainThread:@selector(downloadDidSuccess:) withObject:self.downloadedImage waitUntilDone:YES];
        else
            [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (self.imageRequestConnection == connection){
        [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
    }
}

+ (BOOL)isGifImage:(NSData*)imageData {
	const char* buf = (const char*)[imageData bytes];
	if (buf[0] == 0x47 && buf[1] == 0x49 && buf[2] == 0x46 && buf[3] == 0x38) {
		return YES;
	}
	return NO;
}

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData {
	UILazyImageView* gifImageView = [[UILazyImageView alloc] initWithGIFData:gifImageData];
	if (!gifImageView) {
		return nil;
	}
	NSMutableArray* gifFrames = gifImageView.GIF_frames;
	return gifFrames;
}

- (id)initWithGIFFile:(NSString*)gifFilePath {
	NSData* imageData = [NSData dataWithContentsOfFile:gifFilePath];
	return [self initWithGIFData:imageData];
}

- (id)initWithGIFName:(NSString *)gifName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
    NSData* imageData = [NSData dataWithContentsOfFile:filePath];
    return [self initWithGIFData:imageData];
}

- (id)initWithGIFData:(NSData*)gifImageData {
	if (gifImageData.length < 4) {
		return nil;
	}
	
	if (![UILazyImageView isGifImage:gifImageData]) {
		UIImage* image = [UIImage imageWithData:gifImageData];
        if (self.userInteractionEnabled) {
            UIView * view =[super initWithImage:image];
            view.userInteractionEnabled = YES;
            return (id)view;
        }
        else
        {
            return [super initWithImage:image];
        }
	}
	
	[self decodeGIF:gifImageData];
	
	if (GIF_frames.count <= 0) {
		UIImage* image = [UIImage imageWithData:gifImageData];
		return [super initWithImage:image];
	}
	self.isGifImage = YES;
	self = [super init];
	if (self) {
        UIImage *firstImage = [self getFrameAsImageAtIndex:0];
		return [super initWithImage:firstImage];
	}
	
	return self;
}

- (void)setGIF_frames:(NSMutableArray *)gifFrames {
	
	GIF_frames = gifFrames;
	[self loadImageData];
}

- (void)loadImageData {
	// Add all subframes to the animation
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < [GIF_frames count]; i++)
	{
		[array addObject: [self getFrameAsImageAtIndex:i]];
	}
	
	NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
	UIImage *firstImage = [array objectAtIndex:0];
	CGSize size = firstImage.size;
	CGRect rect = CGRectZero;
	rect.size = size;
	
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	int i = 0;
	AnimatedGifFrame *lastFrame = nil;
	for (UIImage *image in array)
	{
		// Get Frame
		AnimatedGifFrame *frame = [GIF_frames objectAtIndex:i];
		
		// Initialize Flag
		UIImage *previousCanvas = nil;
		
		// Save Context
		CGContextSaveGState(ctx);
		// Change CTM
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextTranslateCTM(ctx, 0.0, -size.height);
		
		// Check if lastFrame exists
		CGRect clipRect;
		
		// Disposal Method (Operations before draw frame)
		switch (frame.disposalMethod)
		{
			case 1: // Do not dispose (draw over context)
                // Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
			case 2: // Restore to background the rect when the actual frame will go to be drawed
                // Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
			case 3: // Restore to Previous
                // Get Canvas
				previousCanvas = UIGraphicsGetImageFromCurrentImageContext();
				
				// Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
		}
		
		// Draw Actual Frame
		CGContextDrawImage(ctx, rect, image.CGImage);
		// Restore State
		CGContextRestoreGState(ctx);
		
		//delay must larger than 0, the minimum delay in firefox is 10.
		if (frame.delay <= 0) {
			frame.delay = 10;
		}
		[overlayArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
		
		// Set Last Frame
		lastFrame = frame;
		
		// Disposal Method (Operations afte draw frame)
		switch (frame.disposalMethod)
		{
			case 2: // Restore to background color the zone of the actual frame
                // Save Context
				CGContextSaveGState(ctx);
				// Change CTM
				CGContextScaleCTM(ctx, 1.0, -1.0);
				CGContextTranslateCTM(ctx, 0.0, -size.height);
				// Clear Context
				CGContextClearRect(ctx, clipRect);
				// Restore Context
				CGContextRestoreGState(ctx);
				break;
			case 3: // Restore to Previous Canvas
                // Save Context
				CGContextSaveGState(ctx);
				// Change CTM
				CGContextScaleCTM(ctx, 1.0, -1.0);
				CGContextTranslateCTM(ctx, 0.0, -size.height);
				// Clear Context
				CGContextClearRect(ctx, lastFrame.area);
				// Draw previous frame
				CGContextDrawImage(ctx, rect, previousCanvas.CGImage);
				// Restore State
				CGContextRestoreGState(ctx);
				break;
		}
		
		// Increment counter
		i++;
	}
	UIGraphicsEndImageContext();
	
	[self setImage:[overlayArray objectAtIndex:0]];
	[self setAnimationImages:overlayArray];
	double total = 0;
	for (AnimatedGifFrame *frame in GIF_frames) {
		total += frame.delay;
	}
	[self setAnimationDuration:total/100];
	
	// Repeat infinite
	[self setAnimationRepeatCount:0];
	
    //	[self startAnimating];
}

- (void)gifImageStartAnimating
{
    if (!hasLoad) {
        [self loadImageData];
        hasLoad = YES;
    }
    [self startAnimating];
}
- (void)gifImageStartAnimating:(int)count
{
    if (!hasLoad) {
        [self loadImageData];
        hasLoad = YES;
    }
    self.animationRepeatCount = count;
    [self startAnimating];
}

- (void)gifImageStopAnimating
{
    [self stopAnimating];
}


- (void) decodeGIF:(NSData *)GIFData {
	GIF_pointer = GIFData;
    GIF_buffer = [[NSMutableData alloc] init];
	GIF_global = [[NSMutableData alloc] init];
	GIF_screen = [[NSMutableData alloc] init];
	GIF_frames = [[NSMutableArray alloc] init];
	dataPointer = 0;
	
	[self GIFSkipBytes: 6]; // GIF89a, throw away
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
	
	[GIF_screen setData: GIF_buffer];

    NSInteger length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes: (3 * GIF_colorS)];
        
        // Deep copy
		[GIF_global setData:GIF_buffer];
	}
	
	unsigned char bBuffer[1];
	while ([self GIFGetBytes:1] == YES)
    {
        [GIF_buffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B)
        { // This is the end
            break;
        }
        
        switch (bBuffer[0])
        {
            case 0x21:
                // Graphic Control Extension (#n of n)
                [self GIFReadExtensions];
                break;
            case 0x2C:
                // Image Descriptor (#n of n)
                [self GIFReadDescriptor];
                break;
        }
	}
	
	// clean up stuff
    GIF_buffer = nil;
    
    GIF_screen = nil;
    GIF_global = nil;
}

- (void) GIFReadExtensions {
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
            
			AnimatedGifFrame *frame = [[AnimatedGifFrame alloc] init];
			
			unsigned char buffer[5];
			[GIF_buffer getBytes:buffer length:5];
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
			//NSLog(@"flags=%x, dm=%x", (int)(buffer[0]), frame.disposalMethod);
			
			// We save the delays for easy access.
			frame.delay = (buffer[1] | buffer[2] << 8);
			
			unsigned char board[8];
			board[0] = 0x21;
			board[1] = 0xF9;
			board[2] = 0x04;
			
			for(int i = 3, a = 0; a < 5; i++, a++)
			{
				board[i] = buffer[a];
			}
			
			frame.header = [NSData dataWithBytes:board length:8];
            
			[GIF_frames addObject:frame];
			break;
		}
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
	}
}

- (void) GIFReadDescriptor {
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
	AnimatedGifFrame *frame = [GIF_frames lastObject];
	frame.area = rect;
	
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code = GIF_colorC, GIF_sort = GIF_sorted;
	
	if (GIF_colorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
        	GIF_sort = 0;
        }
	}
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort)
    {
		bBuffer[4] |= 0x08;
	}
	
    NSMutableData *GIF_string = [NSMutableData dataWithData:[[NSString stringWithFormat:@"%@",@"GIF89a"] dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
    
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
		[GIF_string appendData:GIF_buffer];
	}
    else
    {
		[GIF_string appendData:GIF_global];
	}
	
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:frame.header];
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIF_buffer];
        }
        else
        {
            break;
        }
        
	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	frame.data = GIF_string;
}

- (bool) GIFGetBytes:(long)length {
    if (GIF_buffer != nil)
    {
        GIF_buffer = nil;
    }
    
	if ((NSInteger)[GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIF_buffer = [[NSMutableData alloc] initWithData:[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)]] ;
        dataPointer += length;
		return YES;
	}
    else
    {
        return NO;
	}
}

- (bool) GIFSkipBytes: (NSInteger) length {
    if ((NSInteger)[GIF_pointer length] >= dataPointer + length)
    {
        dataPointer += length;
        return YES;
    }
    else
    {
    	return NO;
    }
}

- (NSData*) getFrameAsDataAtIndex:(NSInteger)index {
	if (index < (NSInteger)[GIF_frames count])
	{
		return ((AnimatedGifFrame *)[GIF_frames objectAtIndex:index]).data;
	}
	else
	{
		return nil;
	}
}

- (UIImage*) getFrameAsImageAtIndex:(NSInteger)index {
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
    {
		image = [UIImage imageWithData:frameData];
    }
    
    return image;
}


@end
