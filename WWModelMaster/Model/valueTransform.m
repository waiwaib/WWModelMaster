//
//  valueTransform.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/9.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "valueTransform.h"
#import "jsonModel.h"

NSString * const constant_propertyClassName = @"propertyClassName";
NSString * const constant_propertyType = @"propertyType";

@implementation valueTransform

extern BOOL isNull(id value)
{
    if (!value) return YES;
    if ([value isKindOfClass:[NSNull class]]) return YES;
    
    return NO;
}

extern NSArray * allPropertyNames(id object)
{
    NSMutableArray * properties = [[NSMutableArray alloc]init];
    
    unsigned int propertyCount = 0;
    
    objc_property_t * propertiesTemp = class_copyPropertyList([object class], &propertyCount);
    
    for (unsigned int i = 0; i<propertyCount; i++) {
        objc_property_t  property = propertiesTemp[i];
        
        const char * propertyName = property_getName(property);
        
        [properties addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    free(propertiesTemp);
    
    return properties;
}

extern NSArray * allPropertyValues(id object)
{
    NSArray * properties = allPropertyNames(object);
    
    NSMutableArray * values = [NSMutableArray array];
    
    for (NSString * propertyName in properties) {
        id value = [object valueForKey:propertyName];
        id valueObj = value ? value : [NSNull null];
        [values addObject:valueObj];
    }
    
    return values;
}

+ (NSDictionary *)propertyInfoFromProperty:(objc_property_t)property
{
    NSDictionary * peropertyInfo;
    
    NSUInteger propertyTypeIndex;
    
    NSString * propertyAttributeClassName;
    
    const char * attributeCStr = property_getAttributes(property);
    
    NSString * attribute = [NSString stringWithCString:attributeCStr encoding:NSUTF8StringEncoding];
    
    NSArray * compents = [attribute componentsSeparatedByString:@"\""];
    
    if (3 == compents.count) {
         //this is the cocoa object
        propertyAttributeClassName = [compents objectAtIndex:1];
    }
    else if([attribute rangeOfString:@"TB,N,"].length)
    {
        //bool类型
        propertyAttributeClassName = @"BOOL";
    }
    else if([attribute rangeOfString:@"Tq,N,"].length||[attribute rangeOfString:@"TQ,N,"].length||[attribute rangeOfString:@"Td,N,"].length)
    {
        //Integer类型
        propertyAttributeClassName = @"NSInteger";
    }
    else
    {
        //未收录类型
        propertyAttributeClassName = @"unKown";
    }
    
    NSArray * types = @[@"unKown",@"NSString",@"NSNumber",@"NSDictionary",@"NSArray",@"NSSet",@"BOOL",@"NSInteger"];
    
    if ([types containsObject:propertyAttributeClassName]) {
        propertyTypeIndex = [types indexOfObject:propertyAttributeClassName];
    }
    else
    {
        Class modelClass = NSClassFromString(propertyAttributeClassName);
        
        if ([modelClass isSubclassOfClass:[jsonModel class]]) {
            
            propertyTypeIndex = propertyTypeModel;
        }
        else
        {
            NSLog(@"unkown transform type %@",propertyAttributeClassName);
        
            propertyTypeIndex = propertyTypeUnkown;
        }
    }
    
    peropertyInfo = @{constant_propertyType:[NSNumber numberWithInteger:propertyTypeIndex],constant_propertyClassName:propertyAttributeClassName};
    
    return peropertyInfo;
}

+ (NSString *)propertyDisplayFromProperty:(objc_property_t)property  value:(id)value
{
    id  display = value;
    
    NSDictionary * propertyInfo = [self propertyInfoFromProperty:property];
    
    propertyType pType = (propertyType)propertyInfo[constant_propertyType];
    
    switch (pType) {
        case propertyTypeString:
        {
            display = [value copy];
            break;
        }
        case propertyTypeNumber:
        {
            display = [[value stringValue] copy];
            break;
        }
        case propertyTypeDictionary:
        {
            
            break;
        }
        case propertyTypeArrray:
        {
            
            break;
        }
        case propertyTypeBool:
        {
            display = [value boolValue] ? @"YES" : @"NO";
            break;
        }
        case propertyTypeNSSet:
        {
            
            break;
        }
        case propertyTypeModel:
        {
            break;
        }
        case propertyTypeUnkown:
        {
            if ([value respondsToSelector:@selector(stringValue)]) {
                display = [value stringValue];
            }
            break;
        }
        default:
            break;
    }
    return display;
}
@end
