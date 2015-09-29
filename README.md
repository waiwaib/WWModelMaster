# WWModelMaster
提供了一个轻量级的model基类;

use example:

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

未完待续...更多内容即将到来
