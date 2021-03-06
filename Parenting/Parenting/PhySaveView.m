//
//  PhySaveView.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-8-14.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import "PhySaveView.h"
#import "BaseMethod.h"

@implementation PhySaveView

- (id)initWithFrame:(CGRect)frame Type:(int)type OpType:(NSString *)operateType CreateTime:(long)create_time
{
    self = [super initWithFrame:frame];
    if (self) {
        itemType = type;
        switch (itemType) {
            case 0:
                itemName = @"身高";
                itemUnit = @"CM";
                break;
            case 1:
                itemName = @"体重";
                itemUnit = @"KG";
                break;
            case 3:
                itemName = @"头围";
                itemUnit = @"CM";
                break;
            default:
                break;
        }

        opType = operateType;
        [self initView];
        if ([opType isEqual:@"UPDATE"]) {
            createTime = create_time;
            [self initData];
        }
    }
    return self;
}

-(void)initView{
    //标题
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(0, 5,290, 30)];
    title.text = [NSString stringWithFormat:@"%@详情",itemName];
    title.textAlignment=NSTextAlignmentCenter;
    title.backgroundColor=[UIColor clearColor];
    title.textColor=[UIColor grayColor];
    
    //记录日期
    UILabel *labelRecordDate = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 100, 30)];
    labelRecordDate.textAlignment = NSTextAlignmentRight;
    labelRecordDate.backgroundColor = [UIColor clearColor];
    labelRecordDate.textColor= [UIColor grayColor];
    labelRecordDate.text = @"记录时间:";
    
    textRecordDate=[[UITextField alloc]initWithFrame:CGRectMake(115, 40, 150, 30)];
    textRecordDate.textColor=[UIColor grayColor];
    textRecordDate.delegate = self;
    [textRecordDate setBackground:[UIImage imageNamed:@"save_text.png"]];
    
    //数值
    UILabel *labelValue = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 100, 30)];
    labelValue.textAlignment = NSTextAlignmentRight;
    labelValue.backgroundColor = [UIColor clearColor];
    labelValue.textColor=[UIColor grayColor];
    labelValue.text = [NSString stringWithFormat:@"记录%@:",itemName];
    
    textValue=[[UITextField alloc]initWithFrame:CGRectMake(115, 80, 150, 30)];
    textValue.textColor=[UIColor grayColor];
    textValue.delegate = self;
    textValue.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textValue setValue:[NSNumber numberWithInt:15] forKey:@"paddingLeft"];
    [textValue setBackground:[UIImage imageNamed:@"save_text.png"]];
    
    //单位
    labelUnit = [[UILabel alloc] initWithFrame:CGRectMake(170, 82, 36, 24)];
    labelUnit.textColor = [UIColor grayColor];
    labelUnit.font = [UIFont fontWithName:@"Arial" size:MIDTEXT];
    labelUnit.text = itemUnit;
    
    //saveButton
    buttonSave = [[UIButton alloc]initWithFrame:CGRectMake(42, 123, 94, 28)];
    [buttonSave setBackgroundColor:[ACFunction colorWithHexString:@"0x68bfcc"]];
    buttonSave.layer.cornerRadius = 5.0f;
    [buttonSave setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [buttonSave addTarget:self action:@selector(saveRecord) forControlEvents:UIControlEventTouchUpInside];
    //cancelButton
    buttonCancel = [[UIButton alloc]initWithFrame:CGRectMake(152, 123, 94, 28)];
    [buttonCancel setBackgroundColor:[ACFunction colorWithHexString:@"0x68bfcc"]];
    buttonCancel.layer.cornerRadius = 5.0f;
    [buttonCancel setTitle:NSLocalizedString(@"Cancle",nil) forState:UIControlStateNormal];
    [buttonCancel addTarget:self action:@selector(cancelSave) forControlEvents:UIControlEventTouchUpInside];
    
    //设置imageView
    imageview=[[UIImageView alloc]init];
    imageview.bounds=CGRectMake(0, 0, 290, 160);
    imageview.center=CGPointMake(160, (460-44-49)/2 - 20);
    imageview.backgroundColor=[UIColor clearColor];
    imageview.userInteractionEnabled=YES;
    imageview.image=[UIImage imageNamed:@"save_bg.png"];
    [self addSubview:imageview];
    
    [imageview addSubview:title];
    [imageview addSubview:labelRecordDate];
    [imageview addSubview:labelValue];
    [imageview addSubview:textRecordDate];
    [imageview addSubview:textValue];
    [imageview addSubview:labelUnit];
    [imageview addSubview:buttonSave];
    [imageview addSubview:buttonCancel];
}

