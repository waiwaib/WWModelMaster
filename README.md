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
