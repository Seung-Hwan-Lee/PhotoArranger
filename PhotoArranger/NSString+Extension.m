//
//  NSString+Extension.m
//  PhotoArranger
//
//  Created by 이승환 on 2017. 1. 15..
//  Copyright © 2017년 Seung-Hwan Lee. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)stringByInsertingPostfixInFileName:(NSString *)postfix
{
    NSArray<NSString*> *fileComponents = [self componentsSeparatedByString:@"."];
    
    NSMutableString *fileNewName = [NSMutableString string];
    [fileNewName appendString:[fileComponents firstObject]];
    [fileNewName appendString:@"_"];
    [fileNewName appendString:postfix];
    
    if ([fileComponents firstObject] != [fileComponents lastObject]) {
        [fileNewName appendString:@"."];
        [fileNewName appendString:[fileComponents lastObject]];
    }
    
    return fileNewName;
}

@end
