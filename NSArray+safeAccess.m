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

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayI") originSelector:@selector(objectAtIndex:) otherSelector:@selector(sa_objectAtIndex:)];
        
        [self swizzleInstanceMethod:NSClassFromString(@"__NSPlaceholderArray") originSelector:@selector(initWithObjects:count:) otherSelector:@selector(ss_initWithObjects:count:)];
        
        [self swizzleClassMethod:NSClassFromString(@"__NSPlaceholderArray") originSelector:@selector(arrayWithObjects:count:) otherSelector:@selector(ss_arrayWithObjects:count:)];
    });

}

-(id)sa_objectAtIndex:(NSUInteger)index{
    if (index < self.count) {
        return [self sa_objectAtIndex:index];
    }
    
    return nil;
}

-(id)ss_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt{

    for (int i=0; i<cnt; i++) {
        if(objects[i] == nil)
            return nil;
    }
    
    return [self ss_initWithObjects:objects count:cnt];
}

+(id)ss_arrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt{
    for (int i=0; i<cnt; i++) {
        if(objects[i] == nil)
            return nil;
    }
    return [self ss_arrayWithObjects:objects count:cnt];
}

@end

@implementation NSMutableArray (safeAccess)

+(void)load{


    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(addObject:) otherSelector:@selector(sa_addObject:)];
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(objectAtIndex:) otherSelector:@selector(sa_objectAtIndex:)];
    });

    
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

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceMethod:NSClassFromString(@"__NSDictionaryM") originSelector:@selector(setObject:forKey:) otherSelector:@selector(sa_setObject:forKey:)];
    });
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
+(void)load{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSPlaceholderDictionary") originSelector:@selector(initWithObjects:forKeys:count:) otherSelector:@selector(ss_initWithObjects:forKeys:count:)];
        
        [self swizzleClassMethod:NSClassFromString(@"__NSPlaceholderDictionary") originSelector:@selector(dictionaryWithObjects:forKeys:count:) otherSelector:@selector(ss_dictionaryWithObjects:forKeys:count:)];
        
    });
}


-(id)ss_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{

    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return  [self ss_initWithObjects:safeObjects forKeys:safeKeys count:j];
}

+(id)ss_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{

    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return [self ss_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}




@end

