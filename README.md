# InlineTagController
Inline tag creation, validation and editing. Completely configurable and supports multiple custom validation blocks.

# Original Source
This class is a direct copy of TFBubbleItUp https://github.com/thefuntasty/TFBubbleItUp, written in Swift 3.0 from scratch. All primary credit is assigned to the original author. 

# Examples

## Inline creation, editing and deletion

![TagCreation](https://user-images.githubusercontent.com/1012880/28084762-8681d8ba-662e-11e7-8569-fd9ea9d31bf6.GIF)

## Validation

![TagValidation](https://user-images.githubusercontent.com/1012880/28084776-8fa44ee6-662e-11e7-9cb5-3e0760725f70.GIF)

## Usage
### Setup

Add a UIView as a subview and set its class to `InputTagController` in the identity inspector. Provide position constraints and omit a height constraint. Open the Size inspector and set `Intrinsic Size` to `Placeholder`. InputTagController will resize to fit its content. 

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

The above two examples are included with **InlineTagControllerValidation** as class vars. To set a validation, update the **itemValidation** property on **InlineTagControllerConfiguration**:

```swift
InlineTagControllerConfiguration.itemValidation = someValidation |>> InlineTagControllerValidation.testEmailAddress
```

We can chain multiple validations together using the custom **|>>** operator. All validations must pass in order for the tag to be accepted as valid. 

Additionally, you can control the allowed number of tags by settings the **numberOfTags** property on **InlineTagControllerConfiguration** to one of the following values: 

```swift
public enum NumberOfTags {
    case unlimited
    case quantity(Int)
}

InlineTagControllerConfiguration.numberOfTags = .quantity(3)
```

When the tag limit is reached, the text fields will no longer activate when tapping the view. Instead, the last tag will transition to the **edit** state. Setting to **.unlimited** will auto-resize the view based on the intrinsic content size. 

### Configuration

InlineTagController can be fully customized with the **InlineTagControllerConfiguration** class. Below are all available properties:

```swift
/// Background color for cell in normal state
public static var viewBackgroundColor: UIColor = UIColor(red: 0.918, green: 0.933, blue: 0.949, alpha: 1.00)

/// Background color for cell in edit state
public static var editBackgroundColor: UIColor = UIColor.whiteColor()

/// Background color for cell in invalid state
public static var invalidBackgroundColor: UIColor = UIColor.whiteColor()

/// Font for cell in normal state
public static var viewFont: UIFont = UIFont.systemFontOfSize(12.0)

/// Font for cell in edit state
public static var editFont: UIFont = UIFont.systemFontOfSize(12.0)

/// Font for cell in invalid state
public static var invalidFont: UIFont = UIFont.systemFontOfSize(12.0)

/// Font color for cell in view state
public static var viewFontColor: UIColor = UIColor(red: 0.353, green: 0.388, blue: 0.431, alpha: 1.00)

/// Font color for cell in edit state
public static var editFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)

/// Font color for cell in invalid state
public static var invalidFontColor: UIColor = UIColor(red: 0.510, green: 0.553, blue: 0.596, alpha: 1.00)

/// Corner radius for cell in view state
public static var viewCornerRadius: Float = 2.0

/// Corner radius for cell in edit state
public static var editCornerRadius: Float = 2.0

/// Corner radius for cell in invalid state
public static var invalidCornerRadius: Float = 2.0

/// Height for item
public static var cellHeight: Float = 25.0

/// View insets
public static var inset: UIEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)

/// Interitem spacing
public static var interitemSpacing: CGFloat = 5.0

/// Line spacing
public static var lineSpacing: CGFloat = 5.0

/// Keyboard type
public static var keyboardType: UIKeyboardType = UIKeyboardType.EmailAddress

/// Keyboard return key
public static var returnKey: UIReturnKeyType = UIReturnKeyType.Done

/// Field auto-capitalization type
public static var autoCapitalization: UITextAutocapitalizationType = UITextAutocapitalizationType.None

/// Field auto-correction type
public static var autoCorrection: UITextAutocorrectionType = UITextAutocorrectionType.No

/// If true it creates new item when user types whitespace
public static var skipOnWhitespace: Bool = true

/// If true it creates new item when user press the keyboards return key. Otherwise resigns first responder
public static var skipOnReturnKey: Bool = false

/// Number of items that could be written
public static var numberOfItems: NumberOfItems = .Unlimited

/// Item has to pass validation before it can be bubbled
public static var itemValidation: Validation? = nil
```

## TO-DO

- Compile in Swift 3.2 and Swift 4.0
- Replace **InlineTagControllerConfiguration** with a protocol; allow this to be passed in for easier custom configuration.
- Add this repo to CocoaPods

## Requirements

InlineTagController uses Swift 3.1. Target deployment iOS 9.0 and higher.

## Installation

Download or clone the repo directly. If using Carthage, add this line to your Carfile: 

```swift
github "kylebegeman/InlineTagController" ~> 1.0
```

## Author

**Original**: Ales Kocur, ales@thefuntasty.com    
**Updated by**: Kyle Begeman, kylebegeman@gmail.com     

## License

InlineTagController is available under the MIT license. See the LICENSE file for more info.
