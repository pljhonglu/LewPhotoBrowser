//
//  ViewController.m
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "ViewController.h"
#import "PictureModel.h"
#import "PhotoBrowserViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pushPhotoBrowserAction:(id)sender{
    NSMutableArray *pictures = @[].mutableCopy;
    for (int i = 1; i < 9; i++) {
        NSString *imageName = [NSString stringWithFormat:@"photo%@.jpg",@(i)];
        PictureModel *model = [PictureModel new];
        model.image = [UIImage imageNamed:imageName];
        [pictures addObject:model];
    }
    PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc]init];
    vc.photoArray = pictures;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
