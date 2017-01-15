//
//  main.m
//  PhotoArranger
//
//  Created by Seung-Hwan Lee on 2016. 12. 30..
//  Copyright © 2016년 Seung-Hwan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSImage+Exif.h"
#import "Util.h"
#import "NSURL+Extension.h"
#import "NSString+Extension.h"


void startWork(int argc, const char * argv[]);

void moveMediaFiles(NSString *srcDirectory, NSString *dstDirectory);
void moveFileWhichHasPrefix(NSString * prefix, NSString * srcDirectory, NSString * dstDirectory);
void adjustFileDate(NSString *srcDirectory);
void adjustFileExtension(NSString *srcDirectory, NSString * dstDirectory);

void processDirectory(NSString *srcDirectory, NSString *dstDirectory);

void processDuplicatedFiles(NSString *directory);
void removeFaceTile(NSString *directory);
void removeTooSmallImages(NSString *directory);
void arrangeFileExtension(NSString *directory);
void renameMovieFileNameToDate(NSURL * fileURL);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        startWork(argc, argv);
    }
    return 0;
}

void startWork(int argc, const char * argv[])
{
#if 1
    if (argc < 3) {
        logCommandLineArguments(argc, argv);
        NSLog(@"PhotoArranger [command] [src_dir] [dst_dir] [option]");
//        NSLog(@"PhotoArranger [src_dir] [dst_dir]");
        exit(1);
    }
    
    NSString * command = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    
    if ([command isEqualToString:@"moveFileIfPrefix"]) {
        
        if (argc != 5) {
            logCommandLineArguments(argc, argv);
            NSLog(@"PhotoArranger moveFileIfPrefix [src_dir] [dst_dir] [prefix]");
            exit(1);
        }

        NSString * srcDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        NSString * dstDirectory = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
        NSString * prefix = [NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding];
        
        moveFileWhichHasPrefix(prefix, srcDirectory, dstDirectory);
        
        return ;
    }
    else if ([command isEqualToString:@"moveFilesAccordingToDate"]) {
        if (argc != 4) {
            logCommandLineArguments(argc, argv);
            NSLog(@"PhotoArranger moveFilesAccordingToDate [src_dir] [dst_dir]");
            exit(1);
        }
        
        NSString * srcDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        NSString * dstDirectory = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
        
        moveMediaFiles(srcDirectory, dstDirectory);
        
        return ;
    }
    else if ([command isEqualToString:@"adjustFileDate"]) {
        if (argc != 3) {
            logCommandLineArguments(argc, argv);
            NSLog(@"PhotoArranger adjustFileDate [src_dir]");
            exit(1);
        }
        
        NSString * srcDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        
        adjustFileDate(srcDirectory);
        
        return ;
    }
    else if ([command isEqualToString:@"adjustFileExtension"]) {
        if (argc != 4) {
            logCommandLineArguments(argc, argv);
            NSLog(@"PhotoArranger adjustFileExtension [src_dir] [dst_dir]");
            exit(1);
        }
        
        NSString * srcDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        NSString * dstDirectory = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];

        adjustFileExtension(srcDirectory, dstDirectory);
        
        return ;
    }
    
//    NSString *srcDirectory = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
//    NSString *dstDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"src dir : %@", srcDirectory);
//    NSLog(@"dst dir : %@", dstDirectory);
//    
//    processDirectory(srcDirectory, dstDirectory);
#endif
    
#if 0
    //        if (argc != 2) {
    //            NSLog(@"PhotoArranger [target_dir]");
    //            return 0;
    //        }
    NSString *directory = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    NSLog(@"directory : %@", directory);
    
    //        arrangeFileExtension(directory);
    //        removeTooSmallImages(directory);
    processDuplicatedFiles(directory);
#endif
}

