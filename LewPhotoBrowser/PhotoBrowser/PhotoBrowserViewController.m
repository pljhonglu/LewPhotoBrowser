//
//  PhotoBrowserViewController.m
//  LewPhotoBrowser
//
//  Created by pljhonglu on 15/6/25.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <LewReorderableLayout.h>
#import <MWPhotoBrowser.h>
#import "PhotoBrowserCell.h"
#import "PictureModel.h"

NSString *const KPhotoBrowserNotificationStartEdit = @"KPhotoBrowserNotificationStartEdit";
NSString *const KPhotoBrowserNotificationEndEdit = @"KPhotoBrowserNotificationEndEdit";

@interface PhotoBrowserViewController ()<LewReorderableLayoutDelegate,LewReorderableLayoutDataSource, MWPhotoBrowserDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PhotoBrowserCellDelegate>
@property (nonatomic, weak)IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray *mPhotoArray;
@property (nonatomic)BOOL isShowBrowser;
@property (nonatomic)BOOL isEditting;

@end

@implementation PhotoBrowserViewController
static NSString *const cellIdentifier = @"PhotoBrowserCell";

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initPropertyData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPropertyData];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initPropertyData];
    }
    return self;
}

- (void)initPropertyData{
    _allowToMoveItem = YES;
    _isEditting = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"照片编辑";
    
    [_collectionView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    _collectionView.backgroundColor = [UIColor clearColor];
    LewReorderableLayout *layout = (LewReorderableLayout *)_collectionView.collectionViewLayout;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat width = floor(screenWidth / 3.0 - ((2.0 / 3) * 2));
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 2.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 2.0f, 0);
    layout.delegate = self;
    
    // navigationbar
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(navigationRightButtonAction:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - setter/getter
- (void)setPhotoArray:(NSArray *)photoArray{
    _mPhotoArray = [NSMutableArray arrayWithArray:photoArray];
    // 在最后加上添加照片的 item
    PictureModel *photo = [[PictureModel alloc]init];
    photo.image = [UIImage imageNamed:@"AddImage"];
    photo.type = PhotoTypeOfAdd;
    [_mPhotoArray addObject:photo];
}

- (NSArray *)photoArray{
    NSArray *array = [_mPhotoArray subarrayWithRange:NSMakeRange(0, _mPhotoArray.count-1)];
    return array;
}

#pragma mark - action
- (void)navigationRightButtonAction:(id)sender{
    if ([_delegate respondsToSelector:@selector(PhotoBrowserWillPop:)]) {
        [_delegate PhotoBrowserWillPop:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)endEditAction{
    if (_isEditting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KPhotoBrowserNotificationEndEdit object:self];
        
        // 编辑完成之后需要在最后加上添加照片的 item
        PictureModel *photo = [PictureModel new];
        photo.image = [UIImage imageNamed:@"AddImage"];
        photo.type = PhotoTypeOfAdd;
        [_mPhotoArray addObject:photo];
        [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mPhotoArray.count-1 inSection:0]]];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(navigationRightButtonAction:)];
        self.navigationItem.rightBarButtonItem = item;
        _isEditting = NO;
    }
}

- (void)startEditAction{
    if (!_isEditting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KPhotoBrowserNotificationStartEdit object:self];
        
        // 编辑状态不能添加照片
        [_mPhotoArray removeLastObject];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mPhotoArray.count inSection:0]]];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(endEditAction)];
        self.navigationItem.rightBarButtonItem = item;
        _isEditting = YES;
    }
}

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    PictureModel *photo = _mPhotoArray[indexPath.item];
    cell.photo = photo;
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _mPhotoArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isEditting) {
        return;
    }
    if (indexPath.row == _mPhotoArray.count-1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
        [actionSheet showInView:self.view];
        return;
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:indexPath.item];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    PictureModel *fromPicture = [_mPhotoArray objectAtIndex:fromIndexPath.item];
    [_mPhotoArray removeObjectAtIndex:fromIndexPath.item];
    [_mPhotoArray insertObject:fromPicture atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_mPhotoArray.count <= 1) {
        return NO;
    }
    // 长按之后所有图片置为编辑状态
    [self startEditAction];
    
    return _allowToMoveItem;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    if (toIndexPath.row == _mPhotoArray.count-1) {
        return NO;
    }
    return _allowToMoveItem;
}

#pragma mark - PhotoBrowserCellDelegate
- (void)PhotoBrowserCellDelete:(PhotoBrowserCell *)cell{
    NSIndexPath *indexpath = [_collectionView indexPathForCell:cell];
    [_mPhotoArray removeObjectAtIndex:indexpath.item];
    [_collectionView deleteItemsAtIndexPaths:@[indexpath]];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UIImagePickerViewControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    PictureModel *photo = [PictureModel new];
    photo.image = image;
    [_mPhotoArray insertObject:photo atIndex:_mPhotoArray.count-1];
    [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mPhotoArray.count-2 inSection:0]]];
    // TODO: 这里选中照片之后可以进行图片的上传操作
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    
    switch (buttonIndex) {
        case 0:{
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
                NSLog(@"没有访问相机的权限");
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 1:{
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
                NSLog(@"没有访问相册的权限");
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default:
            return;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _mPhotoArray.count-1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    PictureModel *photo = _mPhotoArray[index];
    MWPhoto *mwphoto = [MWPhoto photoWithImage:photo.image];
    return mwphoto;
}

@end
