//
//  PhotoBrowserCell.h
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureModel.h"

@class PhotoBrowserCell;
@protocol PhotoBrowserCellDelegate <NSObject>
- (void)PhotoBrowserCellDelete:(PhotoBrowserCell *)cell;

@end

@interface PhotoBrowserCell : UICollectionViewCell
@property (nonatomic, strong)PictureModel *photo;
@property (nonatomic, weak)id<PhotoBrowserCellDelegate> delegate;

@end
