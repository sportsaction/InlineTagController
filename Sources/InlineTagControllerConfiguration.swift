//
//  InlineTagControllerConfiguration.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import Foundation
import UIKit

public enum NumberOfTags {
    case unlimited
    case quantity(Int)
}

public class InlineTagControllerConfiguration {
    public static var viewBackgroundColor: UIColor = UIColor(red: 0.14, green: 0.32, blue: 0.62, alpha: 1.00)
    public static var editBackgroundColor: UIColor = UIColor.white
    public static var invalidBackgroundColor: UIColor = UIColor(red:0.63, green:0.16, blue:0.10, alpha:1.00)

    public static var viewFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
    public static var editFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
    public static var invalidFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
    public static var placeholderFont: UIFont = UIFont.systemFont(ofSize: 18.0)

    public static var viewFontColor: UIColor = UIColor.white
    public static var editFontColor: UIColor = UIColor.black
    public static var invalidFontColor: UIColor = UIColor.white
    public static var placeholderFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)

    public static var viewCornerRadius: Float = 8.0
    public static var editCornerRadius: Float = 8.0
    public static var invalidCornerRadius: Float = 8.0

    public static var cellHeight: Float = 22.0
    public static var inset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    public static var interitemSpacing: CGFloat = 5.0
    public static var lineSpacing: CGFloat = 5.0
    public static var keyboardType: UIKeyboardType = .emailAddress
    public static var returnKey: UIReturnKeyType = .done
    public static var autoCapitalization: UITextAutocapitalizationType = .none
    public static var autoCorrection: UITextAutocorrectionType = .no

    public static var skipOnWhitespace: Bool = true
    public static var skipOnReturnKey: Bool = false

    public static var numberOfTags: NumberOfTags = .unlimited
    public static var itemValidation: Validation?
}

