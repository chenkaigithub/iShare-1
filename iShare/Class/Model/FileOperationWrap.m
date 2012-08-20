//
//  FileOperationWrap.m
//  iShare
//
//  Created by Jin Jin on 12-8-8.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FileOperationWrap.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation FileOperationWrap

+(void)removeFileItems:(NSArray*)fileItems withCompletionBlock:(FileOperationCompletionBlock)block{
    [fileItems enumerateObjectsUsingBlock:^(NSString* filePaths, NSUInteger idx, BOOL *stop){
        [[NSFileManager defaultManager] removeItemAtPath:filePaths error:NULL];
    }];
    
    if (block){
        block(YES);
    }
}

+(BOOL)createDirectoryWithName:(NSString*)name path:(NSString*)path{
    NSString* folderPath = [path stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:NULL];
}

+(BOOL)createFileWithName:(NSString*)name path:(NSString*)path{
    NSString* filePath = [path stringByAppendingPathComponent:name];
    NSString* fileContent = @"";
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[fileContent dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+(BOOL)saveFile:(NSData*)fileData withName:(NSString*)name path:(NSString*)path{
    
    NSString* filePath = [self validFilePathForFilename:name atPath:path];
    
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
}

+(NSString*)zipFileAtFilePath:(NSString*)filePath toPath:(NSString*)path{
    
    NSString* filename = [[filePath lastPathComponent] stringByAppendingPathExtension:@"zip"];
    NSString* zipPath = [FileOperationWrap validFilePathForFilename:filename atPath:path];
    NSData* fileData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    
    ZipFile *zipFile= [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeCreate];
    ZipWriteStream *stream1= [zipFile writeFileInZipWithName:[filePath lastPathComponent] fileDate:[attributes fileModificationDate] compressionLevel:ZipCompressionLevelBest];
    @try {
        [stream1 writeData:fileData];
        [stream1 finishedWriting];
        [zipFile close];
    }
    @catch (NSException *exception) {
        NSLog(@"zip failed: %@", exception.reason);
        zipPath = nil;
    }
    
    return zipPath;
}

+(BOOL)unzipFileAtFilePath:(NSString*)filePath toPath:(NSString*)path{
    
    BOOL result = YES;
    
    //create folder to zip file
    
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
    
    [unzipFile goToFirstFileInZip];
    BOOL keepReading = YES;
    
    @try {
        while(keepReading){
            FileInZipInfo *fInfo = [unzipFile getCurrentFileInZipInfo];
            //获得当前遍历文件的信息，包括大小、文件名、压缩级等等
            ZipReadStream *readStream = [unzipFile readCurrentFileInZip];
            //将当前文件读入readStream，如果当前文件有加密则使用readCurrentFileInZipWithPassword
//            ZipReadStream* readStream = [unzipFile readCurrentFileInZipWithPassword:password];
            NSMutableData *data = [[NSMutableData alloc] initWithLength:fInfo.length];
            //发现data的长度给的不对就要出问题，所以用文件大小初始化
            [readStream readDataWithBuffer:data];
            [readStream finishedReading];
            //写入到文件
            NSString* unzippedFilename = [self validFilePathForFilename:fInfo.name atPath:path];
            [data writeToFile:unzippedFilename atomically:YES];
            //读取下一个文件
            keepReading = [unzipFile goToNextFileInZip];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"unzip file %@ failed:%@", filePath, exception.reason);
        result = NO;
    }

    [unzipFile close];
    return result;
}

+(NSString*)validFilePathForFilename:(NSString*)filename atPath:(NSString*)path{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* extension = [filename pathExtension];
    NSRange extensionRange = [filename rangeOfString:[NSString stringWithFormat:@".%@", extension] options:NSBackwardsSearch];
    
    NSString* realName = [filename substringToIndex:extensionRange.location];
    
    NSString* validPath = [path stringByAppendingPathComponent:filename];
    
    int index =  1;
    
    while([fm fileExistsAtPath:validPath] == YES){
        NSString* tempname = [[NSString stringWithFormat:@"%@ %d", realName, index++] stringByAppendingPathExtension:extension];
        validPath = [path stringByAppendingPathComponent:tempname];
    }
    
    return validPath;

}

+(NSArray*)allImagePathsInFolder:(NSString*)folder{
    return [self allFilesWithFileContentType:FileContentTypeImage inFolder:folder];
}

+(NSArray*)allFilesWithFileContentType:(FileContentType)type inFolder:(NSString*)folder{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* filenames = [fm contentsOfDirectoryAtPath:folder error:NULL];
    NSMutableArray* allFiles = [NSMutableArray array];
    [filenames enumerateObjectsUsingBlock:^(NSString* filename, NSUInteger idx, BOOL* stop){
        NSString* filePath = [folder stringByAppendingPathComponent:filename];
        if ([self fileTypeWithFilePath:filePath] == type){
            [allFiles addObject:filePath];
        }
    }];
    
    return allFiles;
}

+(FileContentType)fileTypeWithFilePath:(NSString*)filePath{
    NSDictionary* attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];

    UIDocument* document = [[UIDocument alloc] initWithFileURL:[NSURL fileURLWithPath:filePath]];

    DebugLog(@"file type is %@", document.fileType);
    
    if ([[attribute fileType] isEqualToString:NSFileTypeDirectory]){
        //
        return FileContentTypeDirectory;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeImage)){
        return FileContentTypeImage;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypePDF)){
        return FileContentTypePDF;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeQuickTimeMovie) || UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeMPEG) || UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeMPEG4)){
        return FileContentTypeMovie;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeAudio)){
        return FileContentTypeMusic;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypePlainText)){
        return FileContentTypeText;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)kUTTypeDirectory)){
        return FileContentTypeDirectory;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef)(document.fileType), (CFStringRef)@"com.pkware.zip-archive")){
        return FileContentTypeCompress;
    }
    
    return FileContentTypeOther;
}

+(NSString*)homePath{
    NSString* defaultFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    DebugLog(@"%@", defaultFilePath);
    return defaultFilePath;
}

+(NSString*)tempFolder{
    NSString* tempFolder = NSTemporaryDirectory();
    DebugLog(@"%@", tempFolder);
    return tempFolder;
}

+(void)clearTempFolder{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* tempFolder = [self tempFolder];
    NSArray* items = [fm contentsOfDirectoryAtPath:tempFolder error:NULL];
    
    [items enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString* filename, NSUInteger idx, BOOL* stop){
        [fm removeItemAtPath:[tempFolder stringByAppendingPathComponent:filename] error:NULL];
    }];
}

+(void)openFileItemAtPath:(NSString*)filePath withController:(UIViewController*)controller{
    NSDictionary* attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    //for direcroty
    if ([[attribute fileType] isEqualToString:NSFileTypeDirectory]){
        
    }
}

@end
