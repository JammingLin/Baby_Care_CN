//
//  HomeViewController.m
//  Parenting
//
//  Created by 家明 on 13-5-17.
//  Copyright (c) 2013年 家明. All rights reserved.
//

#import "HomeViewController.h"
#import "playViewController.h"
#import "SummaryViewController.h"
#import "OpenFunction.h"
@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize lm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //    [self.tabBarController.tabBarItem setImage:[UIImage imageNamed:@"menu1.png"]];
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

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

-(void)viewWillAppear:(BOOL)animated
{
    isFound = YES;
    
    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [self LoadData];
    if (birth != nil) {
        [birth setText:[BabyinfoViewController getbabyage]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"timerOn"]) {
        timer=[NSTimer scheduledTimerWithTimeInterval:1
                                               target:self selector:@selector(timerGo) userInfo:nil repeats:YES];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"babyimage"]==nil) {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"photo" ofType:@"png"];
        NSData *imagedata=[NSData dataWithContentsOfFile:path];
        [imagedata writeToFile:PHOTOPATH atomically:NO];
        [[NSUserDefaults standardUserDefaults] setObject:PHOTOPATH
                                                  forKey:@"babyimage"];
        ;
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"name"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"Baby's Name" forKey:@"name"];
        
        
        BabyinfoViewController *bi=[[BabyinfoViewController alloc]initWithNibName:@"BabyinfoViewController" bundle:nil];
        [self.navigationController pushViewController:bi animated:YES];
        
        
        
    }
    //self.navigationItem.title=[[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    
    if (titleView == nil) {
        titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 240, 40)];
        titleView.backgroundColor=[UIColor clearColor];
        titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
        titleText.backgroundColor = [UIColor clearColor];
        [titleText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
        titleText.textColor = [UIColor whiteColor];
        [titleText setTextAlignment:NSTextAlignmentCenter];
        [titleView addSubview:titleText];
    }
    [titleText setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]];
    self.navigationItem.titleView = titleView;
    
    //cwb-添加蓝牙同步按钮
    buttonSyncBLE=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonSyncBLE.frame=CGRectMake(265, 28, 43, 28);
    [buttonSyncBLE setBackgroundImage:[UIImage imageNamed:@"btn_syncBLE.png"]  forState:UIControlStateNormal];
    [buttonSyncBLE addTarget:self action:@selector(connectBLEController) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *backbar=[[UIBarButtonItem alloc]initWithCustomView:buttonSyncBLE];
    //    self.navigationItem.rightBarButtonItem=backbar;
    [self.navigationController.view addSubview:buttonSyncBLE];
    
    
    
    babyImage.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:PHOTOPATH]];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MARK"];
    
    NSDate *startdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"userstartuserdate"];
    int startweek = [currentdate getEarlyWeek:startdate];
    //NSLog(@"home %@,%d",startdate,startweek);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userreviews"] isEqualToString:@"none"] && startweek < [currentdate getCurrentWeek]) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"reviewstitle", nil),appName]
                                                            message:NSLocalizedString(@"reviewsmsg", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"reviewscancel", nil),NSLocalizedString(@"reviewsok", nil),nil];
        [alertView show];
        
    }
    
    
}
-(void)LoadData
{
    DataBase *db=[DataBase dataBase];
    dataArray=[db selectAll];
    [datatable reloadData];
    [actionArray removeAllObjects];
    [actionArray addObject:[db selectFromdiaper]];
    [actionArray addObject:[db selectFromfeed]];
    [actionArray addObject:[db selectFromsleep]];
    [actionArray addObject:[db selectFrombath]];
    [actionArray addObject:[db selectFromplay]];
    
    [actionTable reloadData];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    [buttonSyncBLE removeFromSuperview];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

-(void)setting
{
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_title.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [datatable setFrame:CGRectMake(6, 142+G_YADDONVERSION, 120, 332)];
    //[actionTable setFrame:CGRectMake(120, 206, 200, 332)];
    
    [self setting];
    
    
    //    actionTable.bounces=NO;
    
    [self.view addSubview:actionTable];
    
    actionArray=[[NSMutableArray alloc]initWithCapacity:0];
    datatable.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview:datatable];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIImage *diaperimage=[UIImage imageNamed:@"icon_diaper.png"];
    UIImage *feedimage=[UIImage imageNamed:@"icon_feed.png"];
    UIImage *sleepimage=[UIImage imageNamed:@"icon_sleep.png"];
    UIImage *bathimage=[UIImage imageNamed:@"icon_bath.png"];
    UIImage *playimage=[UIImage imageNamed:@"icon_play.png"];
    
    iconarray=[NSArray arrayWithObjects:diaperimage,feedimage,sleepimage,bathimage,playimage, nil];
    
    [self makeBabyInfo];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"justdoit"];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"receiveresponse%@",response);
    [webData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *xmlstring=[[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"xml=%@",xmlstring);
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error%@",error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==actionTable) {
        return 5;
    }
    else
    {
        if (dataArray.count>12) {
            return 12;
        }
        return dataArray.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView==actionTable) {
        return 1;
    }
    else
    {
        if (section>=dataArray.count-1||section>=11) {
            return 1;
        }
        else
        {
            return 2;
        }
    }
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == actionTable) {
        UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"Action"];
        if (Cell==nil) {
            Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Action"];
            [Cell setBackgroundColor:[UIColor clearColor]];
            Cell.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_list_item.png"]];
            Cell.selectedBackgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_list_item_focus.png"]];
            Cell.textLabel.bounds=CGRectMake(0, 0, 100, 30);
            Cell.textLabel.textColor=[UIColor colorWithRed:0x6D/255.0 green:0x68/255.0 blue:0x60/255.0 alpha:0xFF/255.0];/* 6D6860FF */
            Cell.textLabel.backgroundColor = [UIColor clearColor];
            Cell.textLabel.font=[UIFont systemFontOfSize:14];
        }
        
        if ( !([[actionArray objectAtIndex:indexPath.section] isEqualToString:@"NULL"] || [[actionArray objectAtIndex:indexPath.section] isEqual:[NSNull null]])) {
            Cell.textLabel.text= [NSString stringWithFormat:@"  %@",[actionArray objectAtIndex:indexPath.section]];
        }
        else{
            Cell.textLabel.text=@"";
        }
        Cell.imageView.image=[iconarray objectAtIndex:indexPath.section];
        return Cell;
        
    }
    else
    {
        UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"History"];
        if (Cell==nil) {
            Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"History"];
            Cell.backgroundColor=[UIColor clearColor];
            Cell.imageView.image=[UIImage imageNamed:@"bg_circle_process.png"];
            Cell.selectionStyle=UITableViewCellSelectionStyleNone;
            Cell.textLabel.textColor=[UIColor colorWithRed:0xB3/255.0 green:0xB3/255.0 blue:0xB3/255.0 alpha:0xFF/255.0];
            [Cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
            UIButton *button=[UIButton  buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(0, 0, 45, 45);
            [button setBackgroundImage:[UIImage imageNamed:@"bg_circle_process.png"] forState:UIControlStateNormal];
            [Cell.contentView addSubview:button];
            button.tag=100001;
            [button setImageEdgeInsets:UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5)];
            button.enabled=NO;
            
            UIButton *buttonarrow=[UIButton buttonWithType:UIButtonTypeCustom];
            buttonarrow.center=CGPointMake(button.center.x, 8.5);
            buttonarrow.bounds=CGRectMake(0, 0, 13, 17);
            [buttonarrow setBackgroundImage:[UIImage imageNamed:@"bg_arrow_process.png"] forState:UIControlStateDisabled];
            buttonarrow.enabled=NO;
            buttonarrow.tag=100002;
            [Cell.contentView addSubview:buttonarrow];
            
        }
        
        //        if (indexPath.row==0) {
        //            [Cell setNeedsDisplay];
        //            UIButton *button=(UIButton*)[Cell.contentView viewWithTag:100001];
        //            UIButton *buttonarrow=(UIButton*)[Cell.contentView viewWithTag:100002];
        //            buttonarrow.hidden=YES;
        //            Cell.imageView.hidden=NO;
        //            button.contentMode=UIViewContentModeScaleAspectFit;
        //
        //            ActivityItem *item=[dataArray objectAtIndex:indexPath.section];
        //            if ([item.type isEqualToString:@"Feed"]) {
        //                [button setImage:[UIImage imageNamed:@"process_feed.png"] forState:UIControlStateDisabled];
        //            }
        //            else if([item.type isEqualToString:@"Diaper"])
        //            {
        //                [button setImage:[UIImage imageNamed:@"process_diaper.png"] forState:UIControlStateDisabled];
        //
        //            }
        //            else if([item.type isEqualToString:@"Pleep"])
        //            {
        //                [button setImage:[UIImage imageNamed:@"process_sleep.png"] forState:UIControlStateDisabled];
        //            }
        //            else if([item.type isEqualToString:@"Play"])
        //            {
        //                [button setImage:[UIImage imageNamed:@"process_play.png"] forState:UIControlStateDisabled];
        //            }
        //            else
        //            {
        //                [button setImage:[UIImage imageNamed:@"process_bath.png"] forState:UIControlStateDisabled];
        //            }
        //            NSDateFormatter *formater=[[NSDateFormatter alloc]init];
        //            [formater setDateFormat:@"HH:mm"];
        //            [currentdate getStarttimefromdate:item.starttime];
        //            [button setHidden:NO];
        //            [Cell.contentView bringSubviewToFront:button];
        //            Cell.textLabel.text=[formater stringFromDate:item.starttime];
        //        }
        //        else
        //        {
        //            [Cell setNeedsDisplay];
        //            Cell.imageView.hidden=YES;
        //            Cell.textLabel.text=@"";
        //            [[Cell.contentView viewWithTag:100001] setHidden:YES];
        //            UIButton *buttonarrow=(UIButton*)[Cell.contentView viewWithTag:100002];
        //            buttonarrow.hidden=NO;
        //
        //        }
        //
        //
        //        return Cell;
        if(indexPath.row==0)
        {
            UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"History"];
            if (Cell==nil) {
                Cell=[[[NSBundle mainBundle] loadNibNamed:@"DataCustomCell" owner:self options:nil] objectAtIndex:0];
            }
            UIButton *button=(UIButton*)[Cell viewWithTag:100001];
            UILabel *lable=(UILabel*)[Cell viewWithTag:200001];
            button.contentMode=UIViewContentModeScaleAspectFit;
            
            ActivityItem *item=[dataArray objectAtIndex:indexPath.section];
            if ([item.type isEqualToString:@"Feed"]) {
                [button setImage:[UIImage imageNamed:@"process_feed.png"] forState:UIControlStateDisabled];
            }
            else if([item.type isEqualToString:@"Diaper"])
            {
                [button setImage:[UIImage imageNamed:@"process_diaper.png"] forState:UIControlStateDisabled];
                
            }
            else if([item.type isEqualToString:@"Sleep"])
            {
                [button setImage:[UIImage imageNamed:@"process_sleep.png"] forState:UIControlStateDisabled];
            }
            else if([item.type isEqualToString:@"Play"])
            {
                [button setImage:[UIImage imageNamed:@"process_play.png"] forState:UIControlStateDisabled];
            }
            else
            {
                [button setImage:[UIImage imageNamed:@"process_bath.png"] forState:UIControlStateDisabled];
            }
            NSDateFormatter *formater=[[NSDateFormatter alloc]init];
            [formater setDateFormat:@"HH:mm"];
            [currentdate getStarttimefromdate:item.starttime];
            [Cell.contentView bringSubviewToFront:button];
            lable.text=[formater stringFromDate:item.starttime];
            return Cell;
        }
        else
        {
            UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"History1"];
            if (Cell==nil) {
                Cell=[[[NSBundle mainBundle] loadNibNamed:@"DataCustomCell" owner:self options:nil] objectAtIndex:1];
            }
            return Cell;
            
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"alertView %d", buttonIndex);
    if (buttonIndex == 1) {
        [OpenFunction openUserReviews];
        [[NSUserDefaults standardUserDefaults] setObject:@"yesido" forKey:@"userreviews"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[currentdate date] forKey:@"userstartuserdate"];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==actionTable) {
        if ([UIScreen mainScreen].bounds.size.height==568) {
            return 10;
        }
        else
        {
            return 2;
        }
        
    }
    else return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView==actionTable) {
        if ([UIScreen mainScreen].bounds.size.height==568) {
            return 10;
        }
        else
        {
            return 2;
        }
        
    }
    else
    {
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==actionTable) {
        return 38;
    }
    else
    {
        if (indexPath.row==0) {
            return 45;
        }
        else
        {
            return 17;
        }
        
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==actionTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self gotoActivity:indexPath.section];
    }
    else
    {
        //        ActivityItem *item=[dataArray objectAtIndex:indexPath.section];
        //        [self showHistory:item];
    }
}
-(void)hitHistoryButton:(UIButton*)sender
{
    //    ActivityItem *item=[dataArray objectAtIndex:sender.tag];
    //    [self showHistory:item];
}
-(void)showHistory:(ActivityItem*)item
{
    if ([item.type isEqualToString:@"feed"]) {
        
        save_feedview *feed=[[save_feedview alloc]initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 460-44-49) Select:YES Start:item.starttime Duration:item.description];
        
        [self.view addSubview:feed];
    }
    else if ([item.type isEqualToString:@"sleep"])
    {
        save_sleepview *sleep=[[save_sleepview alloc] initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 460-44-49) Select:YES Start:item.starttime Duration:item.description];
        [self.view addSubview:sleep];
    }
    else if ([item.type isEqualToString:@"play"])
    {
        save_playview *sleep=[[save_playview alloc] initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 460-44-49) Select:YES Start:item.starttime Duration:item.description];
        [self.view addSubview:sleep];
    }
    else if ([item.type isEqualToString:@"bath"])
    {
        save_bathview  *sleep=[[save_bathview alloc] initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 460-44-49) Select:YES Start:item.starttime Duration:item.description];
        [self.view addSubview:sleep];
    }
    else
    {
        save_diaperview *diaper=[[save_diaperview alloc]initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 460-44-49) Select:YES Start:item.starttime];
        [self.view addSubview:diaper];
    }
    
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (tableView==actionTable) {
//        return nil;
//    }
//    else
//    {
//
//
//        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame=CGRectMake(0, 0, 110, 17);
//        [button setImage:[UIImage imageNamed:@"bg_arrow_process.png"] forState:UIControlStateNormal];
//        button.enabled=NO;
//        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 87)];
//        return button;
//
//    }
//}

-(void)gotoActivity:(int)sender
{
    NSString *str = @"1";
    NSUserDefaults *db = [NSUserDefaults standardUserDefaults];
    [db setObject:str forKey:@"MARK"];
    [db synchronize];
    UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:1];
    switch (sender) {
        case 1:
        {
            feedViewController *feed=[feedViewController shareViewController];
            feed.summary = [nav.viewControllers lastObject];
            [self.navigationController pushViewController:feed animated:YES];
        }
            break;
        case 0:
        {
            diaperViewController *diaper=[diaperViewController shareViewController];
            diaper.summary = [nav.viewControllers lastObject];
            [self.navigationController pushViewController:diaper animated:YES];
        }break;
        case 2:
        {
            sleepViewController *sleep=[sleepViewController shareViewController];
            sleep.summary = [nav.viewControllers lastObject];
            [self.navigationController pushViewController:sleep animated:YES];
        }break;
        case 4:
        {
            playViewController *play=[playViewController shareViewController];
            play.summary = [nav.viewControllers lastObject];
            [self.navigationController pushViewController:play animated:YES];
        }break;
        case 3:
        {
            bathViewController *bath=[bathViewController shareViewController];
            bath.summary = [nav.viewControllers lastObject];
            [self.navigationController pushViewController:bath animated:YES];
        }break;
            
        default:
            break;
    }
    
}


