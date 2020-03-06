# ChatBird [![Version](https://img.shields.io/cocoapods/v/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird) [![License](https://img.shields.io/cocoapods/l/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird) [![Platform](https://img.shields.io/cocoapods/p/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird)

`ChatBird` is a Swift framework that bridges the [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework) with the [Chatto framework](https://github.com/badoo/Chatto). `SendBird` is an in-app messaging platform but doesn't provide any built-in UI, and `Chatto` is one such library that provides a UI to built chat applications. However, this integration requires some work to accomplish, which is where `ChatBird` comes to the rescue!

## Usage

ChatBird sets up the integration of your `SendBird`-enabled messaging app with `Chatto`. To use `ChatBird`: 

1. Initialize your SendBird app upon startup in `AppDelegate.swift` or other appropriate location (e.g., your root view controller): 
```swift 
ChatBirdManager.shared.initializeSendbird(with: "your-SendBird-app-id")
```

2. Connect to your SendBird instance:
```swift
ChatBirdManager.shared.connectSendBird(uuid: "SendBird-user-id", token: "optional-token-for-authentication", completion: (user, error) -> Void)
```

3. Customize your ChatBird experience as desired. The default implementation will give you a working chat controller but you can subclass `ChatViewController` to provide your own input presenters and message handlers.

## Example

The example project is a good starting point to learn about the capabilities and usage of ChatBird. To run the example project, clone the repo, and run `pod install` from the Example directory.

## Requirements

## Installation

ChatBird is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ChatBird'
```

## Author

David Rajan, david@velosmobile.com

## License

ChatBird is available under the MIT license. See the LICENSE file for more info.
# chatbird-ios
