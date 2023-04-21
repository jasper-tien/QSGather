//
//  QSTabBarView.swift
//  QSSwiftDemo
//
//  Created by tianmaotao on 2022/8/3.
//

import Foundation
import UIKit
import simd

@objc
public protocol QSTabBarViewProtocol {
    var indicatorHidden: Bool { set get }
    var indicatorAnimated: Bool { set get }
    var indicatorHeight: CGFloat { set get }
    var itemSpacing: CGFloat { set get }
    var selectIndicatorView: UIView { get }
    var contentScrollView: UIScrollView { get }
    func reloadData()
    func scroll(to index: Int, animated: Bool)
    func configDelegate(_ delegate: QSTabBarDelegate)
    func update(with progress: CGFloat, relativeProgress: CGFloat, leftIndex: Int, rightIndex: Int)
}
 
@objc
public protocol QSTabBarDelegate : AnyObject {
    func numbersInQSTabBarView(_ tabBarView: UIView) -> Int
    func tabBarView(_ tabBarView: UIView, index: Int) -> UIView & QSTabBarItemProtocol
    @objc optional func tabBarView(_ tabBarView: UIView & QSTabBarViewProtocol, willSelectItem originIdx: Int, targetIdx: Int)
    @objc optional func tabBarView(_ tabBarView: UIView & QSTabBarViewProtocol, didSelectItem originIdx: Int, targetIdx: Int)
    @objc optional func tabBarView(_ tabBarView: UIView & QSTabBarViewProtocol, didSelectItemAgain originIdx: Int, targetIdx: Int)
}

@objc
public class QSTabBarView : UIView, QSTabBarViewProtocol {
    public static let tabBarAnimatedDuration = 0.25
    private weak var delegate: QSTabBarDelegate?
    private var selectIndex: Int = 0
    private lazy var itemViews: [UIView & QSTabBarItemProtocol] = []
    
    @objc public var indicatorHidden: Bool = false
    @objc public var indicatorAnimated: Bool = true
    @objc public var indicatorHeight: CGFloat = 5
    @objc public var itemSpacing: CGFloat = 0
    
    @objc public lazy var selectIndicatorView: UIView = {
        let selectIndicatorView = UIView()
        selectIndicatorView.backgroundColor = UIColor.systemPink
        return selectIndicatorView
    }()
    