-(void)timerGo
{
    
    NSIndexPath *index= [self getindexpath:[[NSUserDefaults standardUserDefaults] objectForKey:@"ctl"]];
    [actionArray replaceObjectAtIndex:index.section withObject:[currentdate durationFormat]];
    [actionTable reloadData];
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"ctl"]);
}


-(NSIndexPath *)getindexpath:(NSString *)sender
{
    int section;
    if ([sender isEqualToString:@"feed"]) {
        section=1;
    }
    else if([sender isEqualToString:@"diaper"])
    {
        section=0;
    }
    else if([sender isEqualToString:@"sleep"])
    {
        section=2;
    }
    else if([sender isEqualToString:@"play"])
    {
        section=4;
    }
    else
    {
        section=3;
    }
    NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:section];
    return index;
    
}

-(void)makeBabyInfo
{
    babyImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, G_YADDONVERSION, 320, 135)];
    babyImage.userInteractionEnabled=YES;
    babyImage.contentMode = UIViewContentModeScaleAspectFill;
    babyImage.clipsToBounds = YES;
    
    
    [self.view addSubview:babyImage];
    UITapGestureRecognizer *tapgesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ActionSheetShow)];
    [babyImage addGestureRecognizer:tapgesture];
    imagePicker=[[UIImagePickerController alloc]init];
    
    birth = [[UILabel alloc] initWithFrame:CGRectMake(90, babyImage.frame.size.height-30, 180, 22)];
    [birth setBackgroundColor:[UIColor clearColor]];
    [birth setTextColor:[UIColor whiteColor]];
    [birth setTextAlignment:NSTextAlignmentRight];
    [birth setAlpha:0.9];
    [birth setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    [birth setText:[BabyinfoViewController getbabyage]];
    [babyImage addSubview:birth];
    
    camera=[UIButton buttonWithType:UIButtonTypeCustom];
    camera.frame=CGRectMake(280, babyImage.frame.size.height-30, 30, 22);
    [camera setBackgroundImage:[UIImage imageNamed:@"btn_cam.png"] forState:UIControlStateNormal];
    [camera setBackgroundImage:[UIImage imageNamed:@"btn_cam_focus.png"] forState:UIControlStateHighlighted];
    
    [babyImage addSubview:camera];
    
    [camera addTarget:self action:@selector(ActionSheetShow) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)imageSelectFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing=YES;
        imagePicker.delegate=self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"相机不可用" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)imageSelect
{
    NSLog(@"imageselect");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:NO completion:nil];
    }
    else
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"相册不可用" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)ActionSheetShow
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancle",nil) destructiveButtonTitle:NSLocalizedString(@"Camera",nil) otherButtonTitles:NSLocalizedString(@"Photo",nil), nil];
    
    [action showFromTabBar:self.tabBarController.tabBar];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==[actionSheet destructiveButtonIndex]) {
        [self imageSelectFromCamera];
    }
    else if (buttonIndex==1)
    {
        [self imageSelect];
    }
    else
    {
        [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"];
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        NSLog(@"camare");
    }
    
    NSData *imagedata=UIImagePNGRepresentation(image);
    [imagedata writeToFile:PHOTOPATH atomically:NO];
    [babyImage setImage:image];
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    // Save the image to the album
    
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    if (error == nil)
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"This picture has been saved to your photo album" delegate:nil cancelButtonTitle:@"OK." otherButtonTitles:nil];
        [alert show];
        
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please try it again later.Saving Failed" delegate:nil cancelButtonTitle:@"OK." otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateBabyinfo
{
    babyImage.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:PHOTOPATH]];
    //   UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];//allocate titleView
    //    titleView.backgroundColor=[UIColor clearColor];
    //    //Create UILable
    //    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(100, 0, 50, 20)];//allocate titleText
    //    titleText.backgroundColor = [UIColor clearColor];
    //    titleText.textColor = [UIColor whiteColor];
    //    [titleText setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]];
    //    [titleView addSubview:titleText];
    //
    //    self.navigationItem.titleView = titleView;
    //    self.title=[[NSUserDefaults standardUserDefaults]     objectForKey:@"name"];
}

