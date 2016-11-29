//
//  HCKeychainManager.h
//  HCKeychainManager
//
//  Created by Árpád Goretity on 08/10/16.
//  Copyright © 2016 SciApps.io. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface HCKeychainManager : NSObject

#warning TODO(H2CO3): add declared @properties
// @property (nonatomic, copy, nullable, class) NSString *foo;
// @property (nonatomic, copy, nullable, class) NSArray<NSData *> *bar;
// @property (nonatomic, copy, nullable, class) NSDate *qux;

+ (id _Nullable)objectForKeyedSubscript:(NSString *)key;
+ (void)setObject:(id _Nullable)newValue forKeyedSubscript:(NSString *)key;

@end
NS_ASSUME_NONNULL_END
