    //
//  MyDevicesTableViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-12-16.
//  Copyright (c) 2013年 爱摩科技有限公司. All rights reserved.
//

#import "MyDevicesTableViewController.h"
#import "MyDevicesTableCell.h"
#import "BindingDeviceViewController.h"

@interface MyDevicesTableViewController ()

@end

@implementation MyDevicesTableViewController
@synthesize tableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 200, 20)];
        titleView.backgroundColor=[UIColor clearColor];
        UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        titleText.backgroundColor = [UIColor clearColor];
        [titleText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
        titleText.textColor = [UIColor whiteColor];
        [titleText setTextAlignment:NSTextAlignmentCenter];
        [titleText setText:NSLocalizedString(@"My Devices", nil)];
        [titleView addSubview:titleText];
        
        [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
        self.navigationItem.titleView = titleView;
        //self.title  = NSLocalizedString(@"Baby information",nil ) ;
        self.hidesBottomBarWhenPushed=YES;
        //self.automaticallyAdjustsScrollViewInsets = NO;
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ( IOS7_OR_LATER )
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidAppear:(BOOL)animated{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataInitialize];
    
    tableView= [[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
}

-(void)dataInitialize{
    //处理已绑定设备
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_COM"] != nil) {
        arrMyDevices = [[NSArray alloc] initWithObjects:@"移动记录设备", nil];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_ENV"] != nil) {
        NSArray *peripheral2 = [[NSArray alloc] initWithObjects:@"环境记录设备", nil];
        arrMyDevices = [arrMyDevices arrayByAddingObject:peripheral2];
    }
    
    arrAdd = [[NSArray alloc] initWithObjects:@"绑定配件",nil];
    if (arrMyDevices == nil) {
        arrData = [[NSMutableArray alloc]initWithObjects:arrAdd, nil];
    }
    else{
        arrData = [[NSMutableArray alloc] initWithObjects:arrMyDevices, arrAdd, nil];
    }
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[arrData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)ctableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDevicesTableCell *cell = (MyDevicesTableCell*) [tableView dequeueReusableCellWithIdentifier:@"MyDevicesTableCell"];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyDevicesTableCell" owner:[MyDevicesTableCell class] options:nil];
        cell = (MyDevicesTableCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        if (indexPath.section == 1) {
            //            此处添加硬件设备外观图 & 是否已连接标示
            //            cell.imageView.image = [UIImage imageNamed:@"icon_connected"];
            cell.imageViewRight.image = [UIImage imageNamed:@"temp_icon_ADD.png"];
            cell.labelTitle.center = CGPointMake(20, 20);
            cell.labelTitle.text = @"绑定配件";
            //48 13
        }
        else{
            //cell.imageViewLeft.image = [UIImage imageNamed:@"temp_icon_ADD.png"];
            cell.labelTitle.center = CGPointMake(48, 13);
            cell.labelTitle.text = [[arrData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

        }
    }
    return cell;
}

- (void)tableView:(UITableView *)ctableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ctableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == [arrData count] - 2) {
        //进入配件编辑页面
    }
    else if (indexPath.section == [arrData count] - 1)
    {
        //进入配件绑定搜寻页面
        BindingDeviceViewController *binding = [[BindingDeviceViewController alloc] init];
        [self.navigationController pushViewController:binding animated:YES];
    }
    
}



@end
