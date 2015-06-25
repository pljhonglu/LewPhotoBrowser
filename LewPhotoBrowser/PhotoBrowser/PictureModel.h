//
//  PictureModel.h
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PhotoType) {
    PhotoTypeOfNormal,
    PhotoTypeOfAdd,
};

@interface PictureModel : NSObject
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)NSURL *url;
@property (nonatomic)PhotoType type;

@end
