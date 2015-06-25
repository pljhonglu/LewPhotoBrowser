//
//  HSrcPhotoBrowserViewController.m
//  NetEaseHouseAgent
//
//  Created by pljhonglu on 15/5/21.
//  Copyright (c) 2015年 xbw. All rights reserved.
//

#import "HSrcPhotoBrowserViewController.h"
#import "LewReorderableLayout.h"
#import "HSrcPhotoBrowserCell.h"
#import <MWPhotoBrowser.h>
#import "UIImage+BMAddition.h"
#import "NetworkingService.h"
#import <AVFoundation/AVFoundation.h>
#import "HouseInfoModelItem.h"
#import <AssetsLibrary/AssetsLibrary.h>

NSString *const KHSrcPhotoBrowserNotificationStartEdit = @"KHSrcPhotoBrowserNotificationStartEdit";
NSString *const KHSrcPhotoBrowserNotificationEndEdit = @"KHSrcPhotoBrowserNotificationEndEdit";

@interface HSrcPhotoBrowserViewController ()<LewReorderableLayoutDelegate,LewReorderableLayoutDataSource, MWPhotoBrowserDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, HSrcPhotoBrowserCellDelegate>
@property (nonatomic, strong)NSMutableArray *mPhotoArray;

@property (nonatomic)BOOL isShowBrowser;
@property (nonatomic, weak)IBOutlet UICollectionView *collectionView;

@property (nonatomic)BOOL isEditting;
@end

@implementation HSrcPhotoBrowserViewController
static NSString *const cellIdentifier = @"HSrcPhotoBrowserCell";

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
    
    [self setNaviTitle:@"照片编辑"];
    
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

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

#pragma mark - setter/getter
- (void)setPhotoArray:(NSArray *)photoArray{
    _mPhotoArray = [NSMutableArray arrayWithArray:photoArray];
    HousePictureModel *photo = [[HousePictureModel alloc]init];
    photo.image = [UIImage imageNamed:@"addImage"];
    [_mPhotoArray addObject:photo];
}

- (NSArray *)photoArray{
    NSArray *array = [_mPhotoArray subarrayWithRange:NSMakeRange(0, _mPhotoArray.count-1)];
    return array;
}

#pragma mark - action
- (void)navigationRightButtonAction:(id)sender{
    if ([_delegate respondsToSelector:@selector(HSrcPhotoBrowserWillPop:)]) {
        [_delegate HSrcPhotoBrowserWillPop:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)endEditAction{
    if (_isEditting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KHSrcPhotoBrowserNotificationEndEdit object:self];
        HousePictureModel *photo = [HousePictureModel new];
        photo.image = [UIImage imageNamed:@"addImage"];
        [_mPhotoArray addObject:photo];
        [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mPhotoArray.count-1 inSection:0]]];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(navigationRightButtonAction:)];
        self.navigationItem.rightBarButtonItem = item;
        _isEditting = NO;
    }
}

- (void)startEditAction{
    if (!_isEditting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KHSrcPhotoBrowserNotificationStartEdit object:self];
        [_mPhotoArray removeLastObject];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mPhotoArray.count inSection:0]]];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(endEditAction)];
        self.navigationItem.rightBarButtonItem = item;
        _isEditting = YES;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HSrcPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    HousePictureModel *photo = _mPhotoArray[indexPath.item];
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
    HousePictureModel *fromPicture = [_mPhotoArray objectAtIndex:fromIndexPath.item];
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

#pragma mark - HSrcPhotoBrowserCellDelegate
- (void)HSrcPhotoBrowserCellDelete:(HSrcPhotoBrowserCell *)cell{
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    NSURL *url = [[NetworkingService sharedInstance] generateURLWithActionName:@"common/1/info" andParameters:@{@"method":@"picupload"}];
    kWeakSelf(weakSelf);
    [[NetworkingService sharedInstance] uploadDataToURL:url paramDict:nil dataDict:@{@"picture":imageData} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"errorCode"] integerValue] != 0) {
            [weakSelf showErrorHUDWithTitle:responseObject[@"errorMsg"]];
        }
        
        [weakSelf showSuccessHUDWithTitle:@"图片上传成功"];
        NSString *url = responseObject[@"params"][@"url"];
        HousePictureModel *photo = [HousePictureModel new];
        photo.url = [NSURL URLWithString:url];
        [weakSelf.mPhotoArray insertObject:photo atIndex:weakSelf.mPhotoArray.count-1];
        [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:weakSelf.mPhotoArray.count-2 inSection:0]]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf showErrorHUDWithTitle:@"图片上传失败"];
    } uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [weakSelf showHUDWithProgress:(totalBytesWritten/totalBytesExpectedToWrite) status:@"正在上传"];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageWithColor:SinglePersistMgr.uiSet.colorNavBarBackground] forBarMetrics:UIBarMetricsDefault];
    
    imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : SinglePersistMgr.uiSet.fontNavBarTitle.font};
    switch (buttonIndex) {
        case 0:{
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
                alert(@"没有访问相机的权限");
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 1:{
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
                alert(@"没有访问相册的权限");
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
    return _mPhotoArray.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    HousePictureModel *photo = _mPhotoArray[index];
    MWPhoto *mwphoto = [MWPhoto photoWithURL:photo.url];
    return mwphoto;
}
@end

