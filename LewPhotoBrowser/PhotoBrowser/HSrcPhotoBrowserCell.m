//
//  HSrcPhotoBrowserCell.m
//  NetEaseHouseAgent
//
//  Created by pljhonglu on 15/5/21.
//  Copyright (c) 2015年 xbw. All rights reserved.
//

#import "HSrcPhotoBrowserCell.h"
#import <UIImageView+WebCache.h>
#import "HSrcPhotoBrowserViewController.h"

#define angelToRandian(x)  ((x)/180.0*M_PI)
@interface HSrcPhotoBrowserCell ()
@property (nonatomic, weak)IBOutlet UIView *bgView;

@property (nonatomic, weak)IBOutlet UIImageView *imageView;

@property (nonatomic, weak)IBOutlet UIButton *deleteButton;
@end

@implementation HSrcPhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
//    UILongPressGestureRecognizer* longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
//    [self addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEdit) name:KHSrcPhotoBrowserNotificationStartEdit object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEdit) name:KHSrcPhotoBrowserNotificationEndEdit object:nil];
    _deleteButton.hidden = YES;
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
    
//    self.backgroundColor = [UIColor cyanColor];
//    _deleteButton.backgroundColor = [UIColor yellowColor];
}


- (void)setPhoto:(HousePictureModel *)photo{
    _photo = photo;
    if (photo.image) {
        _imageView.image = photo.image;
    }else if (photo.url){
        [_imageView sd_setImageWithURL:photo.url];
    }
}


-(void)longPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan) {
        
    }
}

- (void)startEdit{
    if (_photo.image) {
        // 默认的添加按钮是直接显示图片的， 这个按钮无法编辑
        return;
    }
    _deleteButton.hidden = NO;
    
    CATransform3D transform = CATransform3DScale(self.layer.transform, 0.8, 0.8, 1.0);
    _bgView.layer.transform = transform;
    
//    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    scaleAnim.toValue = @(0.6);
//    scaleAnim.duration = 0.2;
//    scaleAnim.autoreverses = YES;
//    scaleAnim.repeatCount = 1;
//    scaleAnim.removedOnCompletion = YES;
//    scaleAnim.fillMode = kCAFillModeForwards;
//    [_bgView.layer addAnimation:scaleAnim forKey:nil];
    
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
    DLog(@"delete photo Action");
    if (_delegate) {
        [_delegate HSrcPhotoBrowserCellDelete:self];
    }

}

//
//- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
//{
//    UITouch *touche = [touches anyObject];
//    CGPoint point = [touche locationInView:_deleteButton];
//    CGRect bound = _deleteButton.bounds;
//    DLog(@"%@ %@", NSStringFromCGRect(bound), NSStringFromCGPoint(point));
//    if (CGRectContainsPoint(bound, point)) {
//        DLog(@"delete photo action");
//    }
//}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
