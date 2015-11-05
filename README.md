# WWModelMaster
Model 提供了一个轻量级的model基类;支持多种数据格式;

WWDatabase 提供了数据库连接与sql执行的公共入口;

modelAssociateDB model对象使用sqlite持久化的操作;

use example:

##Ⅰ.WWModel安装
pod 'WWModel'

##Ⅱ.WWModel简介

#1.model使用

testModel继承自model;

NSDictionary * test = @{@"name":@"waiwai",@"age":@22,@"livePlace":@"中国南京",@"sex":@1};

testModel * model1 = [[testModel alloc]init];

[model1 setValuesForKeysWithDictionary:test];

[model1 display];

输出:
2015-09-29 17:05:09.573 WWModelMaster[3721:172393] 赋值:testModel-->出现多余数据 key:sex value:1

2015-09-29 17:05:09.574 WWModelMaster[3721:172393] testModel:

name-->waiwai
age-->22
livePlace-->中国南京

拥有完善的异常key检测机制

实现了model对象的NSCopying,NSMutableCopying;

提供多种转换方式;初始化方式;

/**
 *  根据dictionary初始化model
 *
 *  @param dictionary 设置参数字典,json结构;
 *
 *  @return model对象
 */
-(instancetype) initWithDictionary:(NSDictionary*)dictionary;

/**
 *  根据nsdata 初始化model
 *
 *  @param data json格式NSData
 *
 *  @return model对象
 */
-(instancetype) initWithData:(NSData*)data;

/**
 *  根据json String 初始化model
 *
 *  @param string json String
 *
 *  @return model对象
 */
-(instancetype) initWithJsonString:(NSString *)string;

/**
 *  model对象转字典
 *
 *  @return 结果NSDictionary
 */
-(NSDictionary*) toDictionary;

-(NSDictionary*) toDictionaryWithKeys:(NSArray*)propertyNames;

/**
 *  model对象转NSData
 *
 *  @return 结果NSData
 */
-(NSData *) toData;

-(NSData *) toDataWithKeys:(NSArray*)propertyNames;

/**
 *  model对象转json String
 *
 *  @return json格式NSString
 */
-(NSString *) toJsonString;

-(NSString *) toJsonStringWithKeys:(NSArray*)propertyNames;

同样具有完善的异常处理机制;

dictionarys 和 models 互相转换

NSDictionary * test = @{@"name":@"waiwai",@"age":@22,@"livePlace":@"中国南京"};

NSDictionary * test1 = @{@"name":@"huihui",@"age":@20,@"livePlace":@"中国南京"};
    
NSArray * models = [testModel modelsWithDictionarys:@[test,test1]];
    
NSDictionary * dicts = [testModel dictionarysWithModels:models convertKeys:@[@"name"]];

#2.WWDatabase 介绍

提供了WWDatabase,提供了数据库连接与sql执行的公共入口;

独立模块,可以单独使用WWDatabase来实现自己的更多需求数据库功能;

#3.modelAssociateDB 介绍

这里提供了model连接WWDatabase使用sqlite实现数据持久化的方案;

- (BOOL)saveModel:(id<JsonModelProtocol>) model;

- (BOOL)deleteModel:(id<JsonModelProtocol>) model;

- (BOOL)updateModel:(id<JsonModelProtocol>) newModel;

- (NSArray *)selectAll:(NSString *) tableName;

基本的增加,删除,更新,查询函数提供;

- (BOOL)deleteWithModelTable:(NSString *)tableName where:(NSDictionary *)where;

- (BOOL)updateWithModelTable:(NSString *) tableName Content:(NSDictionary *) updateContent where:(NSDictionary *) where;

- (NSArray *) selectWithModelTable:(NSString *) tableName where:(NSDictionary *) where groupBy:(NSString *) group;

- (id<JsonModelProtocol>)findWithModelTable:(NSString *) tableName  withPrimary:(NSUInteger) primary;

复杂的增加,删除,更新,查询函数提供

提供了使用示例;一个简单的通讯录应用;
