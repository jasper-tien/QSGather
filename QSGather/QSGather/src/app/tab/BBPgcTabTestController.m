//
//  BBPgcTabTestController.m
//  QSGather
//
//  Created by tianmaotao on 2022/7/27.
//

#import "BBPgcTabTestController.h"
#import "BBPgcTabController.h"
#import "BBPgcTabBarItem.h"

@interface BBPgcTabContentController : UIViewController

@end

@implementation BBPgcTabContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear", self.title);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ viewDidAppear", self.title);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear", self.title);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ viewDidDisappear", self.title);
}

@end


@interface BBPgcTabModel : NSObject

@property (nonatomic, strong) BBPgcTabBarItem *tabBarItem;

@property (nonatomic, strong) BBPgcTabContentController *contentVC;

@end

@implementation BBPgcTabModel

@end


@interface BBPgcTabTestController ()<BBPgcTabControllerDataSource, BBPgcTabControllerDelegate>
@property (nonatomic, strong) BBPgcTabController *tabController;
@property (nonatomic, copy) NSArray<BBPgcTabModel *> *tabModels;
@end

@implementation BBPgcTabTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray<NSArray *> *bgColors = @[@[[UIColor purpleColor], @"紫色"],
                                          @[[UIColor orangeColor], @"橘色" ],
                                          @[[UIColor greenColor], @"绿色"],
                                          @[[UIColor systemPinkColor], @"粉色"],
                                          @[[UIColor lightGrayColor], @"灰色"]
    ];
    NSMutableArray *tabModels = @[].mutableCopy;
    for (int i = 0; i < bgColors.count; i++) {
        BBPgcTabBarItem *barItem = [[BBPgcTabBarItem alloc] init];
        [barItem configTitle:[NSString stringWithFormat:@"第 %d tab", i] subTitle:nil];
        BBPgcTabContentController *contentVC = [[BBPgcTabContentController alloc] init];
        contentVC.view.backgroundColor = (UIColor *)(bgColors[i][0]);
        contentVC.title = (NSString *)(bgColors[i][1]);
        BBPgcTabModel *tabModel = [[BBPgcTabModel alloc] init];
        tabModel.tabBarItem = barItem;
        tabModel.contentVC = contentVC;
        [tabModels addObject:tabModel];
    }
    self.tabModels = tabModels;
    
    _tabController = [[BBPgcTabController alloc] initWithForceLoad:YES];
    _tabController.dataSource = self;
    _tabController.delegate = self;
    [self.view addSubview:_tabController.view];
    [self addChildViewController:_tabController];
    _tabController.tabBarView.backgroundColor = [UIColor lightGrayColor];
    
    [_tabController reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tabController.view.frame = (CGRect){
        .origin.y = 100.f,
        .origin.x = 50.f,
        .size.width = self.view.frame.size.width - 100.f,
        .size.height = self.view.frame.size.height - 200.f,
    };
}

#pragma mark - BBPgcTabControllerDataSource

- (NSInteger)numberInPgcTabController:(BBPgcTabController *)tabController {
    return self.tabModels.count;
}

- (UIView<BBPgcTabBarItemProtocol> *)pgcTabController:(BBPgcTabController *)tabController barItemViewAtIndex:(NSUInteger)index {
    return self.tabModels[index].tabBarItem;
}

- (UIViewController *)pgcTabController:(BBPgcTabController *)tabController contentControllerAtIndex:(NSUInteger)index {
    return self.tabModels[index].contentVC;
}

#pragma mark - BBPgcTabControllerDelegate

- (NSUInteger)defaultSelectIndexInPgcTabController:(BBPgcTabController *)tabController {
    return 2;
}

- (CGFloat)heightForTabBarViewInPgcTabController:(BBPgcTabController *)tabController {
    return 44.f;
}

- (CGFloat)tabBarItemSpacingInPgcTabController:(BBPgcTabController *)tabController {
    return 10.f;
}

- (CGFloat)indicatorHeightInPgcTabController:(BBPgcTabController *)tabController {
    return 5.f;
}

- (UIEdgeInsets)tabBarViewInsetInPgcTabController:(BBPgcTabController *)tabController {
    return UIEdgeInsetsMake(0, 0, 0, 100);
}

@end
