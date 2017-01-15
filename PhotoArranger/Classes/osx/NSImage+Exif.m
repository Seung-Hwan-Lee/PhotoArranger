//
//  UIImage+Exif.m
//  Pods
//
//  Created by Nikita Tuk on 12/02/15.
//
//

#import <ImageIO/ImageIO.h>
#import "NSImage+Exif.h"
#import "ExifContainer.h"

@implementation NSImage (Exif)

+ (NSData *)getAppendedDataForImageData:(NSData *)imageData exif:(ExifContainer *)container
{
    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    
    // this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);

    // create a new data object and write the new image into it
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) container.exifData);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return dest_data;
    
}

+ (NSString *)dateForImageURL:(NSURL *)url
{
    NSString *dateString = nil;

    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);

    NSDictionary *props = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

    if ([props count]) {

        NSDictionary *exif = [props objectForKey:(NSString *)kCGImagePropertyExifDictionary];
        NSString *dateTimeString = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];

        if ([dateTimeString length]) {

            dateTimeString = [dateTimeString stringByReplacingOccurrencesOfString:@":" withString:@""];
            dateString = [[dateTimeString componentsSeparatedByString:@" "] firstObject];
        }
        else {

            NSInteger pixelWidth = [[props objectForKey:(NSString *)kCGImagePropertyPixelWidth] integerValue];
            NSInteger pixelHeight = [[props objectForKey:(NSString *)kCGImagePropertyPixelHeight] integerValue];

            if (pixelWidth > 0 && pixelHeight > 0) {

                NSString *path = [NSString stringWithCString:[url fileSystemRepresentation]
                                                    encoding:NSUTF8StringEncoding];

                NSError *error = nil;
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
                
                //            NSLog(@"%@", dic);
                if (error) {
                    NSLog(@"error! %@", error);
                    exit(1);
                }
            }
            else {
                NSInteger i = 9;
                i = 0;
            }
        }
    }

    CFRelease(source);

    return dateString;
}

+ (BOOL)isTooSmallImageOfImageURL:(NSURL *)url
{
    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);

    NSDictionary *props = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

    if ([props count] == 0) {
        CFRelease(source);
        return NO;
    }

    NSInteger pixelWidth = [[props objectForKey:(NSString *)kCGImagePropertyPixelWidth] integerValue];
    NSInteger pixelHeight = [[props objectForKey:(NSString *)kCGImagePropertyPixelHeight] integerValue];

    if (pixelWidth == 0 || pixelHeight == 0) {
        CFRelease(source);
        return NO;
    }

    CFRelease(source);

    BOOL isTooSmall = pixelWidth * pixelHeight < 500 * 500;
    if (isTooSmall) {
        NSLog(@"%@  %@ * %@", [url lastPathComponent], @(pixelWidth), @(pixelHeight));
    }

    return isTooSmall;
}

@end
