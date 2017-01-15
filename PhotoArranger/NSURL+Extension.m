//
//  NSURL+Extension.m
//  PhotoArranger
//
//  Created by 이승환 on 2017. 1. 15..
//  Copyright © 2017년 Seung-Hwan Lee. All rights reserved.
//

#import "NSURL+Extension.h"

@implementation NSURL (Extension)

- (BOOL)isDirectoryFileURL
{
    NSNumber *isDirectory = nil;
    [self getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    return [isDirectory boolValue];
}

@end
