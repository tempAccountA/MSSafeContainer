//
//  MSSafeMutableArray.m
//
//  Created by J on 14-3-6.
//  Copyright (c) 2014年 J. All rights reserved.
//

#import "MSSafeMutableArray.h"

@interface MSSafeMutableArray()
{
    CFMutableArrayRef _array;
    NSRecursiveLock *_safeLock;
}
@end

@implementation MSSafeMutableArray

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
        _array = CFArrayCreateMutable(kCFAllocatorDefault, numItems,  &kCFTypeArrayCallBacks);
    }
    return self;
}

- (void)dealloc
{
    if (_array)
    {
        CFRelease(_array);
        _array = NULL;
    }
}

- (NSUInteger)count
{
    [_safeLock lock];
    NSUInteger result = CFArrayGetCount(_array);
    [_safeLock unlock];
    return result;
}

- (id)objectAtIndex:(NSUInteger)index
{
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    id result = index<count ? CFArrayGetValueAtIndex(_array, index) : nil;
    [_safeLock unlock];
    return result;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (!anObject)
        return;
    
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    if (index > count) {
        index = count;
    }
    CFArrayInsertValueAtIndex(_array, index, (__bridge const void *)anObject);
    [_safeLock unlock];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    if (index < count) {
        CFArrayRemoveValueAtIndex(_array, index);
    }
    [_safeLock unlock];
}

- (void)addObject:(id)anObject
{
    if (!anObject)
        return;
    
    [_safeLock lock];
    CFArrayAppendValue(_array, (__bridge const void *)anObject);
    [_safeLock unlock];
}

- (void)removeLastObject
{
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    if (count > 0) {
        CFArrayRemoveValueAtIndex(_array, count-1);
    }
    [_safeLock unlock];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (!anObject)
        return;
    
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    if (index < count) {
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    }
    [_safeLock unlock];
}

#pragma mark Optional

- (void)removeAllObjects
{
    [_safeLock lock];
    CFArrayRemoveAllValues(_array);
    [_safeLock unlock];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    if (!anObject)
        return NSNotFound;
    
    [_safeLock lock];
    NSUInteger count = CFArrayGetCount(_array);
    NSUInteger result = CFArrayGetFirstIndexOfValue(_array, CFRangeMake(0, count), (__bridge const void *)(anObject));
    [_safeLock unlock];
    return result;
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
