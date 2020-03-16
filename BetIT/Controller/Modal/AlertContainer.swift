//
//  AlertContainer.swift
//  BetIT
//
//  Created by OSX on 8/6/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

typealias AlertCompletion = (_ index: Int) -> Void
class AlertContainer: BaseCustomView {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var stackButtons: UIStackView!
    var titles: [String] = [] {
        didSet {
            updateButtons()
        }
    }
    
    var completion: AlertCompletion? = nil
    
    override func build() {
        super.build()
        
        self.translatesAutoresizingMaskIntoConstraints = false

    }
    
    func updateButtons() {
        guard let stackButtons = stackButtons, titles.count > 0 else {
            return
        }
        
        stackButtons.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for i in 0..<titles.count {
            if i == titles.count - 1 {
                addButton(title: titles[i], index: i, highlight: true)
            }
            else {
                addButton(title: titles[i], index: i, highlight: false)
            }
        }
    }
    
    func addButton(title: String, index: Int, highlight: Bool = false) {
        let button = UIButton(action: #selector(onButtonTapped(_:)), target: self)
        button.tag = index
        button.backgroundColor = .white
        button.setTitleColor(.darkBlue, for: .normal)
        button.setTitle(title, for: .normal)
        if highlight {
            button.titleLabel?.font = .bold(size: 18)
        }
        else {
            button.titleLabel?.font = .regular(size: 18)
        }
        stackButtons.addArrangedSubview(button)
    }
    
    
    @objc
    func onButtonTapped(_ sender: UIButton) {
        self.completion?(sender.tag)
    }
    
    class func create(with title: String, message: String, buttonTitles: [String], completion: AlertCompletion? = nil) -> AlertContainer? {
        let view = Bundle.main.loadNibNamed("AlertContainer", owner: nil, options: nil)?.first as? AlertContainer
        view?.lblTitle?.text = title
        view?.lblMessage?.text = message
        view?.lblMessage.setLineSpacing(lineHeightMultiple: 1.4, alignment: .center)
        view?.titles = buttonTitles
        view?.completion = completion
        return view
    }
}
