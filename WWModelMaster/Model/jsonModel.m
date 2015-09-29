//
//  jsonModel.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "jsonModel.h"
#import <objc/runtime.h>
@implementation jsonModel

#define WWErrorLog(errDsp) NSLog(@"method:%@ error -->%@",[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSASCIIStringEncoding],errDsp);
#define WWExceptionLog(expDsp) NSLog(@"method:%@ Exception -->%@",[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSASCIIStringEncoding],expDsp);

#pragma mark - AbstractJsonModelProtocol
-(instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        [self setPropertyWithDictionary:dictionary];
    }
    return self;
}

-(instancetype) initWithJsonString:(NSString *)string
{
    if (self = [super init]) {
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

-(instancetype) initWithData:(NSData *)data
{
    if (self = [super init]) {
        NSError * serialErr;
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];
        
        if(serialErr) {
            WWErrorLog(serialErr.description);
        }
        
        [self setPropertyWithDictionary:dic];
    }
    return self;
}

-(NSDictionary *) toDictionary
{
    return  [self dictionaryWithValuesForKeys:[self allPropertyNames]];
}

-(NSDictionary *) toDictionaryWithKeys:(NSArray *)propertyNames
{
    
    NSMutableArray * keysArr = [[NSMutableArray alloc]initWithArray:propertyNames copyItems:YES];
    NSMutableArray * shouldDelKey = [[NSMutableArray alloc]init];
    NSArray * properties = [self allPropertyNames];
    for (NSString * key in keysArr) {
        if (![properties containsObject:key]) {
            NSString * expDsp = [NSString stringWithFormat:@"传入了错误的key:%@",key];
            WWExceptionLog(expDsp);
            [shouldDelKey addObject:key];
        }
    }
    
    //删除需要删除的key
    for (NSString * delKey in shouldDelKey) {
        [keysArr removeObject:delKey];
    }
    
    return [self dictionaryWithValuesForKeys:keysArr];
}

-(NSData *) toData
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

-(NSData *) toDataWithKeys:(NSArray *)propertyNames
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

-(NSString *) toJsonString
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

-(NSString *) toJsonStringWithKeys:(NSArray *)propertyNames
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

#pragma mark - public method
-(void) setPropertyWithDictionary:(NSDictionary *)data
{
    NSArray * properyNames = [self allPropertyNames];
    [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([properyNames containsObject:key]) {
            [self setValue:obj forKey:key];
        }
        else
        {
            const char * modelName = class_getName([self class]);
            
            BOOL isNSString =  [obj isMemberOfClass:[NSString class]];
            
            NSString * objStr =  isNSString ? obj : [obj stringValue];
            
            NSLog(@"赋值:%@-->出现多余数据 key:%@ value:%@",[NSString stringWithUTF8String:modelName],key,objStr);
        }
    }];
}

-(void) display
{
    NSArray * properties = [self allPropertyNames];
    NSMutableString * displayStr = [[NSMutableString alloc]initWithString:@"\n"];
    
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
            
            [displayStr appendFormat:@"%@-->%@\n",properties[i],returnValue];
        }
    }
    const char * modelName = class_getName([self class]);
    
    NSLog(@"%@:%@",[NSString stringWithUTF8String:modelName],displayStr);
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

-(id) copyMethodWithZone:(nullable NSZone *)zone
{
    id  copy = [[[self class] allocWithZone:zone] init];
    
    NSArray * properties = [self allPropertyNames];
    
    NSDictionary * propertyDic = [self toDictionary];
    
    for (NSString * key in properties) {
        [copy setValue:propertyDic[key] forKey:key];
    }
    
    return copy;
}

#pragma mark - private method
/**
 *  获取类的所有属性名称
 *
 *  @return
 */
-(NSArray *) allPropertyNames
{
    NSMutableArray * properties = [[NSMutableArray alloc]init];
    
    unsigned int propertyCount = 0;
    
    objc_property_t * propertiesTemp = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i<propertyCount; i++) {
        objc_property_t  property = propertiesTemp[i];
        
        const char * propertyName = property_getName(property);
        
        [properties addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    free(propertiesTemp);
    
    return properties;
}


- (SEL) creatGetterWithPropertyName: (NSString *) propertyName{
    return NSSelectorFromString(propertyName);
}

/**
 *  重写原生设置key-value方法
 *
 *  @param keyedValues
 */
-(void) setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    [self setPropertyWithDictionary:keyedValues];
}
@end
