//
//  QSTabController.swift
//  QSSwiftDemo
//
//  Created by tianmaotao on 2022/8/3.
//

import Foundation
import UIKit
import CoreAudio

@objc
public enum QSTabSelectType: Int {
    case unknown
    case click // 点击tabBar选中
    case scroll // 滑动选中
    case force // 手动选中
}

public enum PGCVCStatus: Int {
    case unknown = 0
    case willAppear = 1
    case didAppear = 2
    case willDisappear = 3
    case didDisappear = 4
}

@objc
public protocol QSTabControllerDataSource: NSObjectProtocol {
    func number(in tabController: QSTabController) -> Int
    func tabController(_ tabController: QSTabController, barItemView index: Int) -> UIView & QSTabBarItemProtocol
    func tabController(_ tabController: QSTabController, contentController index: Int) -> UIViewController
}

@objc
public protocol QSTabControllerDelegate: NSObjectProtocol {
    @objc optional func defaultSelectIndex(in tabController: QSTabController) -> Int
    @objc optional func indicatorHidden(in tabController: QSTabController) -> Bool
    
    // Variable height & width support
    
    @objc optional func heightForTabBarView(in tabController: QSTabController) -> CGFloat
    @objc optional func tabBarItemSpacing(in tabController: QSTabController) -> CGFloat
    @objc optional func indicatorHeight(in tabController: QSTabController) -> CGFloat
    @objc optional func tabBarViewInset(in tabController: QSTabController) -> UIEdgeInsets
    @objc optional func tabBarViewContentInset(in tabController: QSTabController) -> UIEdgeInsets
    
    // Switch customization
    
    @objc optional func tabController(_ tabController: QSTabController, willSelectTab index: Int, type: QSTabSelectType)
    @objc optional func tabController(_ tabController: QSTabController, didSelectTab index: Int, type: QSTabSelectType)
    @objc optional func tabController(_ tabController: QSTabController, didSelectAgainTab index: Int, type: QSTabSelectType)
    @objc optional func tabController(_ tabController: QSTabController, willDeselectTab index: Int, type: QSTabSelectType)
    @objc optional func tabController(_ tabController: QSTabController, didDeselectTab index: Int, type: QSTabSelectType)
}

public class QSTabController : UIViewController {
    @objc public weak var dataSource: QSTabControllerDataSource?
    @objc public weak var delegate: QSTabControllerDelegate?
    
    @objc public var isForceLoad: Bool {
        return forceLoad
    }
    @objc public var selectingIndex: Int {
        return selectIndex
    }
    @objc public var selectViewController: UIViewController? {
        return selectVC
    }
    @objc public var contentPageView: UIScrollView {
        return pageView
    }
    @objc public var topTabBarView: UIView & QSTabBarViewProtocol {
        return tabBarView
    }
    
    // MARK: private
    private static let tabBarViewAreaHeightDefault: CGFloat = 44
    private static let tabControllerAnimationDuration = 0.25
    
    private var tabBarView: (UIView & QSTabBarViewProtocol)!
    private var customTabBarView: (UIView & QSTabBarViewProtocol)?
    lazy private var pageView: UIScrollView = UIScrollView()
    lazy private var loadedViewControllers: [Int:UIViewController] = [:]
    private var selectVC: UIViewController?
    
    private var numbersOfViewController: Int = 0
    private var selectIndex: Int = 0
    private var forceLoad: Bool = false
    private var transition: Bool = false
    private var tabVCStatus = PGCVCStatus.unknown
    