void arrangeFileExtension(NSString *directory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:directory];

    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *directoryEnumerator =
    [localFileManager enumeratorAtURL:srcDirectoryURL
           includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                             NSLog(@"error! %@ %@", url, error);
                             exit(1);
                         }];

    NSError * error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"_[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}JPG"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (regEx == nil || error != nil) {
        NSLog(@"failed to create NSRegularExpression\nerror : %@", error);
        exit(1);
    }

    for (NSURL *fileURL in directoryEnumerator) {
        @autoreleasepool {
            NSString * lastPathComponent = [fileURL lastPathComponent];
            NSRange range = [regEx rangeOfFirstMatchInString:lastPathComponent options:0 range:NSMakeRange(0, [lastPathComponent length])];
            if (range.location == NSNotFound) {
                //                NSLog(@".");
                continue;
            }

            NSLog(@"%@", fileURL);

            NSString * fileName = [lastPathComponent substringWithRange:NSMakeRange(0, [lastPathComponent length]-3)];
            NSString * fileExtension = @"JPG";
            NSString * newFileName = [NSString stringWithFormat:@"%@.%@", fileName, fileExtension];

            NSURL * newFileURL = [[fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newFileName];

            NSLog(@"org   %@", fileURL);
            NSLog(@"new   %@", newFileURL);

            NSError * error = nil;
            if (![[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newFileURL error:&error]) {
                NSLog(@"failed to remove file - %@\n%@", fileURL, error);
                exit(1);
            }
        }
    }
}

void removeTooSmallImages(NSString *directory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:directory];

    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *directoryEnumerator =
    [localFileManager enumeratorAtURL:srcDirectoryURL
           includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                             NSLog(@"error! %@ %@", url, error);
                             return NO;
                         }];

    //    NSMutableArray<NSURL *> *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in directoryEnumerator) {
        @autoreleasepool {

            NSNumber *isDirectory = nil;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            if ([isDirectory boolValue] == YES) {
                NSLog(@".");
                continue;
            }

            if ([NSImage isTooSmallImageOfImageURL:fileURL]) {
                // for image

                NSError * error = nil;
                if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
                    NSLog(@"failed to remove file - %@\n%@", fileURL, error);
                    exit(1);
                }

                NSLog(@"remove  %@", fileURL);
            }
        }
    }
}

void removeFaceTile(NSString *directory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:directory];

    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *directoryEnumerator =
    [localFileManager enumeratorAtURL:srcDirectoryURL
           includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                             NSLog(@"error! %@ %@", url, error);
                             exit(1);
                         }];

    NSError * error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"UNADJUSTEDNONRAW_mini_"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (regEx == nil || error != nil) {
        NSLog(@"failed to create NSRegularExpression\nerror : %@", error);
        exit(1);
    }

    for (NSURL *fileURL in directoryEnumerator) {
        @autoreleasepool {
            NSString * lastPathComponent = [fileURL lastPathComponent];
            NSRange range = [regEx rangeOfFirstMatchInString:lastPathComponent options:0 range:NSMakeRange(0, [lastPathComponent length])];
            if (range.location == NSNotFound) {
                NSLog(@".");
                continue;
            }

            NSError * error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
                NSLog(@"failed to remove file - %@\n%@", fileURL, error);
                exit(1);
            }

            NSLog(@"remove  %@", fileURL);
        }
    }
}

void processDuplicatedFiles(NSString *directory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:directory];

    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *directoryEnumerator =
    [localFileManager enumeratorAtURL:srcDirectoryURL
           includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                             NSLog(@"error! %@ %@", url, error);
                             exit(1);
                         }];

    NSError * error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"_[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (regEx == nil || error != nil) {
        NSLog(@"failed to create NSRegularExpression\nerror : %@", error);
        exit(1);
    }

    for (NSURL *fileURL in directoryEnumerator) {
        @autoreleasepool {
            NSString * lastPathComponent = [fileURL lastPathComponent];
            NSRange range = [regEx rangeOfFirstMatchInString:lastPathComponent options:0 range:NSMakeRange(0, [lastPathComponent length])];
            if (range.location == NSNotFound) {
//                NSLog(@".");
                continue;
            }

            NSLog(@"%@", fileURL);
//            NSLog(@"found - %@", lastPathComponent);

            NSString * fileName = [lastPathComponent substringToIndex:range.location];
            NSString * fileExtension = [fileURL pathExtension];
            NSString * originalFileName = [NSString stringWithFormat:@"%@.%@", fileName, fileExtension];

            NSURL * originalFileURL = [[fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:originalFileName];

            unsigned long long originalFileSize = fileSizeFromFileURL(originalFileURL);

            unsigned long long fileSize = fileSizeFromFileURL(fileURL);

            if (fileSize == originalFileSize) {
                NSLog(@"size is same - %@ , %@", @(fileSize), @(originalFileSize));

                NSError * error = nil;
                if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
                    NSLog(@"failed to remove file - %@\n%@", fileURL, error);
                    exit(1);
                }

                NSLog(@"remove   %@", fileURL);
                NSLog(@"preserve %@", originalFileURL);
            }
        }
    }
}

