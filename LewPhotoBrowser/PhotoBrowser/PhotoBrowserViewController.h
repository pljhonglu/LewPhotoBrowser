//
//  PhotoBrowserViewController.h
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;
@protocol PhotoBrowserViewControllerDelegate <NSObject>
@optional
- (void)PhotoBrowserWillPop:(PhotoBrowserViewController *)photoBrowser;

@end

@class PictureModel;
@interface PhotoBrowserViewController : UIViewController
@property (nonatomic, strong)NSArray *photoArray;// PictureModel array
@property (nonatomic)BOOL allowToMoveItem;// default is YES
@property (nonatomic, weak)id<PhotoBrowserViewControllerDelegate> delegate;
@end

extern NSString *const KPhotoBrowserNotificationStartEdit;
extern NSString *const KPhotoBrowserNotificationEndEdit;