#pragma cwb:
-(void)connectBLEController{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_COM"] != nil) {
        //已绑定过设备,进行数据同步
        bleController = [[BLEController alloc]init];
        bleController.bleControllerDelegate = self;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeGo) userInfo:nil repeats:YES];
        isTimeOut=NO;
        [bleController startscan];
        buttonSyncBLE.enabled=NO;
    }else{
        //未绑定设备，提示并跳入绑定设备页面
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"转到引导介绍图或跳入绑定界面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)scanResult:(BOOL)result with:(NSMutableArray  *)foundPeripherals{
    if (!result) {
        isTimeOut=YES;
    }
    else {
        //Peripherals的名字跟配件名字匹配 如果不匹配还是提示错误
        if (isFound) {
            NSString *sysPeripheralsName =[[NSUserDefaults standardUserDefaults] objectForKey:@"BLE_COM"];
            if ([sysPeripheralsName isEqualToString:[[foundPeripherals objectAtIndex:0] name]])
            {
                //同步数据
                [bleController bleconnect];
            }else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"同步失败,请确定\n①手机蓝牙已开启\n②配件已开启并在手机附近" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
            isFound = NO;
            [bleController stopscan];
        }
    }
}

#pragma protocol
-(void)DidConnected:(BOOL)isConnected
{
    if (isConnected) {
        [bleController getPressKeyHistory:1];
    }
}

-(void)RecvDataFinish:(BOOL)isFinished{
    buttonSyncBLE.enabled=YES;
    isFound=YES;
    [bleController bledisconnect];
    
    //重新加载数据
    [self LoadData];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"同步完成!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void)timeGo
{
    if (isTimeOut && isFound) {
        //连接失败,提醒距离
        [bleController stopscan];
        [timer invalidate];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"同步失败,请确定\n①手机蓝牙已开启\n②配件已开启并在手机附近" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        isFound = NO;
    }
}

@end
