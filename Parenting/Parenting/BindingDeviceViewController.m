//
//  BindingDeviceViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-12-17.
//  Copyright (c) 2013年 爱摩科技有限公司. All rights reserved.
//

#import "BindingDeviceViewController.h"
#import "LookingForDeviceViewController.h"

@interface BindingDeviceViewController ()

@end

@implementation BindingDeviceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self dataInitialize];
    
    _deviceTableView= [[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    _deviceTableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
}

-(void)dataInitialize{
    NSArray *peripheral1 = [[NSArray alloc] initWithObjects:@"移动记录设备", nil];
    arrayData = [[NSMutableArray alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_COM"] == nil) {
        [arrayData addObject:peripheral1];
    }

    NSArray *peripheral2 = [[NSArray alloc] initWithObjects:@"环境检测设备", nil];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_ENV"] == nil) {
        [arrayData addObject:peripheral2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrayData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[arrayData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //制作可重復利用的表格栏位Cell
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font=[UIFont systemFontOfSize:17];
        cell.textLabel.textColor=[UIColor blueColor];
        
        cell.imageView.image = [UIImage imageNamed:@"icon_connected"];//此处添加硬件设备外观图
    }
    
    
    //设定栏位的内容与类型
    cell.textLabel.text = [[arrayData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //设备类型:1-生理环境记录设备  2-环境信息采集设备
    LookingForDeviceViewController *looking = [[LookingForDeviceViewController alloc] init];
    looking.deviceId = indexPath.section;
    [self.navigationController pushViewController:looking animated:YES];
}

@end
