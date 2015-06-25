//
//  HSrcPhotoBrowserCell.h
//  NetEaseHouseAgent
//
//  Created by pljhonglu on 15/5/21.
//  Copyright (c) 2015年 xbw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HouseInfoModelItem.h"

@class HSrcPhotoBrowserCell;
@protocol HSrcPhotoBrowserCellDelegate <NSObject>

- (void)HSrcPhotoBrowserCellDelete:(HSrcPhotoBrowserCell *)cell;

@end

@interface HSrcPhotoBrowserCell : UICollectionViewCell
@property (nonatomic, strong)HousePictureModel *photo;
@property (nonatomic, weak)id<HSrcPhotoBrowserCellDelegate> delegate;

@end
