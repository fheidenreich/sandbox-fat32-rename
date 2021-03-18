//
//  ExternalWriteHelper.m
//  sandbox-fat32-rename
//
//  Created by Florian on 18.03.21.
//

#import "ExternalWriteHelper.h"

@implementation ExternalWriteHelper

- (bool)write:(NSString*)fileName with:(NSString *)temporaryFileName
{
    const int fd = open([temporaryFileName UTF8String], O_CREAT | O_RDWR, S_IRWXU);
    if (fd == -1) {
        return false;
    }

    const char textBuffer[] = "This is an updated test.";
    const size_t textBufferSize = sizeof(textBuffer);
    const ssize_t bytesWritten = write(fd, textBuffer, textBufferSize);
    close(fd);

    if (bytesWritten != textBufferSize) {
        return false;
    }

    const int rc = rename([temporaryFileName UTF8String], [fileName UTF8String]);
    return rc == 0;
}

@end
