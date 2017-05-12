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

#import "HeroUploadItem.h"

@implementation HeroUploadItem


- (void)upload:(HeroImageUploader *)uploader didSendFirstRespone:(NSURLResponse *)response {
    if ([self.delegate respondsToSelector:@selector(upload:didSendFirstRespone:)]) {
        [self.delegate upload:self didSendFirstRespone:response];
    }
}

- (void)upload:(HeroImageUploader *)uploader didSendData:(uint64_t)sendLength onTotal:(uint64_t)totalLength progress:(float)progress {
    if ([self.delegate respondsToSelector:@selector(upload:didSendData:onTotal:progress:)]) {
        [self.delegate upload:self didSendData:sendLength onTotal:totalLength progress:progress];
    }
}

- (void)upload:(HeroImageUploader *)uploader didStopWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(upload:didStopWithError:)]) {
        [self.delegate upload:self didStopWithError:error];
    }
    if ([self.itemDelegate respondsToSelector:@selector(didUploadItem:error:)]) {
        [self.itemDelegate didUploadItem:self error:error];
    }
}

- (void)upload:(HeroImageUploader *)uploader didFinishWithSuccessData:(id)data {
    self.imgUrl = data[@"imageUrl"]?:@"";
    self.thumbImgUrl = data[@"thumbImgUrl"]?:@"";
    self.createdDate = data[@"createdDate"]?:@"";
    self.docId = data[@"docId"]?:@"";
    self.fileId = data[@"fileId"]?:@"";
    self.filename = data[@"filename"]?:@"";
    if ([self.itemDelegate respondsToSelector:@selector(didUpdateItemUploadItem:)]) {
        [self.itemDelegate didUpdateItemUploadItem:self];
    }
    if ([self.delegate respondsToSelector:@selector(upload:didFinishWithSuccessData:)]) {
        [self.delegate upload:self didFinishWithSuccessData:data];
    }
}

@end