void processDirectory(NSString *srcDirectory, NSString *dstDirectory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:srcDirectory];

    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *enumerator = directoryEnumerator(srcDirectoryURL);

//    NSMutableArray<NSURL *> *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        @autoreleasepool {

            if ([fileURL isDirectoryFileURL]) {
                continue ;
            }

            NSString * fileName = [fileURL lastPathComponent];
            NSLog(@"%@", fileName);

            NSError *error = nil;

            NSString * dateString = nil;

            dateString = [NSImage dateFromImageURL:fileURL];
            if ([dateString length] > 0) {
                // for image

                NSLog(@"image! %@", dateString);
            }
            else {

                // for video
                NSString * pathExtension = [[fileURL pathExtension] uppercaseString];

                if (![@[@"MP4", @"MOV", @"AVI", @"MPG"] containsObject:pathExtension]) {
                    continue;
                }

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

                dateString = [dateFormatter stringFromDate:date];
                
                NSLog(@"CreationDate     : %@", creationDate);
                NSLog(@"ModificationDate : %@", modificationDate);
                NSLog(@"dateString       : %@", dateString);
            }

            NSString *yearString = [dateString substringToIndex:4];

            NSString *dstDir = [[dstDirectory stringByAppendingPathComponent:yearString] stringByAppendingPathComponent:dateString];
            [localFileManager createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:nil];

            NSLog(@"dst dir : %@", dstDir);

            NSString *dstFile = [dstDir stringByAppendingPathComponent:fileName];

            NSLog(@"dst file : %@", dstFile);

            if ([localFileManager fileExistsAtPath:dstFile]) {

                NSLog(@"exist!");

                NSString *fileNewName = [fileName stringByInsertingPostfixInFileName:[[NSUUID UUID] UUIDString]];

                dstFile = [dstDir stringByAppendingPathComponent:fileNewName];

                NSLog(@"another dst file : %@", dstFile);
            }

            NSURL *dstFileURL = [NSURL fileURLWithPath:dstFile];

            NSLog(@"%@\n> %@", fileURL, dstFile);

//            NSError *error = nil;
            if (![localFileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
                NSLog(@"failed to move , %@", error);
                exit(1);
            }
        

//        if ([isDirectory boolValue]) {
//            NSString *name = nil;
//            [fileURL getResourceValue:&name forKey:NSURLNameKey error:nil];
//
//            if ([name isEqualToString:@"_extras"]) {
//                [directoryEnumerator skipDescendants];
//            } else {
//                [mutableFileURLs addObject:fileURL];
//            }
//        }
        }
    }
}

