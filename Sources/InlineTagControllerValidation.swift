//
//  InlineTagControllerValidation.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import Foundation

public typealias Validation = (String) -> Bool

infix operator |>>: ExponentiativePrecedence
public func |>> (v1: @escaping Validation, v2: @escaping Validation) -> Validation {
    return { text in return v1(text) && v2(text) }
}

public class InlineTagControllerValidation {

    public class var testEmptiness: Validation {
        return { text in
            return text != ""
        }
    }

    public class var testEmailAddress: Validation {
        return { (text: String) in
            let emailRegex = "^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: text)
        }
    }

    public class var testLegnth: Validation {
        return { (text: String) in
            return text.count < 8
        }
    }

    public class func combine(v1: @escaping Validation, v2: @escaping Validation) -> Validation {
        return { (text: String) in return v1(text) && v2(text) }
    }

    public class func isValid(text: String?) -> Bool {
        if let t = text, let validation = TagConfig.itemValidation {
            return validation(t)
        } else {
            return true
        }
    }

}

// MARK: - Validation chaining operator

precedencegroup ExponentiativePrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator >>: ExponentiativePrecedence
public func >> (v1: @escaping Validation, v2: @escaping Validation) -> Validation {
    return { text in return v1(text) && v2(text) }
}
