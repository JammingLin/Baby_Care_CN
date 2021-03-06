//
//  MilestoneController.m
//  BabyCalendar
//
//  Created by will on 14-5-30.
//  Copyright (c) 2014年 will. All rights reserved.
//

#import "MilestoneController.h"
#import "MilestoneView.h"
#import "AddMilestoneController.h"
#import "MilestoneModel.h"
#import "EditeView.h"
#import "AddIemView.h"
#import "MilestoneContentView.h"
#import "MilestoneHeaderView.h"
#import "ShareInfoView.h"
@interface MilestoneController ()<EditeViewDelegate,AddIemViewDelegate,MilestoneViewDelegate>
{
    MilestoneView* _milestoneView;
    
    AddIemView* _addItemView;
    EditeView*  _editeView;
//    BOOL _noneData;
}

@end

@implementation MilestoneController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"里程碑页面"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"里程碑页面"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"里程碑";
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customForTarget:self image:@"btn_add" title:nil action:@selector(addAction)];
    
    _addItemView = [[[NSBundle mainBundle] loadNibNamed:@"AddItemView" owner:self options:nil] lastObject];
    _addItemView.delegate = self;
    
    _editeView = [[[NSBundle mainBundle] loadNibNamed:@"EditeView" owner:self options:nil] lastObject];
    _editeView.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_addItemView];
    
    _milestoneView = [[MilestoneView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight-64)];
    _milestoneView.delegate = self;
    [self.view addSubview:_milestoneView];
    
    [self _initDatas];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_initDatas) name:kNotifi_milestone_initDatas object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (_noneData) {
//        _noneData = NO;
//        [self addAction];
//    }
    
}

- (void)_initDatas
{
    // 创建数据库
    [BaseSQL createTable_milestone];
    // 获取数据库数据
    NSArray* milestoneDatas_sql = [BaseSQL queryData_milestone];
    NSMutableArray* milestoneDatas = [NSMutableArray array];
    // 过滤获取已经完成的里程碑
    for (MilestoneModel* model in milestoneDatas_sql) {
        if ([model.completed boolValue]) {
            [milestoneDatas addObject:model];
        }
    }
    //是否有已完成的里程碑
    if (milestoneDatas.count == 0) {
//        _noneData = YES;
        _milestoneView.SQLDatas = nil;
    }else
    {
        _milestoneView.SQLDatas = milestoneDatas;
    }
    
    
}
- (void)addAction
{
    AddMilestoneController* addVc = [[AddMilestoneController alloc] init];
    [self.navigationController pushViewController:addVc animated:YES];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"下一页");
        [_milestoneView MilestoneHeaderView_right];

    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"上一页");
        [_milestoneView MilestoneHeaderView_left];
    }
    
}

#pragma mark - EditeViewDelegate

- (void)editeViewDidCancel
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_addItemView];
    _milestoneView.headerView.photoView.canTap = NO;
    _milestoneView.contentView.textView.editable = NO;
    _milestoneView.contentView.textfield.enabled = NO;
    _milestoneView.headerView.btnDate.enabled = NO;
    
    if (_milestoneView.SQLDatas.count > 0) {
        MilestoneModel* model = _milestoneView.SQLDatas[_milestoneView.index];
        _milestoneView.contentView.textView.text = model.content;
        _milestoneView.contentView.notetipsView.hidden = YES;
    }
}
- (void)editeViewDidDone
{
    if ([_milestoneView.contentView.textfield.text  isEqualToString:@""]) {
        [self alertView:kTitle_none];
        return;
    }
    
    if ([_milestoneView.contentView.textView.text isEqualToString:@""]) {
        [self alertView:kContent_none];
        return;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_addItemView];
    _milestoneView.headerView.photoView.canTap = NO;
    _milestoneView.contentView.textView.editable = NO;
    _milestoneView.contentView.textfield.enabled = NO;
    _milestoneView.headerView.btnDate.enabled = NO;
    
       // 更新数据
    if (_milestoneView.SQLDatas.count > 0) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* timeStr = [formatter stringFromDate:[NSDate date]];
        NSString *photoName = [NSString stringWithFormat:@"%@.jpg",timeStr];
        
        MilestoneModel* model = _milestoneView.SQLDatas[_milestoneView.index];
        model.content = _milestoneView.contentView.textView.text;

        NSString* old_photo = model.photo_path;
        model.photo_path    = photoName;
        model.title         = _milestoneView.contentView.textfield.text;
        model.date = _milestoneView.headerView.btnDate.titleLabel.text;
        
        [_milestoneView.SQLDatas replaceObjectAtIndex:_milestoneView.index withObject:model];
        
        // 更新数据库
        [BaseSQL updateData_milestone:model];
        
        NSLog(@"%@",photoName);
        
        // 保存新照片
        [BaseMethod saveNewPhoto:_milestoneView.headerView.photoView.image withPhotoName:photoName];
        
        // 删除旧照片
        [BaseMethod deleteOldPhoto:old_photo];

        
        // 刷新日历列表                        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifi_reload_SQLDatas object:nil];
        
        // 刷新日历
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifi_reload_calendarView object:nil];
    }
    
}

#pragma mark - AddIemViewDelegate

- (void)addIemViewDidEdite
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_editeView];
    
    _milestoneView.headerView.photoView.canTap = YES;
    _milestoneView.contentView.textView.editable = YES;
    MilestoneModel *model = [_milestoneView.SQLDatas objectAtIndex:_milestoneView.index];
    if ([model.month intValue] == 999) {
        _milestoneView.contentView.textfield.enabled = YES;
    }
    _milestoneView.headerView.btnDate.enabled = YES;
}

- (void)addIemViewDidAdd
{
    [self addAction];
}

#pragma mark - MilestonViewDelegate
- (void)ShareToFriend
{
    UIImage *detailImage = [ACFunction cutView:self.view andWidth:kShareImageWidth_Milestone andHeight:kDeviceHeight-64];
    ShareInfoView *shareView = [[[NSBundle mainBundle] loadNibNamed:@"ShareInfoView" owner:self options:nil] lastObject];
    [shareView.shareInfoImageView setFrame:CGRectMake((320-217)/2.0, shareView.shareInfoImageView.origin.y, 217, (kDeviceHeight-64)*217/320.0)];
    [shareView.shareInfoImageView setImage:detailImage];
    shareView.titleDetail.text = [NSString stringWithFormat:kShareMilestoneTitle,[BabyinfoViewController getbabyname],[BabyinfoViewController getbabyage],_milestoneView.contentView.textfield.text];;
    UIImage *shareimage = [ACFunction cutView:shareView andWidth:shareView.width andHeight:kDeviceHeight];
    [ACShare shareImage:self andshareTitle:shareView.titleDetail.text andshareImage:shareimage anddelegate:self];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
