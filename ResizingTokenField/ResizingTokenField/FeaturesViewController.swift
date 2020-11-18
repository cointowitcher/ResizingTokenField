//
//  FeaturesViewController.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 19/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

class FeaturesViewController: UIViewController, UITextFieldDelegate, ResizingTokenFieldDelegate {
    
    class Token: ResizingTokenFieldToken, Equatable {
        
        static func == (lhs: Token, rhs: Token) -> Bool {
            return lhs === rhs
        }
        
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tokenField: ResizingTokenField!
    @IBOutlet weak var animateSwitch: UISwitch!
    @IBOutlet weak var collapseSwitch: UISwitch!
    
    private lazy var titles: [String] = { "Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit".components(separatedBy: " ") }()
    private var randomTitle: String { return titles[Int(arc4random_uniform(UInt32(titles.count)))] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tokenField.layer.borderWidth = 1
//        tokenField.layer.borderColor = UIColor.darkGray.cgColor
        tokenField.preferredTextFieldReturnKeyType = .done
        tokenField.delegate = self
        tokenField.textFieldDelegate = self
        tokenField.shouldTextInputRemoveTokensAnimated = animateSwitch.isOn
        tokenField.shouldExpandTokensAnimated = animateSwitch.isOn
        tokenField.shouldCollapseTokensAnimated = animateSwitch.isOn

        let placeholder = "Type here…"
        tokenField.placeholder = placeholder
        tokenField.textFieldMinWidth = placeholder.width(withFont: tokenField.font)
        
        tokenField.labelText = "Tokens:"
        let tokens: [Token] = [
            Token(title: "Lorem"),
            Token(title: "Ipsum")
        ]
        
        tokenField.append(tokens: tokens)
        tokenField.hideLabel(animated: false)
        tokenField.maxHeight = 22
        tokenField.contentInsets = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterFromKeyboardNotifications()
    }
    
    // MARK: - Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tokenField.invalidateLayout()
    }
    
    // MARK: - ResizingTokenFieldDelegate
    
    func resizingTokenFieldShouldCollapseTokens(_ tokenField: ResizingTokenField) -> Bool {
        return collapseSwitch.isOn
    }
    
    func resizingTokenFieldCollapsedTokensText(_ tokenField: ResizingTokenField) -> String? {
        return "Hiding \(tokenField.tokens.count) tokens…"
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, willChangeHeight newHeight: CGFloat) {
        if animateSwitch.isOn {
            scrollView.layoutIfNeeded()
        }
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        if animateSwitch.isOn {
            UIView.animate(withDuration: tokenField.animationDuration) {
                self.scrollView.layoutIfNeeded()
            }
        }
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, configurationForDefaultCellRepresenting token: ResizingTokenFieldToken) -> DefaultTokenCellConfiguration? {
        return CustomConfiguration()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == tokenField.textField else { return true }
        guard let text = textField.text, !text.isEmpty else { return true }
        
        tokenField.append(tokens: [Token(title: text)], animated: animateSwitch.isOn)
        tokenField.text = nil
        return false
    }
    
    // MARK: - IB actions
    
    @IBAction func animateSwitchValueChanged(_ sender: UISwitch) {
        guard sender == animateSwitch else { return }
        
        tokenField.shouldTextInputRemoveTokensAnimated = sender.isOn
        tokenField.shouldCollapseTokensAnimated = sender.isOn
        tokenField.shouldExpandTokensAnimated = sender.isOn
    }
    
    @IBAction func didTapToggleLabelButton(_ sender: UIButton) {
        tokenField.isShowingLabel ? tokenField.hideLabel(animated: animateSwitch.isOn) : tokenField.showLabel(animated: animateSwitch.isOn)
    }
    
    @IBAction func didTapAddTokenButton(_ sender: UIButton) {
        tokenField.append(tokens: [Token(title: randomTitle)], animated: animateSwitch.isOn, completion: nil)
    }
    
    @IBAction func didTapAddMultipleTokensButton(_ sender: UIButton) {
        var tokens: [Token] = []
        for _ in 0...(Int(arc4random_uniform(4)) + 1) {
            tokens.append(Token(title: randomTitle))
        }

        tokenField.append(tokens: tokens, animated: animateSwitch.isOn)
    }
    
    @IBAction func didTapRemoveAllTokensButton(_ sender: UIButton) {
        tokenField.removeAllTokens(animated: animateSwitch.isOn)
    }
    
    // MARK: - Keyboard
    
    override func keyboardVisibleHeightWillChange(newHeight: CGFloat) {
        scrollView.contentInset.bottom = newHeight
        scrollView.scrollIndicatorInsets.bottom = newHeight
    }
    
}

struct CustomConfiguration: DefaultTokenCellConfiguration {
    func cornerRadius(forSelected isSelected: Bool) -> CGFloat {
        return 11
    }
    
    func borderWidth(forSelected isSelected: Bool) -> CGFloat {
        return 0
    }
    
    func borderColor(forSelected isSelected: Bool) -> CGColor {
        return UIColor.clear.cgColor
    }
    
    func textColor(forSelected isSelected: Bool) -> UIColor {
        return UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1)
    }
    
    func backgroundColor(forSelected isSelected: Bool) -> UIColor {
        return isSelected ? UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1).withAlphaComponent(0.2) : UIColor(red: 0, green: 0.808, blue: 0.081, alpha: 1).withAlphaComponent(0.1)
    }
    
    func cornerCurve(forSelected isSelected: Bool) -> CALayerCornerCurve {
        return .continuous
    }
    
    func font(forSelected isSelected: Bool) -> UIFont {
        .systemFont(ofSize: 15, weight: .semibold)
    }
}