    // MARK: init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    public convenience init(forceLoad: Bool) {
        self.init()
        self.forceLoad = forceLoad
    }
    public convenience init(customTabBarView: UIView & QSTabBarViewProtocol) {
        self.init()
        self.customTabBarView = customTabBarView
    }
    public convenience init(customTabBarView: UIView & QSTabBarViewProtocol, forceLoad: Bool) {
        self.init()
        self.forceLoad = forceLoad
        self.customTabBarView = customTabBarView
    }
    
    // MARK: override
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tabBarViewInset: UIEdgeInsets = delegate?.tabBarViewInset?(in: self) ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let tabBarViewAreaHeight = delegate?.heightForTabBarView?(in: self) ?? QSTabController.tabBarViewAreaHeightDefault
        tabBarView.frame = CGRect(
            x: tabBarViewInset.left,
            y: tabBarViewInset.top,
            width: max(0, self.view.frame.width - tabBarViewInset.left - tabBarViewInset.right),
            height: max(0, tabBarViewAreaHeight - tabBarViewInset.top - tabBarViewInset.bottom))
        pageView.frame = CGRect(
            x: 0,
            y: tabBarViewAreaHeight,
            width: self.view.frame.width,
            height: max(0, self.view.frame.height - tabBarViewAreaHeight))
        pageView.contentSize = CGSize(
            width: self.view.frame.width * CGFloat(self.numbersOfViewController),
            height: 0)
        if self.loadedViewControllers.count > 0 {
            for (index, vc) in self.loadedViewControllers {
                vc.view.frame = CGRect(
                    x: self.pageView.frame.width * CGFloat(index),
                    y: 0,
                    width: self.pageView.frame.width,
                    height: self.pageView.frame.height)
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabVCStatus = .willAppear
        updateStatus(status: .willAppear, controller: self.selectVC, animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabVCStatus = .didAppear
        updateStatus(status: .didAppear, controller: self.selectVC, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabVCStatus = .willDisappear
        updateStatus(status: .willDisappear, controller: self.selectVC, animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabVCStatus = .didDisappear
        updateStatus(status: .didDisappear, controller: self.selectVC, animated: animated)
    }
    
    // MARK: private
    
    private func setupSubviews() {
        if customTabBarView != nil {
            tabBarView = customTabBarView!
        } else {
            tabBarView = QSTabBarView()
            tabBarView .configDelegate(self)
        }
        self.view.addSubview(tabBarView)
        
        pageView.backgroundColor = UIColor.clear
        pageView.showsVerticalScrollIndicator = false
        pageView.showsHorizontalScrollIndicator = false
        pageView.isPagingEnabled = true
        pageView.bounces = false
        pageView.delegate = self
        pageView.scrollsToTop = false
        self.view.addSubview(pageView)
    }
    
    private func reloadData(isForce: Bool) {
        if self.dataSource == nil {
            return
        }
        
        self.numbersOfViewController = self.dataSource?.number(in: self) ?? 0
        if self.view.frame.width > 0 {
            pageView.contentSize = CGSize(
                width: self.view.frame.width * CGFloat(self.numbersOfViewController),
                height: 0)
        }
        
        var selectIndex = defaultSelectIndex()
        selectIndex = min(self.numbersOfViewController - 1, selectIndex)
        selectIndex = max(0, selectIndex)
        
        self.tabBarView.itemSpacing = delegate?.tabBarItemSpacing?(in: self) ?? 0
        self.tabBarView.indicatorHeight = delegate?.indicatorHeight?(in: self) ?? 0
        self.tabBarView.indicatorHidden = delegate?.indicatorHidden?(in: self) ?? false
        self.tabBarView.contentScrollView.contentInset = delegate?.tabBarViewContentInset?(in: self) ?? UIEdgeInsets()
        
        tabBarView.reloadData()
        tabBarView.scroll(to: selectIndex, animated: false)
        
        let selectVC = dataSource?.tabController(self, contentController: selectIndex) ?? UIViewController()
        let ignore = (selectVC === self.selectVC) && (!isForce)
        if self.loadedViewControllers.count > 0 {
            for (_, vc) in self.loadedViewControllers {
                if !ignore && vc === self.selectVC {
                    self.updateStatus(status: .willDisappear, controller: vc, animated: false)
                }
                vc.view .removeFromSuperview()
                vc .removeFromParent()
                if !ignore && vc === self.selectVC {
                    self.updateStatus(status: .didDisappear, controller: vc, animated: false)
                }
            }
        }
        
        if self.forceLoad {
            for index in 0..<self.numbersOfViewController {
                _ = self.loadController(with: index)
            }
        }
        
        self.selectTo(index: selectIndex, animated: false, selectType: .unknown)
    }
    
    private func selectTo(index: Int, animated: Bool, selectType: QSTabSelectType) {
        if index < 0 || index >= self.numbersOfViewController {
            return
        }
        
        let lastSelectVC: UIViewController? = self.selectVC
        let selectVC: UIViewController? = loadController(with: index)
        
        if self.tabVCStatus.rawValue < PGCVCStatus.willDisappear.rawValue {
            updateStatus(status: PGCVCStatus.willDisappear, controller: lastSelectVC, animated: false)
            if self.tabVCStatus.rawValue >= PGCVCStatus.willAppear.rawValue {
                updateStatus(status: PGCVCStatus.willAppear, controller: selectVC, animated: false)
            }
        }
        
        let oldSelectIndex = self.selectIndex
        self.selectIndex = index
        self.selectVC = selectVC
        
        if self.transition {
            self.pageView.layer.removeAllAnimations()
        }
        
        delegate?.tabController?(self, willDeselectTab: oldSelectIndex, type: selectType)
        delegate?.tabController?(self, willSelectTab: index, type: selectType)
        
        let completionBlock = {
            [weak self](animated: Bool) -> Void in
            if let selfVC = self {
                selfVC.transition = false
                if selfVC.tabVCStatus.rawValue < PGCVCStatus.didDisappear.rawValue {
                    selfVC.updateStatus(status: PGCVCStatus.didDisappear, controller: lastSelectVC, animated: animated)
                    if selfVC.tabVCStatus.rawValue >= PGCVCStatus.didAppear.rawValue {
                        selfVC.updateStatus(status: PGCVCStatus.didAppear, controller: selectVC, animated: animated)
                    }
                }
                selfVC.delegate?.tabController?(selfVC, didDeselectTab: oldSelectIndex, type: selectType)
                selfVC.delegate?.tabController?(selfVC, didSelectTab: index, type: selectType)
            }
        }
        
        if animated {
            UIView.animate(withDuration: QSTabController.tabControllerAnimationDuration, animations: {
                [weak self] () -> Void in
                if let weakSelf = self {
                    weakSelf.transition = true
                    weakSelf.pageView.contentOffset = CGPoint(x: weakSelf.pageView.frame.width * CGFloat(index), y: 0)
                }
            }, completion: completionBlock)
        } else {
            completionBlock(false)
        }
    }
    
    private func insertController(controller: UIViewController, to index: Int) {
        if index >= 0 && index < self.numbersOfViewController {
            self.loadedViewControllers[index] = controller
            controller.view.frame = CGRect(
                x: pageView.frame.width * CGFloat(index),
                y: 0,
                width: pageView.frame.width,
                height: pageView.frame.height)
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight];
            self.addChild(controller)
            self.pageView.addSubview(controller.view)
        }
    }
    
    private func updateTabBar(with contentOffsetX: CGFloat) {
        let contentSizeWidth = self.pageView.contentSize.width
        let width = self.view.bounds.width
        if contentSizeWidth < 0.1 || contentOffsetX < 0.1 || width < 0.1 {
            return
        }
        
        let currentIndex = contentOffsetX / width
        let leftIndex = floor(currentIndex)
        let rightIndex = ceil(currentIndex)
        
        let currentPointX = contentOffsetX
        let leftPointX = leftIndex * width
        let rightPointX = rightIndex * width
        
        let unitRelativePointX = rightPointX - leftPointX
        let currentRelativePointX = currentPointX - leftPointX
        
        var relativeProgress: CGFloat = 0
        if unitRelativePointX > 0 || unitRelativePointX < 0 {
            relativeProgress = currentRelativePointX / unitRelativePointX;
        }
        
        let progress = contentOffsetX / contentSizeWidth;
        self.tabBarView.update(with: progress, relativeProgress: relativeProgress, leftIndex: Int(leftIndex), rightIndex: Int(rightIndex))
    }
    
    private func updateStatus(status: PGCVCStatus, controller: UIViewController?, animated: Bool) {
        guard let vc = controller else {
            return
        }
        vc.pgc_vc_status = status
        switch status {
        case .willAppear:
            vc.beginAppearanceTransition(true, animated: animated)
        case .willDisappear:
            vc.beginAppearanceTransition(false, animated: animated)
        case .didAppear:
            vc.endAppearanceTransition()
        case .didDisappear:
            vc.endAppearanceTransition()
        default: break
        }
    }
    
    private func defaultSelectIndex() -> Int {
        return delegate?.defaultSelectIndex?(in: self) ?? 0
    }
    
    private func loadController(with index: Int) -> UIViewController? {
        if let vc = self.dataSource?.tabController(self, contentController: index), index < self.numbersOfViewController && self.dataSource != nil {
            insertController(controller: vc, to: index)
            return vc
        }
        return nil
    }
}

extension QSTabController {
    
    @objc public func reloadData() {
        reloadData(isForce: false)
    }
    
    @objc public func scrollTo(_ index: Int, animated: Bool) {
        if index == self.selectIndex || index >= self.numbersOfViewController {
            return
        }
        selectTo(index: index, animated: animated, selectType: .force)
        tabBarView.scroll(to: index, animated: animated)
    }
    
    @objc public func contentViewController(with index: Int) -> UIViewController? {
        return self.loadedViewControllers[index]
    }
}

extension QSTabController : UIScrollViewDelegate, QSTabBarDelegate {
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTabBar(with: scrollView.contentOffset.x)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.bounds.width < 0.1 {
            return
        }
        let selectedIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        tabBarView .scroll(to: selectedIndex, animated: false)
        selectTo(index: selectedIndex, animated: false, selectType: .scroll)
    }
    
    // MARK: QSTabBarDelegate
    public func numbersInQSTabBarView(_ tabBarView: UIView) -> Int {
        return self.numbersOfViewController
    }
    
    public func tabBarView(_ tabBarView: UIView, index: Int) -> UIView & QSTabBarItemProtocol {
        return dataSource?.tabController(self, barItemView: index) ?? QSTabBarItem()
    }
    
    public func tabBarView(_ tabBarView: UIView & QSTabBarViewProtocol, didSelectItem originIdx: Int, targetIdx: Int) {
        selectTo(index: targetIdx, animated: true, selectType: .click)
    }
    
    public func tabBarView(_ tabBarView: UIView & QSTabBarViewProtocol, didSelectItemAgain originIdx: Int, targetIdx: Int) {
        delegate?.tabController?(self, didSelectAgainTab: targetIdx, type: .click)
    }
}

extension UIViewController {
    private static var pgc_vc_status_key: Bool = false
    public var pgc_vc_status: PGCVCStatus {
        get {
            return objc_getAssociatedObject(self, &Self.pgc_vc_status_key) as? PGCVCStatus ?? PGCVCStatus.unknown
        }
        set {
            objc_setAssociatedObject(self, &Self.pgc_vc_status_key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
