//
//  QSHomeViewController.m
//  QSGather
//
//  Created by tianmaotao on 2021/11/3.
//

#import "QSHomeViewController.h"
#import "BBPgcTabTestController.h"
#import "QSClassifyController.h"

@interface QSHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QSHomeViewController

#pragma mark - override

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首位";
    [self makeTableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.tableView != nil) {
        self.tableView.frame = self.view.bounds;
    }
}

#pragma mark - private

- (void)makeTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    [self.view addSubview:self.tableView];
}

- (void)jumpToTabTestController {
    BBPgcTabTestController *vc = [[BBPgcTabTestController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToClassifyController {
    QSClassifyController *vc = [[QSClassifyController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第 %ld 个选项", indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            UIViewController *vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor orangeColor];
            vc.title = @"自定义转场动画测试";
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            [self jumpToTabTestController];
            break;
        }
        case 2: {
            [self jumpToClassifyController];
            break;
        }
            
        default:
            break;
    }
}

@end