-(void)initData{
    NSDictionary *dict = [[BabyDataDB babyinfoDB] selectBabyPhysiologyDetail:itemType CreateTime:createTime];
    measureTime = [ACDate getDateFromTimeStamp:[[dict objectForKey:@"measure_time"] longValue]];
    textRecordDate.text=[ACDate dateDetailFomatdate3:measureTime];
    textValue.text = [NSString stringWithFormat:@"%0.1f",[[dict objectForKey:@"value"] doubleValue]];
    
}

-(void)saveRecord{
    if ([textRecordDate.text  isEqual: @""] || [textValue.text  isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"提交异常,请填写记录时间及数值哦!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([opType isEqualToString:@"SAVE"]) {
        if ([[BabyDataDB babyinfoDB] insertBabyPhysiology:[ACDate getTimeStampFromDate:[ACDate date]] UpdateTime:[ACDate getTimeStampFromDate:[ACDate date]] MeasureTime:[ACDate getTimeStampFromDate:[datepicker date]] Type:itemType Value:[textValue.text doubleValue]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"添加成功!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.PhySaveDelegate sendPhyReloadData];
            
            /**  edit by cwb  **/
            /**  刷新首页时间轴及数据源  **/
            if (itemType == 0) {
                [[InitTimeLineData initTimeLine]refreshByFinishItemsWithTypeID:20 ProTime:[ACDate getTimeStampFromDate:[datepicker date]] Key:@"" Content:[NSString stringWithFormat:@"记录了宝宝于%@时的身高: %@ cm。",[BaseMethod stringFromDate:[datepicker date]],textValue.text]];
            }else if (itemType == 1){
                [[InitTimeLineData initTimeLine]refreshByFinishItemsWithTypeID:21 ProTime:[ACDate getTimeStampFromDate:[datepicker date]] Key:@"" Content:[NSString stringWithFormat:@"记录了宝宝于%@时的体重: %@ kg。",[BaseMethod stringFromDate:[datepicker date]],textValue.text]];
            }
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"添加失败!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if ([opType isEqualToString:@"UPDATE"]){
        if ([[BabyDataDB babyinfoDB] updateBabyPhysiology:[textValue.text doubleValue] CreateTime:createTime UpdateTime:[ACDate getTimeStampFromDate:[ACDate date]] MeasureTime:[ACDate getTimeStampFromDate:measureTime]  Type:itemType]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"修改成功!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.PhySaveDelegate sendPhyReloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"添加失败!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    textValue.text = @"";
    textRecordDate.text = @"";
    [self removeFromSuperview];
}

-(void)cancelSave{
    textValue.text = @"";
    textRecordDate.text = @"";
    [self removeFromSuperview];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == textRecordDate){
        [self actionsheetShow];
        [textRecordDate resignFirstResponder];
        [textValue resignFirstResponder];
        return NO;
    }
    else{
        return YES;
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == textValue && ![self isPureFloat:textValue.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@数值异常,必须为数字!",itemName]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        textValue.text = @"";
        return NO;
    }
    else if (textField == textValue && ![self isLegal:textValue.text]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@数值必须在婴儿正常范围内!\n[身高范围:30~110cm]\n[体重范围:2~16kg]\n[头围范围:25~60cm]",itemName]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        textValue.text = @"";
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (id view in imageview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            [view resignFirstResponder];
        }
    }
}

#pragma 判断是否为浮点数
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

#pragma 判断是否为正确范围
-(BOOL)isLegal:(NSString*)string{
    double value = [string doubleValue];
    switch (itemType) {
        case 0:
            if (value < 30 || value > 110) {
                return NO;
            }
            break;
        case 1:
            if (value < 2 || value > 16) {
                return NO;
            }
            break;
        case 3:
            if (value < 25 || value > 60) {
                return NO;
            }
            break;
        default:
            break;
    }
    return YES;
}

-(void)updateRecordDate:(UIDatePicker*)sender{
    measureTime = sender.date;
    textRecordDate.text= [ACDate dateDetailFomatdate3:measureTime];
}

-(void)actionsheetShow
{
    if (action == nil) {
        action = [[CustomIOS7AlertView alloc] init];
        [action setContainerView:[self createDateView]];
        [action setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"确定", nil]];
        [action setDelegate:self];
    }
    datepicker.date = [NSDate date];
    [action show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self updateRecordDate:datepicker];
    }
    else{
        
    }
    
    [alertView close];
    
}

- (UIDatePicker*)createDateView
{
    if (datepicker==nil) {
        datepicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, textRecordDate.frame.origin.y+45+G_YADDONVERSION, 320, 162)];
        datepicker.datePickerMode = UIDatePickerModeDate;
        BabyDataDB *babyDb = [[BabyDataDB alloc]init];
        NSDictionary *dict = [babyDb selectBabyInfoByBabyId:BABYID];
        long birthTime = [[dict objectForKey:@"birth"] longValue];
        datepicker.minimumDate = [ACDate getDateFromTimeStamp:birthTime]; 
    }
    datepicker.frame=CGRectMake(0, 0, 320, 162);
    return datepicker;
}




@end
