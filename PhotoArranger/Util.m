//
//  Util.m
//  PhotoArranger
//
//  Created by 이승환 on 2017. 1. 15..
//  Copyright © 2017년 Seung-Hwan Lee. All rights reserved.
//

#import "Util.h"

@implementation Util

@end

NSDirectoryEnumerator* directoryEnumerator(NSURL * srcDirectoryURL)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *directoryEnumerator =
    [fileManager enumeratorAtURL:srcDirectoryURL
      includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                    errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                        NSLog(@"error! %@ %@", url, error);
                        exit(1);
                        return NO;
                    }];
    return directoryEnumerator;
}

NSString * dateFromFileURL(NSURL * fileURL)
{
    NSError * error = nil;
    
    NSString *path = [NSString stringWithCString:[fileURL fileSystemRepresentation] encoding:NSUTF8StringEncoding];
    
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    NSDate *date = nil;
    NSDate *creationDate = [dic objectForKey:NSFileCreationDate];
    NSDate *modificationDate = [dic objectForKey:NSFileModificationDate];
    
    NSComparisonResult result = [creationDate compare:modificationDate];
    switch (result) {
        case NSOrderedAscending:
        default:
            date = creationDate;
            break;
        case NSOrderedDescending:
            date = modificationDate;
            break;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    
    NSString * dateString = [dateFormatter stringFromDate:date];
    
//    NSLog(@"CreationDate     : %@", creationDate);
//    NSLog(@"ModificationDate : %@", modificationDate);
//    NSLog(@"dateString       : %@", dateString);
    
    return dateString;
}

unsigned long long fileSizeFromFileURL(NSURL * fileURL)
{
    NSString *path = [NSString stringWithCString:[fileURL fileSystemRepresentation] encoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 0;
    }
    
    NSError * error = nil;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (dic == nil || error != nil) {
        NSLog(@"failed to get file attributed\n%@", error);
        exit(1);
    }
    
    return [[dic objectForKey:NSFileSize] unsignedLongLongValue];
}

void logCommandLineArguments(int argc, const char * argv[])
{
    NSMutableString * mutableString = [[NSMutableString alloc] init];
    for (int i = 0 ; i < argc ; i++) {
        [mutableString appendString:
         [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
        [mutableString appendString:@" "];
    }
    
    NSLog(@"%@", mutableString);
}

