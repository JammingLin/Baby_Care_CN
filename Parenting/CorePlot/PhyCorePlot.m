//
//  PhyCorePlot.m
//  Physiological
//
//  Created by CHEN WEIBIN on 14-1-22.
//  Copyright (c) 2014年 CHEN WEIBIN. All rights reserved.
//

#import "PhyCorePlot.h"
#import "PhyCPTTheme.h"

@implementation PhyCorePlot

#pragma 参数:Frame、标题、X/Y轴坐标、X/Y轴名称、线条描点集合
//XY轴坐标XYPlotRange:@[X轴坐标,Y轴坐标]
//XY轴名称相上
//线条描点axis:@[@[@"线条含义",UIColor,NSArray<描点内容>],...]
-(id)initWithFrame:(CGRect)frame Title:(NSString*)title XYPlotRange:(NSArray*)xyRange XYTitle:(NSArray*)xyTitle Axis:(NSArray*)axis YBaseV:(float)yBaseV YSizeInterval:(float)ySizeinter{
    if (self = [super initWithFrame:frame]) {
        Ctitle      = title;
        CxyRange    = xyRange;
        CxyTitle    = xyTitle;
        Caxis       = axis;
        
        //Fixed:
        yBaseValue  = yBaseV;
        ySizeInterval  = ySizeinter;
        
        //Step1:配置Graph画布
        [self configureGraph];
        //Step2:配置Plots绘制
        [self configurePlots];
        //Step3:配置Axes弧线
        [self configureAxes];
    }
    return self;
}

-(void)configureGraph {
    // 1 - 创建画布
    _graph = [[CPTXYGraph alloc] initWithFrame:self.bounds];
     PhyCPTTheme *theme = [[PhyCPTTheme alloc] init];
    [_graph applyTheme:theme];
    self.hostedGraph = _graph;
    // 2 - 设置画布标题
    _graph.title = Ctitle;
    // 3 - 创建且设置文字样式
    // 4 - 设置画布留空
    _graph.plotAreaFrame.borderLineStyle = nil;
    _graph.plotAreaFrame.cornerRadius    = 0.0f;
    //CPTGraph四边不留白
    _graph.paddingLeft   = 0.0f;
    _graph.paddingRight  = 0.0f;
    _graph.paddingTop    = 0.0f;
    _graph.paddingBottom = 0.0f;
    //绘图区四边留白
    _graph.plotAreaFrame.paddingLeft   = 25.0f;
    _graph.plotAreaFrame.paddingRight  = 25.0f;
    _graph.plotAreaFrame.paddingTop    = 25.0f;
    _graph.plotAreaFrame.paddingBottom = 25.0f;
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) _graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
}

