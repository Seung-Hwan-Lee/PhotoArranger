//
//  Util.h
//  PhotoArranger
//
//  Created by 이승환 on 2017. 1. 15..
//  Copyright © 2017년 Seung-Hwan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

@end

NSDirectoryEnumerator * directoryEnumerator(NSURL * srcDirectoryURL);
NSString * dateFromFileURL(NSURL * fileURL);

void logCommandLineArguments(int argc, const char * argv[]);
