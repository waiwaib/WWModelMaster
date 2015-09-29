//
//  ViewController.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "ViewController.h"
#import "testModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary * test = @{@"name":@"waiwai",@"age":@22,@"livePlace":@"中国南京",@"sex":@1};
    testModel * model1 = [[testModel alloc]init];
    [model1 setValuesForKeysWithDictionary:test];
    
    [model1 setPropertyWithDictionary:test];

    [model1 display];
    
    NSDictionary * modelDic = [model1 toDictionary];
    
    NSString * str =  [model1 toJsonString];
    
    NSData * data = [model1 toData];
    
    
    testModel * model2 = [[testModel alloc]initWithDictionary:test];
    //[model2 displayModleProperty];
    
    NSString * jsonStr = @"{\"name\":\"huihui\",\"age\":23,\"livePlace\":\"中国南京\"}";
    testModel * model3 = [[testModel alloc]initWithJsonString:jsonStr];
    //[model3 displayModleProperty];
    
    testModel * model4 = [[testModel alloc]initWithData:data];
    //[model4 displayModleProperty];
    
    NSDictionary * dic = [model4 toDictionaryWithKeys:@[@"name",@"age",@"live"]];
    
    NSString * tojsonStr = [model4 toJsonStringWithKeys:@[@"nae",@"ge",@"live"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