-(void)configurePlots {
    // 1 - 建立绘制区域
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) _graph.defaultPlotSpace;
    // 2 - 判断绘制曲线数量并绘制区域
    
    /**  P75  **/
    CPTScatterPlot *baseP75Plot = [[CPTScatterPlot alloc] init];    //P25参考线
    baseP75Plot.dataSource = self;
    baseP75Plot.identifier = @"P75";
    CPTColor *baseP75Color = [CPTColor blueColor];
    [_graph addPlot:baseP75Plot toPlotSpace:plotSpace];
    
    //P75填充区域
    NSString *pngFilePath=[[NSBundle mainBundle] pathForResource:@"phy_shadow" ofType:@"png"];
    CPTFill * P75areaGradientFill = [CPTFill fillWithImage:[CPTImage imageForPNGFile:pngFilePath]];
    baseP75Plot.areaFill      = P75areaGradientFill;
    //0.1是为了避免填充区域覆盖XY轴
    baseP75Plot.areaBaseValue = [[NSDecimalNumber numberWithFloat:0.1] decimalValue];
    
    /**  P25  **/
    CPTScatterPlot *baseP25Plot = [[CPTScatterPlot alloc] init];    //P25参考线
    baseP25Plot.dataSource = self;
    baseP25Plot.identifier = @"P25";
    CPTColor *baseP25Color = [CPTColor blueColor];
    [_graph addPlot:baseP25Plot toPlotSpace:plotSpace];
    
    //P25填充区域
    CPTFill * areaGradientFill  = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    baseP25Plot.areaFill      = areaGradientFill;
    //0.1是为了避免填充区域覆盖XY轴
    baseP25Plot.areaBaseValue = [[NSDecimalNumber numberWithFloat:0.1] decimalValue];
    
    CPTScatterPlot *targetUserPlot = [[CPTScatterPlot alloc] init];    //用户参考线
    targetUserPlot.dataSource = self;
    targetUserPlot.identifier = @"targetUser";
    CPTColor *targetUserColor = [CPTColor blueColor];
    [_graph addPlot:targetUserPlot toPlotSpace:plotSpace];
    
    /* 用户参考线描点 */
    CPTMutableLineStyle * symbolUserLineStyle = [CPTMutableLineStyle lineStyle];
    symbolUserLineStyle.lineColor = [CPTColor greenColor];
    symbolUserLineStyle.lineWidth = 2;
    
    CPTPlotSymbol * plotSymbolUser = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbolUser.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbolUser.lineStyle     = symbolUserLineStyle;
    plotSymbolUser.size          = CGSizeMake(7.0, 7.0);
    targetUserPlot.plotSymbol = plotSymbolUser;
    
    
    // 3 - 设置绘制控件
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:baseP25Plot,baseP75Plot,targetUserPlot,nil]];
    //TODO:XY轴起始刻度根据时间情况判断
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat([[Caxis objectAtIndex:0]count] - 1)]; 
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(5.5f)];
    // 4 - 设置绘制样式和描点样式 style symbol
    CPTMutableLineStyle *baseP25LineStyle = [baseP25Plot.dataLineStyle mutableCopy];
    baseP25LineStyle.lineWidth = 0.2;
    baseP25LineStyle.lineColor = baseP25Color;
    baseP25Plot.dataLineStyle = baseP25LineStyle;
    
    CPTMutableLineStyle *baseP75LineStyle = [baseP75Plot.dataLineStyle mutableCopy];
    baseP75LineStyle.lineWidth = 0.2;
    baseP75LineStyle.lineColor = baseP75Color;
    baseP75Plot.dataLineStyle = baseP75LineStyle;
    
    CPTMutableLineStyle *targetUserLineStyle = [targetUserPlot.dataLineStyle mutableCopy];
    targetUserLineStyle.lineWidth = 1.5;
    targetUserLineStyle.lineColor = targetUserColor;
    targetUserPlot.dataLineStyle = targetUserLineStyle;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.textAlignment = NSTextAlignmentRight;
    axisTextStyle.fontSize = 9.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostedGraph.axisSet;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0.0];
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0.0];
    
    // 3 - 配置X轴
    CPTAxis *x = axisSet.xAxis;
    x.title = [CxyTitle objectAtIndex:0];
    x.titleLocation = CPTDecimalFromDouble(10);
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -19.5f;
    
    x.axisLineStyle = axisLineStyle; 
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorIntervalLength = CPTDecimalFromInt(3);
    x.tickDirection = CPTSignNegative;
    
    CGFloat dateCount = [[Caxis objectAtIndex:0] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    //TODO:画X轴label 
    
    for ( NSInteger j = 0; j < [[Caxis objectAtIndex:0]count]; j++) {
        NSString *xLabel;
        xLabel = [NSString stringWithFormat:@"%@", [[Caxis objectAtIndex:0] objectAtIndex:j]];
         CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:xLabel textStyle:x.labelTextStyle];
        
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }

    
    x.axisLabels = xLabels;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = [CxyTitle objectAtIndex:1];
    y.titleTextStyle = axisTitleStyle;
    y.titleRotation=0; 
    y.titleLocation=CPTDecimalFromDouble(6.2);
    y.titleOffset=0.1;
    
    y.axisLineStyle = axisLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 10.0f;
    y.tickDirection = CPTSignPositive;
    
    //TODO:画Y轴label
    CGFloat yDateCount = [[Caxis objectAtIndex:1] count];
    NSMutableSet *yLabels = [NSMutableSet setWithCapacity:yDateCount];
    NSMutableSet *yLocations = [NSMutableSet setWithCapacity:yDateCount];
    NSInteger k = 0;
    //TODO:画X轴label
    for ( NSInteger l = 0; l < [[Caxis objectAtIndex:1]count]; l++) {
        NSString *yLabel;
        yLabel = [NSString stringWithFormat:@"%@", [[Caxis objectAtIndex:1] objectAtIndex:l]];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:yLabel textStyle:y.labelTextStyle];
        
        CGFloat location = k++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = -21.0f;
        //y轴刻度0不现实
        if (label && l != 0) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    
    y.axisLabels = yLabels;
}



-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot.identifier  isEqual: @"targetUser"]) {
        return [[CxyRange objectAtIndex:2] count];
    }
    else{
        return [[CxyRange objectAtIndex:0] count];
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSInteger valueCount = [[CxyRange objectAtIndex:0] count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                //+0.1是为了避免填充区域覆盖XY轴
                if ([plot.identifier  isEqual: @"targetUser"]) {
                    double dXNum = [[[[CxyRange objectAtIndex:2] objectAtIndex:index] objectAtIndex:0] intValue] + 0.1;
                    return [NSNumber numberWithDouble:dXNum];
                }
                else{
                    return [NSNumber numberWithDouble:(index + 0.1)];
                }
            }
            break;
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:@"P25"] == YES) {
//                [NSNumber numberWithFloat:]
                NSNumber *num25 = [[CxyRange objectAtIndex:0] objectAtIndex:index];
                return [self getYAxisValue:num25];
            } else if ([plot.identifier isEqual:@"P75"] == YES) {
                NSNumber *num75 = [[CxyRange objectAtIndex:1] objectAtIndex:index];
                return [self getYAxisValue:num75];
            } else if ([plot.identifier isEqual:@"targetUser"] == YES) {
                NSNumber *numUser = [[[CxyRange objectAtIndex:2] objectAtIndex:index] objectAtIndex:1];
                return [self getYAxisValue:numUser];
            }
            break;
    } 
    return [NSDecimalNumber zero];
}

-(NSNumber *)getYAxisValue:(NSNumber*)value
{
    //如果小于最基础值
    if ([value floatValue] <= yBaseValue) {
        return [NSNumber numberWithFloat:[value floatValue]/yBaseValue];
    }
    else {
        float newValue = [value floatValue] - yBaseValue;
        return [NSNumber numberWithFloat:(newValue / ySizeInterval + 1)];
    }
}

@end
