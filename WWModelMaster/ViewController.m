//
//  ViewController.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "ViewController.h"
#import "contactPersonModel.h"
#import "modelAssociateDB.h"

#import "contactDetailCtl.h"
@interface ViewController ()

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mrak - table view delegate and data soruce
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    contactPersonModel * model = [_contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"名字: %@ 号码:%@ 地区:%@ 生日:%@",model.name,model.phone,model.city,[model birthdayStr]];
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_associate deleteModel:_contacts[indexPath.row]];
    [_contacts removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    contactDetailCtl * detail = [[contactDetailCtl alloc]init];
    detail.model = [_contacts objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark - getter
- (modelAssociateDB *)associate
{
    if (!_associate) {
        _associate = [[modelAssociateDB alloc]init];
    }
    return _associate;
}

#pragma mark - action

- (IBAction)addNewContact:(id)sender {
}

#pragma mark - private method

- (void) configData
{
    _contacts = [NSMutableArray array];
    
    [_contacts addObjectsFromArray:[self.associate selectAll:contactPersonModel.tableName]];
    
    //没有数据的情况,初始增加几个新的数据
    if (0 == _contacts.count) {
        NSDictionary * dcit1 = @{@"name":@"waiwai",@"phone":@"18888888888",@"city":@"nanjing",@"birthday":[NSDate date]};
    
        NSDictionary * dcit2 = @{@"name":@"huihui",@"phone":@"13666666666",@"city":@"beijing",@"birthday":[NSDate date]};
        
        NSArray * models = [contactPersonModel modelsWithDictionarys:@[dcit1,dcit2]];
        
        for (contactPersonModel * model in models) {
            [self.associate saveModel:model];
        }
        //
        [_contacts addObjectsFromArray:[self.associate selectAll:contactPersonModel.tableName]];
    }
}


@end
