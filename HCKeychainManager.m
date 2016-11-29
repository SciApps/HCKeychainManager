//
//  HCKeychainManager.m
//  HCKeychainManager
//
//  Created by Árpád Goretity on 08/10/16.
//  Copyright © 2016 SciApps.io. All rights reserved.
//

#import "HCKeychainManager.h"

#import <Security/Security.h>
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN
@interface HCKeychainManager ()

+ (NSMutableDictionary *)queryDictionaryForKey:(NSString *)key;
+ (void)atomicallyInvokeBlock:(void (^)(void))block;

@end
NS_ASSUME_NONNULL_END

@implementation HCKeychainManager

#warning TODO(H2CO3): insert @dynamic for properties
// @dynamic foo;
// @dynamic bar;
// @dynamic qux;

#pragma mark - Initialization

+ (void)initialize {
    // This class is not to be subclassed, but for defensive
    // programming reasons, we still use the superclass checking idiom.
    if (self != HCKeychainManager.class) {
        return;
    }

    // Generate accessors for each declared property
    Class metaClass = object_getClass(self);

    NSString *getterType = [NSString stringWithFormat:@"%s%s", @encode(id), @encode(SEL)];
    NSString *setterType = [NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(SEL), @encode(id)];

    NSArray<NSString *> *propertyNames = @[
#warning TODO(H2CO3): fill in with declared property names
        // @"foo",
        // @"bar",
        // @"qux",
    ];

    for (NSString *propertyName in propertyNames) {
        NSString *getterName = propertyName;
        NSString *setterName = [NSString stringWithFormat:@"set%@%@:",
                                                          [propertyName substringToIndex:1].uppercaseString,
                                                          [propertyName substringFromIndex:1]];

        IMP getter = imp_implementationWithBlock(^(id selfPtr) {
            return selfPtr[propertyName];
        });

        IMP setter = imp_implementationWithBlock(^(id selfPtr, id newValue) {
            selfPtr[propertyName] = newValue;
        });

        class_addMethod(metaClass, NSSelectorFromString(getterName), getter, getterType.UTF8String);
        class_addMethod(metaClass, NSSelectorFromString(setterName), setter, setterType.UTF8String);
    }
}

#pragma mark - Public methods

+ (void)atomicallyInvokeBlock:(void (^)(void))block {
    NSParameterAssert(block);

    static NSLock *lock;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        lock = [NSLock new];
    });

    [lock lock];
    block();
    [lock unlock];
}

+ (void)setObject:(id _Nullable)newValue forKeyedSubscript:(NSString *)key {

    NSParameterAssert(key);

    NSString *oldValue = self.self[key];

    if (newValue) {
        if (oldValue == nil) {
            // Does not yet exist, so add to keychain
            NSMutableDictionary *update = [self queryDictionaryForKey:key];

            update[(__bridge id) kSecClass]     = (__bridge id) kSecClassGenericPassword;
            update[(__bridge id) kSecValueData] = [NSPropertyListSerialization dataWithPropertyList:newValue
                                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                                            options:kNilOptions
                                                                                              error:NULL];

            [self atomicallyInvokeBlock:^{
                SecItemAdd((__bridge CFDictionaryRef) update, NULL);
            }];
        } else if ([oldValue isEqual:newValue] == NO) {
            // Exists but new value differs from old value: update item
            NSMutableDictionary *query = [self queryDictionaryForKey:key];
            NSMutableDictionary *update = [self queryDictionaryForKey:key];

            query[(__bridge id) kSecClass]      = (__bridge id) kSecClassGenericPassword;
            update[(__bridge id) kSecValueData] = [NSPropertyListSerialization dataWithPropertyList:newValue
                                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                                            options:kNilOptions
                                                                                              error:NULL];

            [self atomicallyInvokeBlock:^{
                SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) update);
            }];
        }
        // otherwise: old value exists and is equal to new value - no need to do anything
    } else {
        if (oldValue) {
            // New value is nil, but old value exists, so remove it from the keychain
            NSMutableDictionary *query = [self queryDictionaryForKey:key];

            query[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;

            [self atomicallyInvokeBlock:^{
                SecItemDelete((__bridge CFDictionaryRef) query);
            }];
        }
        // otherwise: setting nonexistent to nil, which is a no-op
    }
}

+ (id _Nullable)objectForKeyedSubscript:(NSString *)key {
    NSParameterAssert(key);

    __block CFTypeRef data = NULL;
    NSMutableDictionary *query = [self queryDictionaryForKey:key];

    query[(__bridge id) kSecReturnData] = (__bridge id) kCFBooleanTrue;
    query[(__bridge id) kSecClass]      = (__bridge id) kSecClassGenericPassword;

    __block OSStatus status;

    [self atomicallyInvokeBlock:^{
        status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &data);
    }];

    if (status != noErr) {
        return nil;
    }

    if (data == NULL) {
        return nil;
    }

    return [NSPropertyListSerialization propertyListWithData:CFBridgingRelease(data)
                                                     options:kNilOptions
                                                      format:NULL
                                                       error:NULL];
}

#pragma mark - Private methods

+ (NSMutableDictionary *)queryDictionaryForKey:(NSString *)key {

    NSParameterAssert(key);

    NSDictionary *dictionary = @{
        (__bridge id) kSecAttrAccount: [key dataUsingEncoding:NSUTF8StringEncoding],
        (__bridge id) kSecAttrService: NSBundle.mainBundle.bundleIdentifier,
    };

    return [dictionary mutableCopy];
}

@end
