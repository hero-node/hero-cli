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

//  Created by 朱成尧 on 5/5/16.
//

#import "HeroImageUploadManager.h"
#import "HeroImageUploader.h"

@interface HeroImageUploadManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation HeroImageUploadManager

- (instancetype)init {
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
        [sharedManager setOperationQueueName:@"HeroUploadManager_SharedInstance_Queue"];
    });
    return sharedManager;
}

- (void)setOperationQueueName:(NSString *)name {
    [self.operationQueue setName:name];
}

- (void)startUpload:(HeroImageUploader *)upload {
    [self.operationQueue addOperation:upload];
}

- (void)cancelAllUploads {
    for (HeroImageUploader *item in [self.operationQueue operations]) {
        [item cancel];
    }
}

- (void)setMaxConcurrentUploads:(NSInteger)max {
    [self.operationQueue setMaxConcurrentOperationCount:max];
}

- (NSUInteger)uploadCount {
    return [self.operationQueue operationCount];
}

- (NSUInteger)currentUploadCount {
    NSUInteger count = 0;
    for (HeroImageUploader *item in [self.operationQueue operations]) {
        if (item.state == HeroUploadStateUploading) {
            count++;
        }
    }
    return count;
}

@end
