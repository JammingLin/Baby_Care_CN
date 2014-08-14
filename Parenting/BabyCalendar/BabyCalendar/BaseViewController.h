//
//  BaseViewController.h
//  MySafedog
//
//  Created by Will on 13-12-26.
//  Copyright (c) 2013年 will. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "LoadingView.h"

@interface BaseViewController : UIViewController
{
    LoadingView* _loadingView;
}

- (void)alertView:(NSString*)text;
@end