void moveMediaFiles(NSString *srcDirectory, NSString *dstDirectory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:srcDirectory];
    
    NSFileManager *localFileManager= [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *enumerator = directoryEnumerator(srcDirectoryURL);
    
    for (NSURL *fileURL in enumerator) {
        
        @autoreleasepool {
            
            if ([fileURL isDirectoryFileURL]) {
                NSLog(@".");
                continue ;
            }
            
            NSString * fileName = [fileURL lastPathComponent];
            NSLog(@"%@", fileName);
            
            NSError *error = nil;
            
            NSString * dateString = nil;
            
            dateString = [NSImage dateFromImageURL:fileURL];
            if ([dateString length] > 0) {
                // for image
                
                NSLog(@"image! %@", dateString);
            }
            else {
                
                // for video
                NSString * pathExtension = [[fileURL pathExtension] uppercaseString];
                
                if (![@[@"MP4", @"MOV", @"AVI", @"MPG"] containsObject:pathExtension]) {
                    NSLog(@".");
                    continue;
                }

                dateString = dateFromFileURL(fileURL);
            }
            
            NSString *yearString = [dateString substringToIndex:4];
            
            NSString *dstDir = [[dstDirectory stringByAppendingPathComponent:yearString] stringByAppendingPathComponent:dateString];
            [localFileManager createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:nil];
            
            
            NSString *dstFile = [dstDir stringByAppendingPathComponent:fileName];
            
            NSLog(@"dst file : %@", dstFile);
            
            if ([localFileManager fileExistsAtPath:dstFile]) {
                
                NSLog(@"exist!");
                
                NSString *fileNewName = [fileName stringByInsertingPostfixInFileName:[[NSUUID UUID] UUIDString]];
                
                dstFile = [dstDir stringByAppendingPathComponent:fileNewName];
                
                NSLog(@"new dst file : %@", dstFile);
            }
            
            NSURL *dstFileURL = [NSURL fileURLWithPath:dstFile];
            
            NSLog(@"%@\n> %@", fileURL, dstFile);
            
            if (![localFileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
                NSLog(@"failed to move , %@", error);
                exit(1);
            }
        }
    }
}

void adjustFileDate(NSString *srcDirectory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:srcDirectory];
    
    NSFileManager *localFileManager= [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *enumerator = directoryEnumerator(srcDirectoryURL);
    
    for (NSURL *fileURL in enumerator) {
        
        @autoreleasepool {
            
            if ([fileURL isDirectoryFileURL]) {
                NSLog(@".");
                continue ;
            }
            
            NSString * fileName = [fileURL lastPathComponent];
            NSLog(@"%@", fileName);
            
            NSError *error = nil;
            
            NSString * dateString = nil;
            
            if ([NSImage adjustDate:fileURL]) {
                NSLog(@".");
                continue ;
            }

            NSString * pathExtension = [[fileURL pathExtension] uppercaseString];
            
            if (![@[@"MP4", @"MOV", @"AVI", @"MPG"] containsObject:pathExtension]) {
                NSLog(@".");
                continue;
            }
            
            renameMovieFileNameToDate(fileURL);
        }
    }
}

void adjustFileExtension(NSString *srcDirectory, NSString * dstDirectory)
{
    NSURL *srcDirectoryURL = [NSURL fileURLWithPath:srcDirectory];
    NSURL *dstDirectoryURL = [NSURL fileURLWithPath:dstDirectory];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = directoryEnumerator(srcDirectoryURL);
    
    for (NSURL *fileURL in enumerator) {
        
        @autoreleasepool {
            
            if ([fileURL isDirectoryFileURL]) {
//                NSLog(@".");
                continue ;
            }
            
            NSString * fileName = [fileURL lastPathComponent];
            NSString * fileExt = [fileName pathExtension];
            
            if ([fileExt length] > 0) {
//                NSLog(@".");
                continue ;
            }
            
            if ([fileName hasSuffix:@"."]) {
                fileName = [fileName substringToIndex:[fileName length]-1];
            }

            fileExt = [[fileName substringFromIndex:[fileName length]-3] uppercaseString];

            if (![@[@"JPG", @"PNG", @"GIF"] containsObject:fileExt]) {
                NSLog(@"strange file %@", fileURL);

                NSURL * dstFileURL = [dstDirectoryURL URLByAppendingPathComponent:[fileURL lastPathComponent]];
                
                NSLog(@"%@\n -> %@", fileURL, dstFileURL);
                
                NSError * error = nil;
                if (![fileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
                    NSLog(@"failed to move , %@", error);
                    exit(1);
                }

                continue;
            }
            
            fileName = [fileName substringToIndex:[fileName length]-3];
            
            NSString * newFileName = [NSString stringWithFormat:@"%@.%@", fileName, fileExt];
            
            NSURL * dstFileURL = [[fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newFileName];
            
            NSLog(@"%@\n -> %@", fileURL, dstFileURL);
            
            NSError * error = nil;
            if (![fileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
                NSLog(@"failed to move , %@", error);
                exit(1);
            }
        }
    }
}

void moveFileWhichHasPrefix(NSString * prefix, NSString * srcDirectory, NSString * dstDirectory)
{
    NSURL * srcDirectoryURL = [NSURL fileURLWithPath:srcDirectory];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * enumerator = directoryEnumerator(srcDirectoryURL);
    
    for (NSURL *fileURL in enumerator) {

        @autoreleasepool {
            
            if ([fileURL isDirectoryFileURL]) {
                NSLog(@".");
                continue ;
            }
            
            NSString * fileName = [fileURL lastPathComponent];

            if (![fileName hasPrefix:prefix]) {
                NSLog(@".");
                continue ;
            }

            NSLog(@"%@", fileName);

            
            NSError *error = nil;
            NSString * dateString = nil;
            
            dateString = [NSImage dateFromImageURL:fileURL];
            if ([dateString length] > 0) {
                // for image
                NSLog(@"image! %@", dateString);
            }
            else {
                // for video
                NSString * pathExtension = [[fileURL pathExtension] uppercaseString];
                if (![@[@"MP4", @"MOV", @"AVI", @"MPG"] containsObject:pathExtension]) {
                    NSLog(@".");
                    continue;
                }
                dateString = dateFromFileURL(fileURL);
                NSLog(@"video! %@", dateString);
            }
            
            NSString *yearString = [dateString substringToIndex:4];
            
            NSString *dstDir = [[dstDirectory stringByAppendingPathComponent:yearString] stringByAppendingPathComponent:dateString];
            [fileManager createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:nil];
            
            
            NSString *dstFile = [dstDir stringByAppendingPathComponent:fileName];
            
            NSLog(@"dst file : %@", dstFile);
            
            if ([fileManager fileExistsAtPath:dstFile]) {
                
                NSLog(@"exist!");
                
                NSString *fileNewName = [fileName stringByInsertingPostfixInFileName:[[NSUUID UUID] UUIDString]];
                
                dstFile = [dstDir stringByAppendingPathComponent:fileNewName];
                
                NSLog(@"new dst file : %@", dstFile);
            }
            
            NSURL *dstFileURL = [NSURL fileURLWithPath:dstFile];
            
            NSLog(@"%@\n> %@", fileURL, dstFile);
            
            if (![fileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
                NSLog(@"failed to move , %@", error);
                exit(1);
            }
        }
    }
}

void renameMovieFileNameToDate(NSURL * fileURL)
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * filePath = [NSString stringWithCString:[fileURL fileSystemRepresentation] encoding:NSUTF8StringEncoding];
    
    NSError * error = nil;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy:MM:dd HH:mm:ss";

    NSMutableArray * dateList = [NSMutableArray array];
    

    
    NSDictionary<NSFileAttributeKey,id> *fileAttributes =
    [fileManager attributesOfItemAtPath:filePath error:&error];
    
    NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
    NSDate *modificationDate = [fileAttributes objectForKey:NSFileModificationDate];
    //    NSDate *fileDate = nil;
    
    NSLog(@"create : %@ , modify : %@",
          [dateFormatter stringFromDate:creationDate], [dateFormatter stringFromDate:modificationDate]);
    
    if (creationDate) {
        [dateList addObject:creationDate];
    }
    if (modificationDate) {
        [dateList addObject:modificationDate];
    }
    
    NSDate *date = [[dateList sortedArrayUsingSelector:@selector(compare:)] firstObject];
    
    NSLog(@"oldest date : %@", [dateFormatter stringFromDate:date]);
    
    NSMutableDictionary<NSFileAttributeKey,id> * newFileAttributes = [fileAttributes mutableCopy];
    newFileAttributes[NSFileCreationDate] = date;
    newFileAttributes[NSFileModificationDate] = date;
    
    error = nil;
    if (![fileManager setAttributes:newFileAttributes ofItemAtPath:filePath error:&error]) {
        NSLog(@"Failed update file attributes , %@", error);
        exit(1);
    }
    
    // check
    //    {
    //        NSDictionary<NSFileAttributeKey,id> *fileAttributes =
    //        [fileManager attributesOfItemAtPath:filePath error:&error];
    //
    //        NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
    //        NSDate *modificationDate = [fileAttributes objectForKey:NSFileModificationDate];
    //
    //        NSLog(@"updated creationDate : %@ , modificationDate : %@", creationDate, modificationDate);
    //    }
    
    
    NSDateFormatter *newFileNameFormatter = [[NSDateFormatter alloc] init];
    newFileNameFormatter.dateFormat = @"yyyyMMdd_HHmmss";
    
    NSString * fileName = [fileURL lastPathComponent];
    NSString * fileExt = [fileName pathExtension];
    
    NSString * newFileName = [[newFileNameFormatter stringFromDate:date] stringByAppendingPathExtension:fileExt];
    
    if ([fileName isEqualToString:newFileName]) {
        NSLog(@"already processed");
        return ;
    }
    
    fileName = [fileName stringByReplacingFileName:[newFileNameFormatter stringFromDate:date]];
    
    NSURL * dstFileURL = [[fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileName];
    
    
    if ([fileManager fileExistsAtPath:[NSString stringWithCString:[dstFileURL fileSystemRepresentation]
                                                         encoding:NSUTF8StringEncoding]]) {
        NSLog(@"exist!");
        
        NSString *fileNewName = [fileName stringByInsertingPostfixInFileName:[[NSUUID UUID] UUIDString]];
        
        dstFileURL = [[fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileNewName];
    }
    
    NSLog(@"%@ -> %@", fileURL, dstFileURL);
    
    error = nil;
    if (![fileManager moveItemAtURL:fileURL toURL:dstFileURL error:&error]) {
        NSLog(@"Failed update file attributes , %@", error);
        exit(1);
    }
    
    NSLog(@"\n");
    
}