    @objc public lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.contentInsetAdjustmentBehavior = .never;
        return contentScrollView
    }()
    
    // MARK: init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: override
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentScrollView.frame = self.bounds
        updateItemsLayout()
        updateSelectIndicatorLayout()
    }
    
    // MARK: private
    
    private func setupSubviews() {
        self.addSubview(contentScrollView)
        self.addSubview(selectIndicatorView)
    }
    
    private func createAndCongigItemViews() {
        if delegate == nil {
            return
        }
        
        let itemNum = delegate?.numbersInQSTabBarView(self) ?? 0
        if itemNum == 0 {
            return
        }
        
        for index in 0..<itemNum {
            let itemView = delegate?.tabBarView(self, index: index) ?? QSTabBarItem()
            itemViews.append(itemView)
            contentScrollView.addSubview(itemView)
            
            itemView.configActionBlock { [weak self](index, tapsRequiredNumber) in
                if tapsRequiredNumber == 1 {
                    self?.itemClickAction(with: index)
                } else if tapsRequiredNumber == 1 {
                    self?.itemDoubleClickAction(with: index)
                }
            }
            
            let isHightlight: Bool = (selectIndex == index) ? true : false
            itemView.update(with: isHightlight)
            itemView.config(with: index)
        }
    }
    
    private func switchItem(with index: Int, animated: Bool, completion: ((Bool) -> Void)?) {
        if selectIndex == index || itemViews.count == 0 { return }
        let switchItmeBlock = { [weak self]() -> Void in
            self?.selectIndex = index
            self?.updateSelectIndicatorLayout()
            self?.updateItemViewHighlight(with: index)
            self?.updateItemsLayout()
        }
        if animated {
            UIView.animate(withDuration: QSTabBarView.tabBarAnimatedDuration, animations: {
                switchItmeBlock()
            }, completion: completion)
        } else {
            switchItmeBlock()
            completion?(false)
        }
    }
    
    private func updateSelectIndicatorLayout() {
        if itemViews.count > 0 {
            if let currentView = fetchTabBarItem(with: selectIndex) {
                let width: CGFloat = currentView.frame.width
                let pointX: CGFloat = currentView.frame.minX
                selectIndicatorView.frame = CGRect(x: pointX, y: self.frame.height - indicatorHeight, width: width, height: indicatorHeight)
            }
        }
    }
    
    private func updateItemsLayout() {
        var itemPointX: CGFloat = 0
        var contentSizeWidth: CGFloat = 0
        for itemView in itemViews {
            let width: CGFloat = itemView.itemWidth
            itemView.frame = CGRect(x: itemPointX, y: 0, width: width, height: self.frame.height - indicatorHeight)
            contentSizeWidth = itemPointX + width
            itemPointX = itemPointX + width + itemSpacing
        }
        if contentSizeWidth > self.frame.width {
            contentScrollView.isScrollEnabled = true
        } else {
            contentScrollView.isScrollEnabled = false
        }
        contentScrollView.contentSize = CGSize(width: contentSizeWidth, height: contentScrollView.frame.height)
    }
    
    private func updateItemViewHighlight(with index: Int) {
        if itemViews.count == 0 { return }
        for (idx, itemView) in itemViews.enumerated() {
            if index == idx {
                itemView.update(with: true)
            } else {
                itemView.update(with: false)
            }
        }
    }
    
    private func fetchTabBarItem(with index: Int) -> (UIView & QSTabBarItemProtocol)? {
        if index >= 0 && !(itemViews.isEmpty) && index < itemViews.count {
            return itemViews[Int(index)]
        }
        return nil
    }
    
    private func resetItemViews() {
        for itemView in itemViews {
            if itemView.superview != nil {
                itemView.removeFromSuperview()
            }
        }
        itemViews.removeAll()
    }
    
    // MARK: action
    private func itemClickAction(with index: Int) {
        let originIdx = self.selectIndex
        delegate?.tabBarView?(self, willSelectItem: originIdx, targetIdx: index)
        switchItem(with: index, animated: indicatorAnimated) { [weak self](animted: Bool) -> Void in
            if let weakSelf = self {
                weakSelf.delegate?.tabBarView?(weakSelf, didSelectItem: originIdx, targetIdx: index)
            }
        }
    }
    
    private func itemDoubleClickAction(with index: Int) {
        if self.selectIndex != index { return }
        delegate?.tabBarView?(self, didSelectItemAgain: index, targetIdx: index)
    }
}

extension QSTabBarView {
    
    @objc public func reloadData() {
        resetItemViews()
        createAndCongigItemViews()
        updateItemsLayout()
        updateSelectIndicatorLayout()
    }
    
    @objc public func scroll(to index: Int, animated: Bool) {
        self.switchItem(with: index, animated: animated, completion: nil)
    }
    
    @objc public func configDelegate(_ delegate: QSTabBarDelegate) {
        self.delegate = delegate
    }
    
    @objc public func update(with progress: CGFloat, relativeProgress: CGFloat, leftIndex: Int, rightIndex: Int) {
        if progress.isNaN || relativeProgress.isNaN || leftIndex < 0 || rightIndex < 0 {
            return
        }
        
        let leftView: (UIView & QSTabBarItemProtocol)? = fetchTabBarItem(with: Int(leftIndex))
        let rightView: (UIView & QSTabBarItemProtocol)? = fetchTabBarItem(with: Int(rightIndex))
        if leftView == nil || rightView == nil {
            return
        }
        
        let leftViewPointX = leftView!.frame.minX
        let rightViewPointX = rightView!.frame.minX
        let leftViewWidth = leftView!.frame.width
        let rightViewWidth = rightView!.frame.width
        
        var frame = selectIndicatorView.frame
        frame.origin.x = leftViewPointX + (rightViewPointX - leftViewPointX) * relativeProgress
        frame.size.width = leftViewWidth + (rightViewWidth - leftViewWidth) * relativeProgress;
        selectIndicatorView.frame = frame
        
        if contentScrollView.isScrollEnabled {
            let itemCount: CGFloat = CGFloat(itemViews.count)
            let offsetProgress = progress * itemCount / (itemCount - 1);
            let x = (contentScrollView.contentSize.width - contentScrollView.frame.width) * offsetProgress
            contentScrollView.contentOffset = CGPoint(x: x, y: 0)
        }
    }
}
