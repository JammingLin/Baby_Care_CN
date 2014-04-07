//
//  SyncController.h
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 14-4-3.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef void(^SyncFinishBlock)();

@interface SyncController : NSObject {
    
}

+(id)syncController;

-(void)syncBabyDataCollectionsByUserID:(int) UserID
                           HUD:(MBProgressHUD*) hud
                  SyncFinished:(SyncFinishBlock) syncFinishBlock
                ViewController:(UIViewController*) viewController;


@end
