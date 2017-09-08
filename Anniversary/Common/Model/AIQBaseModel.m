//
//  AIQBaseModel.m
//  Anniversary
//
//  Created by 小希 on 2017/9/8.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQBaseModel.h"
#import <objc/runtime.h>

@implementation AIQBaseModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
        {
            Ivar const ivar = *p;
            const char *type = ivar_getTypeEncoding(ivar);
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (key == nil){
                continue;
            }
            if ([key length] == 0){
                continue;
            }
            if ([self skipCodingIvarKeys] && [[self skipCodingIvarKeys] containsObject:key]) {
                continue;
            }
            id value = [self valueForKey:key];
            if (value) {
                switch (type[0]) {
                    case _C_STRUCT_B: {
                        NSUInteger ivarSize = 0;
                        NSUInteger ivarAlignment = 0;
                        NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                        NSData *data = [NSData dataWithBytes:(const char *)(__bridge void *)self + ivar_getOffset(ivar)
                                                      length:ivarSize];
                        [encoder encodeObject:data forKey:key];
                    }
                        break;
                    default:
                        [encoder encodeObject:value
                                       forKey:key];
                        break;
                }
            }
        }
        if (ivars) {
            free(ivars);
        }
        
        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numberOfIvars = 0;
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
            
            for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
            {
                Ivar const ivar = *p;
                const char *type = ivar_getTypeEncoding(ivar);
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if (key == nil){
                    continue;
                }
                if ([key length] == 0){
                    continue;
                }
                if ([self skipCodingIvarKeys] && [[self skipCodingIvarKeys] containsObject:key]) {
                    continue;
                }
                id value = [decoder decodeObjectForKey:key];
                if (value) {
                    switch (type[0]) {
                        case _C_STRUCT_B: {
                            NSUInteger ivarSize = 0;
                            NSUInteger ivarAlignment = 0;
                            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                            NSData *data = [decoder decodeObjectForKey:key];
                            char *sourceIvarLocation = (char*)(__bridge void *)self + ivar_getOffset(ivar);
                            [data getBytes:sourceIvarLocation length:ivarSize];
                        }
                            break;
                        default:
                            [self setValue:value forKey:key];
                            break;
                    }
                }
            }
            
            if (ivars) {
                free(ivars);
            }
            cls = class_getSuperclass(cls);
        }
    }
    
    return self;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"%@: {\n", NSStringFromClass([self class])];
    unsigned int count = 0;
    objc_property_t *propList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propList[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        if ([name isEqualToString:@"description"] || [name isEqualToString:@"debugDescription"]) {
            continue;
        }
        id value = [self valueForKey:name];
        [desc appendFormat:@"\t%@: %@\n", name, value];
    }
    
    if (propList) {
        free(propList);
    }
    
    [desc appendString:@"}"];
    return [desc copy];
}

- (nullable NSArray <NSString *>*)skipCodingIvarKeys {
    return nil;
}

@end
