//
//  FileOperationWrap.h
//  iShare
//
//  Created by Jin Jin on 12-8-8.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FileOperationCompletionBlock)(BOOL);

typedef enum{
    FileContentTypeDirectory,
    FileContentTypeImage,
    FileContentTypeMovie,
    FileContentTypeMusic,
    FileContentTypeText,
    FileContentTypePDF,
    FileContentTypeDocument,
    FileContentTypeCompress,
    FileContentTypeOther
} FileContentType;

@interface FileOperationWrap : NSObject

+(void)removeFileItems:(NSArray*)fileItems withCompletionBlock:(FileOperationCompletionBlock)block;

+(BOOL)createDirectoryWithName:(NSString*)name path:(NSString*)path;
+(BOOL)createFileWithName:(NSString*)name path:(NSString*)path;
+(BOOL)saveFile:(NSData*)fileData withName:(NSString*)name path:(NSString*)path;

+(NSArray*)allImagePathsInFolder:(NSString*)folder;
+(NSArray*)allFilesWithFileContentType:(FileContentType)type inFolder:(NSString*)folder;

+(NSString*)zipFileAtFilePath:(NSString*)filePath toPath:(NSString*)path;
+(BOOL)unzipFileAtFilePath:(NSString*)filePath toPath:(NSString*)path;

+(NSString*)validFilePathForFilename:(NSString*)filename atPath:(NSString*)path;
+(NSString*)homePath;
+(NSString*)tempFolder;

+(FileContentType)fileTypeWithFilePath:(NSString*)filePath;

+(void)openFileItemAtPath:(NSString*)filePath withController:(UIViewController*)controller;
+(void)clearTempFolder;

@end
