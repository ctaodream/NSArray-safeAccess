//
//  NSArray+safeAccess.m
//  FFMPEGDemo
//
//  Created by ct on 16/8/29.
//  Copyright © 2016年 funwear. All rights reserved.
//

#import "NSArray+safeAccess.h"
#import <objc/runtime.h>

@implementation NSObject (swizzExtension)

+(void)swizzleClassMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector{
    Method origin = class_getClassMethod(class, originSelector);
    
    Method other = class_getClassMethod(class, otherSelector);
    
    method_exchangeImplementations(origin, other);
}

+(void)swizzleInstanceMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector{
    Method origin = class_getInstanceMethod(class, originSelector);
    
    Method other = class_getInstanceMethod(class, otherSelector);
    
    method_exchangeImplementations(origin, other);
}

@end

@implementation NSArray (safeAccess)

+(void)load{

    [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayI") originSelector:@selector(objectAtIndex:) otherSelector:@selector(sa_objectAtIndex:)];
}

-(id)sa_objectAtIndex:(NSUInteger)index{
    if (index < self.count) {
        return [self sa_objectAtIndex:index];
    }
    
    return nil;
}


@end

@implementation NSMutableArray (safeAccess)

+(void)load{

    [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(addObject:) otherSelector:@selector(sa_addObject:)];
    [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(objectAtIndex:) otherSelector:@selector(sa_objectAtIndex:)];

    
}

- (void)sa_addObject:(id)object
{
    if (object != nil) {
        [self sa_addObject:object];
    }else{
        
        NSLog(@"WARNING: You tried to add a nil object");
    }
}

- (id)sa_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self sa_objectAtIndex:index];
    } else {
        NSLog(@"WARNING: You tried to get a beyond index");
        return nil;
    }
}

@end

@implementation NSMutableDictionary (safeAccess)

+(void)load{
    [self swizzleInstanceMethod:NSClassFromString(@"__NSDictionaryM") originSelector:@selector(setObject:forKey:) otherSelector:@selector(sa_setObject:forKey:)];
}

- (void) sa_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (aKey == nil) {
        NSLog(@"WARNING: You tried to insert a nil key");
        return;
    }
    if(anObject != nil)
    {
        [self sa_setObject:anObject forKey:aKey];
    }
    else
    {
        NSLog(@"WARNING: You tried to insert a nil value for key %@", aKey);
    }
}

@end

@implementation NSDictionary (safeAccess)



@end

