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
        let shouldDismiss = self.text?.count == 0
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

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[field]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["field": self.textField])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-4)-[field]-(-4)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["field": self.textField])

        self.addConstraints(hConstraints)
        self.addConstraints(vConstraints)

        self.textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)

        // Setup appearance
        self.textField.borderStyle = .none
        self.textField.textAlignment = .center
        self.textField.contentMode = .left

        self.textField.keyboardType = TagConfig.keyboardType
        self.textField.returnKeyType = TagConfig.returnKey
        self.textField.autocapitalizationType = TagConfig.autoCapitalization
        self.textField.autocorrectionType = TagConfig.autoCorrection

        set(mode: .view)
    }

    override var intrinsicContentSize: CGSize {
        var textFieldSize = self.textField.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.textField.bounds.height))
        textFieldSize.width += 10

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
            textField.backgroundColor = TagConfig.backgroundColor.edit
            textField.font = TagConfig.font.edit
            textField.textColor = TagConfig.fontColor.edit

            self.backgroundColor = TagConfig.backgroundColor.edit
            self.layer.cornerRadius = TagConfig.radius.edit

        case .view:
            textField.backgroundColor = TagConfig.backgroundColor.view
            textField.font = TagConfig.font.view
            textField.textColor = TagConfig.fontColor.view

            self.backgroundColor = TagConfig.backgroundColor.view
            self.layer.cornerRadius = TagConfig.radius.view

        case .invalid:
            textField.backgroundColor = TagConfig.backgroundColor.invalid
            textField.font = TagConfig.font.invalid
            textField.textColor = TagConfig.fontColor.invalid

            self.backgroundColor = TagConfig.backgroundColor.invalid
            self.layer.cornerRadius = TagConfig.radius.invalid
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
        if string == " " && TagConfig.skipOnWhitespace && InlineTagControllerValidation.isValid(text: self.textField.text) {
            self.delegate?.createAndSwitchToNewCell(cell: self)
        } else if string == "" && textField.text == "" {
            self.delegate?.shouldDeleteCellInFrontOfCell(cell: self)
        } else if !InlineTagControllerValidation.isValid(text: self.textField.text) {
            self.set(mode: .invalid)
            return true
        } else if InlineTagControllerValidation.isValid(text: self.textField.text) {
            self.set(mode: .edit)
            return true
        } else {
            return self.mode == .edit
        }

        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if TagConfig.skipOnReturnKey {
            if !InlineTagControllerValidation.isValid(text: textField.text) {
                return false
            }

            self.delegate?.createAndSwitchToNewCell(cell: self)
        } else {
            self.textField.resignFirstResponder()
        }

        return false
    }

    @objc func editingChanged(_ textField: UITextField) {
        delegate?.didChangeText(cell: self, text: textField.text ?? "")
        delegate?.needUpdateLayout(cell: self)
    }

    @objc func editingDidBegin(_ textField: UITextField) {
        set(mode: .edit)
    }

    @objc func editingDidEnd(_ textField: UITextField) {
        set(mode: InlineTagControllerValidation.isValid(text: textField.text) ? .view : .invalid)
        delegate?.editingDidEnd(cell: self, text: textField.text ?? "")
    }
    
}
