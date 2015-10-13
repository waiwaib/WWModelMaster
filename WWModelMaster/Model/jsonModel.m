//
//  jsonModel.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "jsonModel.h"
#import "valueTransform.h"
#import "WWExceptionAndError.h"
@implementation jsonModel

- (id)init
{
    if (self = [super init]) {
        [self beforeLoad];
    }
    return self;
}

#pragma mark - AbstractJsonModelProtocol


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    
    if (self = [self init]) {
        if (isNull(dictionary)) {
            WWErrorLog(@"dictionary can't be nil");
            
            return self;
        }
        
        [self setPropertyWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithJsonString:(NSString *)string
{
    if (self = [self init]) {
        if (isNull(string)) {
            WWErrorLog(@"json string can't be nil");
            
            return self;
        }
        
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *err;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        
        if (err) {
            WWErrorLog(err.description);
        }
        
        [self setPropertyWithDictionary:dic];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [self init]) {
        if (isNull(data)) {
            WWErrorLog(@"data can't be nil");
            
            return self;
        }
        
        NSError * serialErr;
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];
        
        if(serialErr) {
            WWErrorLog(serialErr.description);
        }
        
        [self setPropertyWithDictionary:dic];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return [self toDictionaryWithKeys:allPropertyNames(self)];
}

- (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames
{
    
    NSMutableArray * keysArr = [[NSMutableArray alloc]initWithArray:propertyNames copyItems:YES];
    NSMutableArray * shouldDelKey = [[NSMutableArray alloc]init];
    NSArray * properties = allPropertyNames(self);
    for (NSString * key in keysArr) {
        if (![properties containsObject:key]) {
            NSString * expDsp = [NSString stringWithFormat:@"传入了错误的key:%@",key];
            WWExceptionLog(expDsp);
            [shouldDelKey addObject:key];
        }
    }
    
    //删除错误的key
    for (NSString * delKey in shouldDelKey) {
        [keysArr removeObject:delKey];
    }
    
    BOOL containModel = NO;
    
    NSMutableDictionary * result ;
    
    for (NSString * property in keysArr) {
        
        id value = [self valueForKey:property];
        
        if ([value isKindOfClass:[jsonModel class]]) {
            
            containModel = YES;
            
            if (!result) {
                result = [[NSMutableDictionary alloc]init];
            }
            
            [result setObject:[value toDictionary] forKeyedSubscript:property];
        }
        else
        {
            [result setObject:value forKeyedSubscript:property];
        }
    }
    
    return containModel ? [result copy] : [self dictionaryWithValuesForKeys:keysArr];
}

- (NSData *)toData
{
    NSData* jsonData;
    NSError* jsonError;
    
    @try {
        NSDictionary* dict = [self toDictionary];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        WWExceptionLog(exception.description);
        return nil;
    }
    
    return jsonData;
}

- (NSData *)toDataWithKeys:(NSArray *)propertyNames
{
    NSData* jsonData;
    NSError* jsonError;
    
    @try {
        NSDictionary* dict = [self toDictionaryWithKeys:propertyNames];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        WWExceptionLog(exception.description);
        return nil;
    }
    
    return jsonData;
}

- (NSString *)toJsonString
{
    NSData* jsonData;
    NSError* jsonError;
    
    @try {
        NSDictionary* dict = [self toDictionary];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        WWExceptionLog(exception.description);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)toJsonStringWithKeys:(NSArray *)propertyNames
{
    NSData* jsonData = nil;
    NSError* jsonError = nil;
    
    @try {
        NSDictionary* dict = [self toDictionaryWithKeys:propertyNames];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        WWExceptionLog(exception.description);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)analysisModelDisplayContent
{
    NSArray * properties = allPropertyNames(self);
    NSMutableString * displayStr = [[NSMutableString alloc]initWithString:@"{\n"];
    
    for (int i = 0; i<properties.count; i++) {
        SEL getSEL = [self creatGetterWithPropertyName:properties[i]];
        if ([self respondsToSelector:getSEL]) {
            NSMethodSignature * signature = [self methodSignatureForSelector:getSEL];
            
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setTarget:self];
            
            [invocation setSelector:getSEL];
            
            NSObject *__unsafe_unretained returnValue = nil;
            
            [invocation invoke];
            
            [invocation getReturnValue:&returnValue];
            
            objc_property_t property = class_getProperty([self class], [properties[i] cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSDictionary * propertyInfo = [valueTransform propertyInfoFromProperty:property];
            
            NSString * display;
            
            if (propertyTypeModel == [propertyInfo[constant_propertyType] integerValue]) {
                
                id <JsonModelProtocol> idTmep = returnValue;
                
                display = [idTmep analysisModelDisplayContent];
            }
            else if(propertyTypeBool == [propertyInfo[constant_propertyType] integerValue])
            {
                //针对bool类型 做特殊处理;
                BOOL boolValue = [self valueForKey:properties[i]];
                display = boolValue ? @"YES" : @"NO";
            }
            else if(propertyTypeInt == [propertyInfo[constant_propertyType] integerValue])
            {
                //针对NSInterger int NSUIterger做特殊特殊处理
                NSInteger iterValue = [[self valueForKey:properties[i]] integerValue];
                display = [[NSNumber numberWithInteger:iterValue]stringValue];
            }
            else if(propertyTypeUnkown == [propertyInfo[constant_propertyType] integerValue])
            {
                //可能不属于cocoa object
            }
            else
            {
                display = [valueTransform propertyDisplayFromProperty:property value:returnValue];
            }
            @try {
                [displayStr appendFormat:@"%@-->%@\n",properties[i],display];
            }
            @catch (NSException *exception) {
                WWExceptionLog(exception.description);
            }
        }
    }
    [displayStr appendString:@"}"];
    return displayStr;
}
#pragma mark - public method
- (void)beforeLoad
{
    
}

- (void)setPropertyWithDictionary:(NSDictionary *)data
{
    if (![data isKindOfClass:[NSDictionary class]]) {
        WWExceptionLog(@"赋值model请使用Dictionary")
        return;
    }
    
    NSArray * properyNames = allPropertyNames(self);
    [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([properyNames containsObject:key]) {
            
            objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSDictionary * propertyInfo = [valueTransform propertyInfoFromProperty:property];
            
            if (propertyTypeModel == [propertyInfo[constant_propertyType] integerValue] && [obj isKindOfClass:[NSDictionary class]]) {
                id <JsonModelProtocol> modelProperty;
                
                Class modelClass = NSClassFromString(propertyInfo[constant_propertyClassName]);
                
                modelProperty = [[modelClass alloc]initWithDictionary:obj];
                
                [self setValue:modelProperty forKey:key];
            }
            else 
            {
                [self setValue:obj forKey:key];
            }
        }
        else
        {
            if (![key isEqualToString:@"primaryKey"]) {
                const char * modelName = class_getName([self class]);
                
                NSLog(@"赋值:%@-->出现多余数据 key:%@",[NSString stringWithUTF8String:modelName],key);
            }
        }
    }];
}

- (void)display
{
    const char * modelName = class_getName([self class]);
    
    NSLog(@"%@:%@",[NSString stringWithUTF8String:modelName],[self analysisModelDisplayContent]);
}
#pragma mark - coping delegate
- (id)copyWithZone:(nullable NSZone *)zone
{
    return [self copyMethodWithZone:zone];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [self copyMethodWithZone:zone];
}

- (id)copyMethodWithZone:(nullable NSZone *)zone
{
    id  copy = [[[self class] allocWithZone:zone] init];
    
    NSArray * properties = allPropertyNames(self);
    
    NSDictionary * propertyDic = [self toDictionary];
    
    for (NSString * key in properties) {
        [copy setValue:propertyDic[key] forKey:key];
    }
    
    return copy;
}

#pragma mark - private method
- (SEL)creatGetterWithPropertyName: (NSString *)propertyName{
    return NSSelectorFromString(propertyName);
}

/**
 *  重写原生设置key-value方法
 *
 *  @param keyedValues
 */
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    [self setPropertyWithDictionary:keyedValues];
}

#pragma mark - class method
+ (NSArray *)modelsWithDictionarys:(NSArray *)dicts
{
    if (isNull(dicts)) {
        return nil;
    }
    
    NSMutableArray * models = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary * dict in dicts) {
        
        id modelObj = [[[self class] alloc]initWithDictionary:dict];
        
        [models addObject:modelObj];
        
    }
    
    return models;
}

+ (NSArray *)dictionarysWithModels:(NSArray *)models convertKeys:(NSArray *)keys
{
    if (isNull(models)) {
        return nil;
    }
    
    NSMutableArray * dicts = [NSMutableArray arrayWithCapacity:models.count];
    
    for (id<JsonModelProtocol> modelObj in models) {
        
        NSDictionary * dict = isNull(keys) ? [modelObj toDictionary] : [modelObj toDictionaryWithKeys:keys];
        
        [dicts addObject:dict];
    }
    
    return dicts;
}
@end
