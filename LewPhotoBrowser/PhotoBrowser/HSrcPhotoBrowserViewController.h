//
//  HSrcPhotoBrowserViewController.h
//  NetEaseHouseAgent
//
//  Created by pljhonglu on 15/5/21.
//  Copyright (c) 2015年 xbw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWPhoto, HSrcPhotoBrowserViewController;

@protocol HSrcPhotoBrowserViewControllerDelegate <NSObject>
@optional
- (void)HSrcPhotoBrowserWillPop:(HSrcPhotoBrowserViewController *)photoBrowser;

@end

@class PictureModel;
@interface HSrcPhotoBrowserViewController : UIViewController
@property (nonatomic, strong)NSArray *photoArray;// HousePictureModel array
@property (nonatomic)BOOL allowToMoveItem;// default is YES
@property (nonatomic, weak)id<HSrcPhotoBrowserViewControllerDelegate> delegate;
@end


extern NSString *const KHSrcPhotoBrowserNotificationStartEdit;
extern NSString *const KHSrcPhotoBrowserNotificationEndEdit;

