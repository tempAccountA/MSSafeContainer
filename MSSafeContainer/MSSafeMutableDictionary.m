//
//  MSSafeMutableDictionary.m
//
//  Created by J on 14-3-6.
//  Copyright (c) 2014年 J. All rights reserved.
//

#import "MSSafeMutableDictionary.h"

@interface MSSafeMutableDictionary ()
{
    NSRecursiveLock *_safeLock;
    CFMutableDictionaryRef _dictionary;
}
@end

@implementation MSSafeMutableDictionary

- (id)init
{
    return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self)
    {
        _safeLock = [[NSRecursiveLock alloc] init];
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, numItems,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self init];
    if (self)
    {
        for (NSInteger idx = 0; idx < cnt; idx++)
        {
            CFDictionaryAddValue(_dictionary, (__bridge const void *)(keys[idx]), (__bridge const void *)(objects[idx]));
        }
    }
    return self;
}

- (void)dealloc
{
    if (_dictionary)
    {
        CFRelease(_dictionary);
        _dictionary = NULL;
    }
}

- (NSUInteger)count
{
    [_safeLock lock];
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    [_safeLock unlock];
    return count;
}

- (id)objectForKey:(id)aKey
{
    if (!aKey)
        return nil;
    
    [_safeLock lock];
    id result = CFDictionaryGetValue(_dictionary, (__bridge const void *)(aKey));
    [_safeLock unlock];
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    [_safeLock lock];
    id result = [(__bridge id)_dictionary keyEnumerator];
    [_safeLock unlock];
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!anObject || !aKey)
        return;
    
    [_safeLock lock];
    CFDictionarySetValue(_dictionary, (__bridge const void *)aKey, (__bridge const void *)anObject);
    [_safeLock unlock];
}

- (void)removeObjectForKey:(id)aKey
{
    if (!aKey)
        return;
    
    [_safeLock lock];
    CFDictionaryRemoveValue(_dictionary, (__bridge const void *)aKey);
    [_safeLock unlock];
}

#pragma mark Optional

- (void)removeAllObjects
{
    [_safeLock lock];
    CFDictionaryRemoveAllValues(_dictionary);
    [_safeLock unlock];
}

#pragma mark NSLocking

- (void)lock
{
    [_safeLock lock];
}

- (void)unlock
{
    [_safeLock unlock];
}

@end
