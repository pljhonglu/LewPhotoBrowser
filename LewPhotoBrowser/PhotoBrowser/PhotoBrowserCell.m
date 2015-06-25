//
//  PhotoBrowserCell.m
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "PhotoBrowserCell.h"
#import "PhotoBrowserViewController.h"
#import <UIImageView+WebCache.h>

#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface PhotoBrowserCell ()
@property (nonatomic, weak)IBOutlet UIView *bgView;
@property (nonatomic, weak)IBOutlet UIImageView *imageView;
@property (nonatomic, weak)IBOutlet UIButton *deleteButton;

@end

@implementation PhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEdit) name:KPhotoBrowserNotificationStartEdit object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEdit) name:KPhotoBrowserNotificationEndEdit object:nil];
    _deleteButton.hidden = YES;
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter
- (void)setPhoto:(PictureModel *)photo{
    _photo = photo;
    if (photo.image) {
        _imageView.image = photo.image;
    }else if (photo.url){
        [_imageView sd_setImageWithURL:photo.url];
    }
}

#pragma mark - action
- (void)startEdit{
    if (_photo.type == PhotoTypeOfAdd) {
        // 默认的添加按钮是直接显示图片的， 这个按钮无法编辑
        return;
    }
    _deleteButton.hidden = NO;
    
    CATransform3D transform = CATransform3DScale(self.layer.transform, 0.8, 0.8, 1.0);
    _bgView.layer.transform = transform;
    
    CAKeyframeAnimation *rotationAnim=[CAKeyframeAnimation animation];
    rotationAnim.keyPath=@"transform.rotation";
    rotationAnim.values=@[@(angelToRandian(-3)),@(angelToRandian(3)),@(angelToRandian(-3))];
    rotationAnim.repeatCount=MAXFLOAT;
    rotationAnim.duration=0.2;
    [_bgView.layer addAnimation:rotationAnim forKey:nil];
}

- (void)endEdit{
    _deleteButton.hidden = YES;
    [_bgView.layer removeAllAnimations];
    CATransform3D transform = CATransform3DScale(self.layer.transform, 1.0, 1.0, 1.0);
    _bgView.layer.transform = transform;
}

- (IBAction)deleteAction:(id)sender{
    NSLog(@"delete photo Action");
    if (_delegate) {
        [_delegate PhotoBrowserCellDelete:self];
    }
}

@end
