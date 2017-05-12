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

#import "HeroImageUploader.h"

@interface HeroImageUploader ()

@property (nonatomic) NSURL *uploadUrl;
@property (nonatomic) NSURL *uploadName;
@property (nonatomic) NSData *uploadData;

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableURLRequest *uploadRequest;
@property (nonatomic) NSMutableData *responseData;

@end

@implementation HeroImageUploader

- (instancetype)initWithURL:(NSURL *)URL data:(NSData *)data fileName:(NSString *)fileName delegate:(id)delegate {
    if (self = [super init]) {
        _uploadUrl = URL;
        _uploadName = fileName;
        _uploadData = data;
        _delegate = delegate;
        _state = HeroUploadStateReady;
        _uploadRequest = [NSMutableURLRequest new];
        _uploadRequest.timeoutInterval = 20.0;
        [_uploadRequest setURL:_uploadUrl];
        [_uploadRequest setHTTPMethod:@"POST"];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"]) {
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"httpHeader"];
            for (NSString *key in [dic allKeys]) {
                [_uploadRequest setValue:dic[key] forHTTPHeaderField:key];
            }
        }
        NSString *fileNameWithExt = [NSString stringWithFormat:@"%@_%@.jpg", _uploadName, [NSNumber numberWithUnsignedInteger:[self hash]]];

        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [_uploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", _uploadName, fileNameWithExt] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:_uploadData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [_uploadRequest setHTTPBody:body];
        [_uploadRequest addValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[body length]]] forHTTPHeaderField:@"Content-Length"];
    }
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        return;
    }
    if (![NSURLConnection canHandleRequest:self.uploadRequest]) {
        NSError *error = [NSError errorWithDomain:@"com.dianrong.uploader" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid URL provided: %@", self.uploadRequest.URL]}];
        [self notifyFromCompletionWithError:error];
        return;
    }
    self.connection = [[NSURLConnection alloc] initWithRequest:self.uploadRequest delegate:self startImmediately:NO];
    if (self.connection && ![self isCancelled]) {
        [self willChangeValueForKey:@"isExecuting"];
        self.state = HeroUploadStateUploading;
        [self didChangeValueForKey:@"isExecuting"];

        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        [self.connection scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        [self.connection start];
        [runLoop run];
    }
}

- (BOOL)isExecuting {
    return self.state == HeroUploadStateUploading;
}

- (BOOL)isCancelled {
    return self.state == HeroUploadStateCanceled;
}

- (BOOL)isFinished {
    return self.state == HeroUploadStateCanceled || self.state == HeroUploadStateUploaded || self.state == HeroUploadStateFailed;
}

- (void)notifyFromCompletionWithError:(NSError *)error {
    BOOL success = error == nil;
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(upload:didStopWithError:)]) {
                [self.delegate upload:self didStopWithError:error];
            }
        });
    }

    HeroUploadState finalState = success ? HeroUploadStateUploaded : HeroUploadStateFailed;
    [self finishOperationWithState:finalState];
}

- (void)finishOperationWithState:(HeroUploadState)state {

    [self.connection cancel];
    if ([self isExecuting]) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        self.state = state;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    } else {
        [self willChangeValueForKey:@"isExecuting"];
        self.state = state;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [self finishOperationWithState:HeroUploadStateCanceled];
    [self didChangeValueForKey:@"isCancelled"];
}

#pragma mark - NSURLConnection Delegate


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(upload:didSendFirstRespone:)]) {
            [self.delegate upload:self didSendFirstRespone:response];
        }
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite == 0) {
        _percentage= 0;
        return;
    }
    _percentage = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(upload:didSendData:onTotal:progress:)]) {
            [self.delegate upload:self didSendData:bytesWritten onTotal:totalBytesExpectedToWrite progress:_percentage];
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    if ([self isExecuting]) {
        // 点融特有错误
        if (_responseData) {
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&err];
            if (json) {
                if ([@"success" isEqualToString:json[@"result"]]) {
                    [self notifyFromCompletionWithError:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(upload:didFinishWithSuccessData:)]) {
                            [self.delegate upload:self didFinishWithSuccessData:[[json valueForKeyPath:@"content.files"] lastObject]];
                        }
                    });
                } else {
                    if (json[@"errors"]) {
                        NSError *error = [NSError errorWithDomain:@"com.dianrong.uploader" code:0 userInfo:@{NSLocalizedDescriptionKey:json[@"errors"][0]}];
                        [self notifyFromCompletionWithError:error];
                    }
                }
            } else {
                NSString *responseText = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
                NSError *error = [NSError errorWithDomain:@"com.dianrong.uploader" code:0 userInfo:@{NSLocalizedDescriptionKey:@"SERVER ERROR"}];
                [self notifyFromCompletionWithError:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"com.dianrong.uploader" code:0 userInfo:@{NSLocalizedDescriptionKey:@"UNKNOW ERROR"}];
            [self notifyFromCompletionWithError:error];
        }
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    [self notifyFromCompletionWithError:error];
}

@end
