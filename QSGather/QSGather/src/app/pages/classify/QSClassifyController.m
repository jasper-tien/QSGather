//
//  QSClassifyController.m
//  QSGather
//
//  Created by tianmaotao on 2022/8/27.
//

#import "QSClassifyController.h"
#import "QSGather-Swift.h"

@interface QSTabModel : NSObject

@property (nonatomic, strong) QSTabBarItem *tabBarItem;

@property (nonatomic, strong) UIViewController *contentVC;

@end

@implementation QSTabModel

@end


@interface QSClassifyController ()<QSTabControllerDelegate, QSTabControllerDataSource>

@property (nonatomic, strong) QSTabController *tabController;

@property (nonatomic, copy) NSArray<QSTabModel *> *tabModels;

@end

@implementation QSClassifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildTabController];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tabController.view.frame = self.view.bounds;
}

- (void)buildTabController {
    if (!_tabController) {
        _tabController = [[QSTabController alloc] init];
        _tabController.delegate = self;
        _tabController.dataSource = self;
        [self.view addSubview:_tabController.view];
        [self addChildViewController:_tabController];
        
        NSArray<NSArray *> *bgColors = @[@[[UIColor purpleColor], @"紫色"],
                                              @[[UIColor orangeColor], @"橘色" ],
                                              @[[UIColor greenColor], @"绿色"],
                                              @[[UIColor systemPinkColor], @"粉色"],
                                              @[[UIColor lightGrayColor], @"灰色"]
        ];
        NSMutableArray *tabModels = @[].mutableCopy;
        for (int i = 0; i < bgColors.count; i++) {
            QSTabBarItem *barItem = [[QSTabBarItem alloc] init];
            [barItem configWithTitle:[NSString stringWithFormat:@"第 %d tab", i] subtitle:nil];
            UIViewController *contentVC = [[UIViewController alloc] init];
            contentVC.view.backgroundColor = (UIColor *)(bgColors[i][0]);
            contentVC.title = (NSString *)(bgColors[i][1]);
            QSTabModel *tabModel = [[QSTabModel alloc] init];
            tabModel.tabBarItem = barItem;
            tabModel.contentVC = contentVC;
            [tabModels addObject:tabModel];
        }
        self.tabModels = tabModels;
        [_tabController reloadData];
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

#pragma mark - QSTabControllerDataSource

- (NSInteger)numberIn:(QSTabController * _Nonnull)tabController {
    return self.tabModels.count;
}

- (UIView<QSTabBarItemProtocol> * _Nonnull)tabController:(QSTabController * _Nonnull)tabController barItemView:(NSInteger)index {
    return self.tabModels[index].tabBarItem;
}

- (UIViewController * _Nonnull)tabController:(QSTabController * _Nonnull)tabController contentController:(NSInteger)index {
    return self.tabModels[index].contentVC;
}

#pragma mark - QSTabControllerDelegate

- (CGFloat)heightForTabBarViewIn:(QSTabController *)tabController {
    return 44;
}

- (CGFloat)tabBarItemSpacingIn:(QSTabController *)tabController {
    return 10;
}

- (CGFloat)indicatorHeightIn:(QSTabController *)tabController {
    return 5;
}

//@objc optional func heightForTabBarView(in tabController: QSTabController) -> CGFloat
//@objc optional func tabBarItemSpacing(in tabController: QSTabController) -> CGFloat
//@objc optional func indicatorHeight(in tabController: QSTabController) -> CGFloat
//@objc optional func tabBarViewInset(in tabController: QSTabController) -> UIEdgeInsets
//@objc optional func tabBarViewContentInset(in tabController: QSTabController) -> UIEdgeInsets

@end
