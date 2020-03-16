//
//  BarSegmentControl.swift
//  BetIT
//
//  Created by OSX on 8/1/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

typealias SegmentItem = (title: String, alignment: UIControl.ContentHorizontalAlignment)

struct BarSegmentControlTheme {
    var normalColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.5)
    var highlightColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var spaceBetweenControls: CGFloat = 20
    
    var normalFont: UIFont = AppFont.louisGeorgeCafe.regular(size: 14)
    var highlightFont: UIFont = AppFont.louisGeorgeCafe.bold(size: 14)
    var barThickness: CGFloat = 4.0
}

@IBDesignable
class BarSegmentControl: BaseCustomView {
    var items: [SegmentItem] = [] {
        didSet {
            reloadItems()
        }
    }
    
    private var buttons: [UIButton] = []
    
    private var stackView: UIStackView = UIStackView()
    private var barBottom: UIView = UIView()
    private var indicator: UIView = UIView()
    
    var index: Int = 0 {
        didSet {
            reloadButtons()
            reloadIndicator(animated: true)
        }
    }
    
    var selector: ((Int)->Void)? = nil
    
    var theme: BarSegmentControlTheme = BarSegmentControlTheme() {
        didSet {
            reload()
        }
    }
    
    convenience init(items: [SegmentItem]) {
        self.init()
        self.items = items
    }

    override func build() {
        super.build()
        
        self.addSubview(barBottom)
        barBottom.backgroundColor = theme.normalColor
        barBottom.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(theme.barThickness)
        }
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = theme.spaceBetweenControls
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(barBottom.snp.top)
        }
        
        indicator.backgroundColor = theme.highlightColor
        self.addSubview(indicator)
        
        reloadIndicator(animated: false)
    }
    
    func reload() {
        stackView.spacing = theme.spaceBetweenControls
        barBottom.snp.remakeConstraints {
            $0.height.equalTo(theme.barThickness)
            $0.left.right.bottom.equalToSuperview()
        }
        reloadIndicator()
        reloadButtons()
    }
    
    func reloadItems() {
        stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        buttons.removeAll()
        
        for i in 0..<items.count {
            let button = UIButton(action: #selector(onItemTapped(_:)), target: self)
            button.tag = i
            button.setTitle(items[i].title, for: .normal)
            button.contentHorizontalAlignment = items[i].alignment
            if button.tag == index {
                button.titleLabel?.font = theme.highlightFont
                button.setTitleColor(theme.highlightColor, for: .normal)
            }
            else {
                button.titleLabel?.font = theme.normalFont
                button.setTitleColor(theme.normalColor, for: .normal)
            }
            stackView.addChild(view: button)
            buttons.append(button)
        }
        reloadIndicator()
    }
    
    func reloadButtons() {
        buttons.forEach { (button) in
            if button.tag == index {
                button.titleLabel?.font = theme.highlightFont
                button.setTitleColor(theme.highlightColor, for: .normal)
            }
            else {
                button.titleLabel?.font = theme.normalFont
                button.setTitleColor(theme.normalColor, for: .normal)
            }
        }
    }
    
    func reloadIndicator(animated: Bool = false) {
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let weak_self = self else {
                return
            }
            
            weak_self.indicator.snp.remakeConstraints {
                $0.height.equalTo(weak_self.theme.barThickness)
                $0.bottom.equalToSuperview()
                if weak_self.buttons.count > 0, weak_self.index < weak_self.buttons.count {
                    $0.left.equalTo(weak_self.buttons[weak_self.index].snp.left)
                    $0.width.equalTo(weak_self.buttons[weak_self.index].snp.width)
                }
                else {
                    $0.left.equalToSuperview()
                }
                $0.bottom.equalToSuperview()
            }
            weak_self.layoutIfNeeded()
        }
    }
    
    @objc func onItemTapped(_ sender: UIButton) {
        self.index = sender.tag
        selector?(self.index)
    }
}
