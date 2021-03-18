//
//  ExternalWriteHelper.h
//  sandbox-fat32-rename
//
//  Created by Florian on 18.03.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExternalWriteHelper : NSObject

- (bool)write:(NSString*)fileName with:(NSString*)temporaryFileName;

@end

NS_ASSUME_NONNULL_END
