//
//  InlineTagCell.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import UIKit

class TagTextField: UITextField {
    override func deleteBackward() {
        let shouldDismiss = self.text?.characters.count == 0
        super.deleteBackward()

        if shouldDismiss {
            _ = self.delegate?.textField!(self, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
        }
    }
}

public enum InlineTagMode {
    case edit
    case view
    case invalid
}

protocol InlineTagCellDelegate: class {
    func didChangeText(cell: InlineTagCell, text: String)
    func needUpdateLayout(cell: InlineTagCell)
    func createAndSwitchToNewCell(cell: InlineTagCell)
    func editingDidEnd(cell: InlineTagCell, text: String)
    func shouldDeleteCellInFrontOfCell(cell: InlineTagCell)
}

class InlineTagCell: UICollectionViewCell, UITextFieldDelegate {

    weak var delegate: InlineTagCellDelegate?

    var textField: TagTextField!
    var mode: InlineTagMode = .view

    class var identifier: String {
        return "InlineTagCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true

        self.textField = TagTextField()
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.delegate = self
        self.addSubview(self.textField)

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[field]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["field": self.textField])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-4)-[field]-(-4)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["field": self.textField])

        self.addConstraints(hConstraints)
        self.addConstraints(vConstraints)

        self.textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)

        // Setup appearance
        self.textField.borderStyle = .none
        self.textField.textAlignment = .center
        self.textField.contentMode = .left

        self.textField.keyboardType = InlineTagControllerConfiguration.keyboardType
        self.textField.returnKeyType = InlineTagControllerConfiguration.returnKey
        self.textField.autocapitalizationType = InlineTagControllerConfiguration.autoCapitalization
        self.textField.autocorrectionType = InlineTagControllerConfiguration.autoCorrection

        set(mode: .view)
    }

    override var intrinsicContentSize: CGSize {
        var textFieldSize = self.textField.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.textField.bounds.height))
        textFieldSize.width += 20

        return textFieldSize
    }

    override func becomeFirstResponder() -> Bool {
        self.textField.becomeFirstResponder()
        self.set(mode: .edit)

        return true
    }

    override func resignFirstResponder() -> Bool {
        self.textField.resignFirstResponder()

        return true
    }

    func set(mode: InlineTagMode) {
        var m = mode

        if self.textField.text == "" {
            m = .edit
        }

        switch m {
        case .edit:
            textField.backgroundColor = InlineTagControllerConfiguration.editBackgroundColor
            textField.font = InlineTagControllerConfiguration.editFont
            textField.textColor = InlineTagControllerConfiguration.editFontColor

            self.backgroundColor = InlineTagControllerConfiguration.editBackgroundColor
            self.layer.cornerRadius = CGFloat(InlineTagControllerConfiguration.editCornerRadius)

        case .view:
            textField.backgroundColor = InlineTagControllerConfiguration.viewBackgroundColor
            textField.font = InlineTagControllerConfiguration.viewFont
            textField.textColor = InlineTagControllerConfiguration.viewFontColor

            self.backgroundColor = InlineTagControllerConfiguration.viewBackgroundColor
            self.layer.cornerRadius = CGFloat(InlineTagControllerConfiguration.viewCornerRadius)

        case .invalid:
            textField.backgroundColor = InlineTagControllerConfiguration.invalidBackgroundColor
            textField.font = InlineTagControllerConfiguration.invalidFont
            textField.textColor = InlineTagControllerConfiguration.invalidFontColor

            self.backgroundColor = InlineTagControllerConfiguration.invalidBackgroundColor
            self.layer.cornerRadius = CGFloat(InlineTagControllerConfiguration.invalidCornerRadius)
        }

        self.mode = mode
    }
    
    func configure(with tag: Tag) {
        self.textField.text = tag.text
        self.set(mode: InlineTagControllerValidation.isValid(text: textField.text) ? .view : .invalid)
    }
}

// MARK:- UITextField delegate

extension InlineTagCell {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " && InlineTagControllerConfiguration.skipOnWhitespace && InlineTagControllerValidation.isValid(text: self.textField.text) {
            self.delegate?.createAndSwitchToNewCell(cell: self)
        } else if string == "" && textField.text == "" {
            self.delegate?.shouldDeleteCellInFrontOfCell(cell: self)
        } else {
            return self.mode == .edit
        }

        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if InlineTagControllerConfiguration.skipOnReturnKey {
            if !InlineTagControllerValidation.isValid(text: textField.text) {
                return false
            }

            self.delegate?.createAndSwitchToNewCell(cell: self)
        } else {
            self.textField.resignFirstResponder()
        }

        return false
    }

    func editingChanged(_ textField: UITextField) {
        delegate?.didChangeText(cell: self, text: textField.text ?? "")
        delegate?.needUpdateLayout(cell: self)
    }

    func editingDidBegin(_ textField: UITextField) {
        set(mode: .edit)
    }

    func editingDidEnd(_ textField: UITextField) {
        set(mode: InlineTagControllerValidation.isValid(text: textField.text) ? .view : .invalid)
        delegate?.editingDidEnd(cell: self, text: textField.text ?? "")
    }
    
}
