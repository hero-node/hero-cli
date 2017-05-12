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

#import <Foundation/Foundation.h>
#import "HeroImageUploader.h"
@class HeroImageUploader;
@class HeroUploadItem;
@protocol HeroUploadItemDelegate <NSObject>
@optional

- (void)didUpdateItemUploadItem:(HeroUploadItem *)uploadItem;
- (void)didUploadItem:(HeroUploadItem *)uploadItem error:(NSError *)error;

@end

@interface HeroUploadItem : NSObject

@property (nonatomic) HeroImageUploader *uploader;
@property (nonatomic) NSURL *localImgURL;
@property (nonatomic) NSString *imgUrl;
@property (nonatomic) NSString *thumbImgUrl;
@property (nonatomic) NSString *docId;
@property (nonatomic) NSString *fileId;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *createdDate;

@property (nonatomic, weak) id<HeroImageUploaderDelegate> delegate;
@property (nonatomic, weak) id<HeroUploadItemDelegate> itemDelegate;

@end
