//
//  valueTransform.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/9.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern NSString * const constant_propertyClassName;
extern NSString * const constant_propertyType;

//常用的属性类型
typedef NS_ENUM(NSInteger, propertyType){
    /**
     *  未收录的属性类型
     */
    propertyTypeUnkown = 0,
    /**
     *  字符串类型
     */
    propertyTypeString = 1,
    /**
     *  NSNumber类型
     */
    propertyTypeNumber = 2,
    /**
     *  字典类型
     */
    propertyTypeDictionary = 3,
    /**
     *  数组类型
     */
    propertyTypeArrray = 4,
    /**
     *  NSSet类型
     */
    propertyTypeNSSet = 5,
    /**
     *  BOOL类型
     */
    propertyTypeBool = 6,
    /**
     *  int类型
     */
    propertyTypeInt = 7,
    /**
     *  Date类型
     */
    propertyTypeDate = 8,
    /**
     *  Model类型
     */
    propertyTypeModel = 9
};



/**
 *  this class is design for model propery value checking or transform;
 */
@interface valueTransform : NSObject

/**
 *  获取属性的描叙信息
 *
 *  @param property property属性
 *
 *  @return 结果描叙字典包括属性的类别和类名称
 */
+ (NSDictionary *)propertyInfoFromProperty:(objc_property_t)property;

/**
 *  获取属性的display字符串
 *
 *  @param property
 *  @param value
 *
 *  @return display字串
 */
+ (NSString *)propertyDisplayFromProperty:(objc_property_t)property value:(id)value;
/****************	全局函数	****************/

/**
 *  检测对象是否为空
 *
 *  @return
 */
extern BOOL isNull(id value);

/**
 *  获取对象的所有属性名称
 *
 *  @return
 */
extern NSArray * allPropertyNames(id object);

/**
 *  获取对象的所有属性值
 *
 *  @return
 */
extern NSArray * allPropertyValues(id object);
@end
