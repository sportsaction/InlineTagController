# InlineTagController

![Github release version](https://img.shields.io/github/release/kylebegeman/InlineTagController.svg)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![GitHub contributors](https://img.shields.io/github/contributors/kylebegeman/InlineTagController.svg)]()

Inline tag creation, validation and editing. Completely configurable and supports multiple custom validation blocks.

# Original Source
This class is a direct copy of TFBubbleItUp https://github.com/thefuntasty/TFBubbleItUp, written in Swift 3.0 from scratch. All primary credit is assigned to the original author. 

# Examples

## Inline creation, editing and deletion

![TagCreation](https://user-images.githubusercontent.com/1012880/28084762-8681d8ba-662e-11e7-8569-fd9ea9d31bf6.GIF)

## Validation

![TagValidation](https://user-images.githubusercontent.com/1012880/28084776-8fa44ee6-662e-11e7-9cb5-3e0760725f70.GIF)

# Usage
### Setup

Add a UIView as a subview and set its class to `InputTagController` in the identity inspector. Provide position constraints and omit a height constraint. Open the Size inspector and set `Intrinsic Size` to `Placeholder`. InputTagController will resize to fit its content. 

## IMPORTANT
You must call setConfiguration() in order for the class to work correctly. Pass in any class that conforms to **InlineTagConfigurable** or pass in nothing to use the supplied default configuration. See below for more info on InlineTagConfigurable and its properties. 

Add existing tags with the setTags method:

```swift
tagController.setTags(["Some", "Tags", "#indeed"])
```

### Validation

InlineTagController is completely customizable, and that includes providing text validation before a tag is created. A validation block is defined by the following typealias:

```swift
public typealias Validation = (String) -> Bool
```

Your custom validations can either be functions or properties. The validation block accepts a String parameter (the tag text) and returns a Bool indicating if the text is valid or not. Validations should not be overly complex; you can chain multiple validations together with a provided custom operator (see below). 

A simple example that validates the text is not empty: 

```swift
var testEmptiness: Validation {
    return { (text: String) in
        return text != ""
    }
}
```

Another example for email validation:

```swift
var testEmailAddress: Validation {
    return { (text: String) in
        let emailRegex = "^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: text)
    }
}
```

The above two examples are included with **InlineTagControllerValidation** as class vars. Testing for empty strings is the default validation provided by **DefaultConfiguration**. You can add custom validation to your own configuration class comforming to **InlineTagConfigurable**.

```swift
public var itemValidation = someValidation |>> InlineTagControllerValidation.testEmailAddress
```

We can chain multiple validations together using the custom **|>>** operator. All validations must pass in order for the tag to be accepted as valid. 

Additionally, you can control the allowed number of tags by settings the **numberOfTags** property on your **InlineTagConfigurable** conforming class. You can choose between the following two values: 

```swift
public enum NumberOfTags {
    case unlimited
    case quantity(Int)
}

public var numberOfTags = .quantity(3)
```

When the tag limit is reached, the text fields will no longer activate when tapping the view. Instead, the last tag will transition to the **edit** state. Setting to **.unlimited** will auto-resize the view based on the intrinsic content size. 

### Delegates

Similar to any text field, **InlineTagControllerDelegate** gives you access to the real time text while typing new tags, and each final tag once created (will not be called if validation fails)

```swift
public protocol InlineTagControllerDelegate: class {
    func inlineTagController(_ controller: InlineTagController, didFinishEditing text: String)
    func inlineTagController(_ controller: InlineTagController, didChange text: String)
}
```

### Configuration

InlineTagController can be fully customized by creating a class or struct that conforms to **InlineTagConfigurable**. YOU MUST make the following call, with or without a custom configuration, in order for the tagging to work properly. 

```swift
let config = CustomConfig(...)
setConfiguration(config)
```

Passing in your custom configuration will assign it to the class, passing nothing will automatically asign the default provided by InlineTagController. Below is the declaration for **InlineTagConfigurable**:

```swift
public protocol InlineTagConfigurable {
    var backgroundColor: ColorCollection { get } // Background colors for all states
    var fontColor: ColorCollection { get } // Font color for all states
    var font: FontCollection { get } // Font for all states
    var radius: ValueCollection { get } // Corner radius for all states

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
```

We use a basic typealias to manage collections of values for multiple states. 

```swift
public typealias ColorCollection = (view: UIColor, edit: UIColor, invalid: UIColor, placeholder: UIColor?)
public typealias FontCollection = (view: UIFont, edit: UIFont, invalid: UIFont, placeholder: UIFont)
public typealias ValueCollection = (view: CGFloat, edit: CGFloat, invalid: CGFloat)
```

Each property of the tuple represents a state of the tag cell.

**view** - the appearance of a created and valid tag   
**edit** - the appearance of a tag being created/edited   
**invalid** - the appearance of a tag that is invalid   
**placeholder** - not a state, but requires values for font and color   

## TO-DO

- Compile in Swift 3.2 and Swift 4.0
- Replace **InlineTagControllerConfiguration** with a protocol; allow this to be passed in for easier custom configuration.

## Requirements

InlineTagController uses Swift 3.1. Target deployment iOS 9.0 and higher.

## Installation

### Swift Package Manager
To add InlineTagController to a [Swift Package Manager](https://swift.org/package-manager/) based project, add:

```swift
.Package(url: "https://github.com/kylebegeman/InlineTagController.git", majorVersion: 0, minor: 1),
```
to your `Package.swift` files `dependencies` array.

### Carthage
If you're using [Carthage](https://github.com/Carthage/Carthage) you can add InlineTagController by updating your `Cartfile`: 

```swift
github "kylebegeman/InlineTagController" ~> 0.1
```

## Author

**Original**: Ales Kocur, ales@thefuntasty.com    
**Updated by**: Kyle Begeman, kylebegeman@gmail.com     

## License

InlineTagController is available under the MIT license. See the LICENSE file for more info.
