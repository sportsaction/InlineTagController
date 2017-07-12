//
//  InlineTagControllerConfiguration.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import Foundation
import UIKit

internal class Config {
    static let instance = Config()
    private init() {
        configuration = DefaultConfiguration()
    }

    var configuration: InlineTagConfigurable
    func set(config: InlineTagConfigurable) {
        self.configuration = config
    }
}

public typealias ColorCollection = (view: UIColor, edit: UIColor, invalid: UIColor, placeholder: UIColor?)
public typealias FontCollection = (view: UIFont, edit: UIFont, invalid: UIFont, placeholder: UIFont)
public typealias ValueCollection = (view: CGFloat, edit: CGFloat, invalid: CGFloat)

public enum NumberOfTags {
    case unlimited
    case quantity(Int)
}

public class DefaultConfiguration: InlineTagConfigurable {}
public let TagConfig = Config.instance.configuration

public protocol InlineTagConfigurable {
    var backgroundColor: ColorCollection { get }
    var fontColor: ColorCollection { get }
    var font: FontCollection { get }
    var radius: ValueCollection { get }

    var cellHeight: Float { get }
    var inset: UIEdgeInsets { get }
    var interitemSpacing: CGFloat { get }
    var lineSpacing: CGFloat { get }
    var keyboardType: UIKeyboardType { get }
    var returnKey: UIReturnKeyType { get }
    var autoCapitalization: UITextAutocapitalizationType { get }
    var autoCorrection: UITextAutocorrectionType { get }
    var skipOnWhitespace: Bool { get }
    var skipOnReturnKey: Bool { get }
    var placeholderText: String { get }
    var numberOfTags: NumberOfTags { get }
    var itemValidation: Validation? { get }
}

extension InlineTagConfigurable {
    public var backgroundColor: ColorCollection {
        return (view: UIColor.blue, edit: UIColor.white, invalid: UIColor.red, placeholder: nil)
    }
    public var fontColor: ColorCollection {
        return (view: UIColor.white, edit: UIColor.darkText, invalid: UIColor.white, placeholder: UIColor.gray)
    }
    public var radius: ValueCollection {
        return (view: 8.0, edit: 8.0, invalid: 8.0)
    }
    public var font: FontCollection {
        let font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
        let phFont = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightLight)
        return (view: font, edit: font, invalid: font, placeholder: phFont)
    }

    public var cellHeight: Float { return 20.0 }
    public var inset: UIEdgeInsets { return UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4) }
    public var interitemSpacing: CGFloat { return 5.0 }
    public var lineSpacing: CGFloat { return 5.0 }
    public var keyboardType: UIKeyboardType { return .default }
    public var returnKey: UIReturnKeyType { return .done }
    public var autoCapitalization: UITextAutocapitalizationType { return .none }
    public var autoCorrection: UITextAutocorrectionType { return .no }
    public var skipOnWhitespace: Bool { return true }
    public var skipOnReturnKey: Bool { return true }
    public var placeholderText: String { return "Add tags..." }
    public var numberOfTags: NumberOfTags { return .unlimited }
    public var itemValidation: Validation? { return InlineTagControllerValidation.testEmptiness }
}
