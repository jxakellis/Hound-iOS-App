![Banner](https://raw.githubusercontent.com/rayhannabi/RNAlertController/master/images/banner.png) 

[![Build Status](https://img.shields.io/travis/rayhannabi/RNAlertController/master?logo=travis%20ci&logoColor=white&style=flat)](https://travis-ci.org/rayhannabi/RNAlertController)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/RNAlertController?color=blue&style=flat)
![Cocoapods](https://img.shields.io/cocoapods/v/RNAlertController?style=flat)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/rayhannabi/RNAlertController?logo=github&style=flat)
![GitHub issues](https://img.shields.io/github/issues/rayhannabi/RNAlertController?style=flat&logo=github)
![GitHub](https://img.shields.io/github/license/rayhannabi/RNAlertController?style=flat)

# RNAlertController

An easy-to-use alert framework for iOS written purely in Swift. With native look-n-feel and animations, you can add more functionalities to your alerts. 

## Features

* iOS 13 compatible, supports Dark Mode.
* Title
* Description message
* Banner image below the description message
* Multiple buttons with closure action
* Picker view
* URL Button
* Checkbox

## Requirements

* iOS 9.0+
* Xcode 11.0+
* Swift 5.0
* Objective-C 2.0 (ARC required)

## Installation

### Via Cocoapods
**RNAlertController** is available through [CocoaPods](https://cocoapods.org/pods/RNAlertController). To install the latest version, simply add the following line to your Podfile:

```ruby
# Swift 5.0 or later
pod 'RNAlertController'
```
and run `pod install` and you are ready to use the framework.

## Usage

RNAlertController is really simple to use. The following example shows how to create a simple alert with an OK button within a view controller.

### Swift
```swift
let alertController = RNAlertController(title: "Message", message: "This is a demo")
alertController.addButton(title: "Got It", type: .default)
alertController.present()
```

### Objective-C
```objc
RNAlertController *alert = [[RNAlertController alloc] initWithTitle:@"Message" 
                                                            message:@"This is a demo"];
[alert addButtonWithTitle:@"Got It" type:AlertButtonTypeDefault action:nil];
[alert presentOn:nil completion:nil];
```

You can also specify button styles when adding them.

The following example shows how to create an alert with a message and an image.

### Swift

```swift
RNAlertController(title: "Message", message: "This is a demo")
    .addButton(title: "Cancel", type: .cancel, action: nil)
    .addButton(title: "Delete", type: .destructive, action: { [weak self] in
        self?.performSomeAction()
    })
    .setBannerImage(UIImage(named: "Flag")!)
    .present()
```

### Objective-C

```objc
RNAlertController *alert = [[RNAlertController alloc] initWithTitle:@"Message"
                                                            message:@"This is a demo"];
[alert addButtonWithTitle:@"Cancel" type:AlertButtonTypeCancel action:nil];
[alert addButtonWithTitle:@"Delete" type:AlertButtonTypeDestructive action:^{
    [self performSomeAction];
}];
[alert setBannerImage:[UIImage imageNamed:@"Flag"]];
[alert presentOn:self completion:nil];
```



## Documentation

Documentation and API references can be found at [rayhannabi.github.io/RNAlertController](https://rayhannabi.github.io/RNAlertController). Also check out the wiki for detailed usage.



## Contributing

- If you **need help** or you'd like to **ask a general question**, open an issue.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.



## License

This project is available under **MIT** License. See the LICENSE file for more info.
