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

#import "NSData+HashMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (HashMD5)

+ (NSString*) hashMD5StringFromData:(NSData*)data{
    return [data hashMD5String];
}

- (NSString*) hashMD5String{
    
    //Get the MD5 hash for the data
    unsigned char hashChar [CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, self.length, hashChar);
    NSMutableString * hashMutable = [NSMutableString string];
    for (int i=0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hashMutable appendFormat:@"%02X", hashChar[i]];
    }
    return [NSString stringWithString:hashMutable];
    
}



@end
