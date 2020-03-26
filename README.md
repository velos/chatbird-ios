# ChatBird [![Version](https://img.shields.io/cocoapods/v/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird) [![License](https://img.shields.io/cocoapods/l/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird) [![Platform](https://img.shields.io/cocoapods/p/ChatBird.svg?style=flat)](https://cocoapods.org/pods/ChatBird)



`ChatBird` is a Swift framework that bridges the [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework) with the [Chatto framework](https://github.com/badoo/Chatto). `SendBird` is an in-app messaging platform but doesn't provide any built-in UI, and `Chatto` is one such library that provides a UI to built chat applications. However, this integration requires some work to accomplish, which is where `ChatBird` comes to the rescue!

<p align="center">
    <img src="https://github.com/velos/chatbird-ios/raw/master/ChatBird.gif" alt="ChatBird Screenshot" />
</p>

## Compatibility

ChatBird requires **iOS 12+** and is compatible with **Swift 5** projects.

## Installation

ChatBird is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ChatBird'
```

## Example

The example project is a good starting point to learn about the capabilities and usage of ChatBird. To run the example project, clone the repo, and run `pod install` from the Example directory.

## Setting up the example

ChatBird sets up the integration of your `SendBird`-enabled messaging app with `Chatto`. To use `ChatBird`: 

1. Initialize your SendBird app upon startup in `AppDelegate.swift` or other appropriate location (e.g., your root view controller): 
```swift 
ChatBirdManager.shared.initializeSendbird(with: "your-SendBird-app-id")
```

2. Connect to your SendBird instance:
```swift
ChatBirdManager.shared.connectSendBird(uuid: "SendBird-user-id", token: "optional-token-for-authentication", completion: (user, error) -> Void)
```

## Customizing the example

You may now customize ChatBird experience as desired. The default implementation will give you a working chat controller but you can subclass `ChatViewController` to provide your own input presenters and message handlers as described below.

## Usage

### Presenting the Chat View

To instantiate and present a new `ChatViewController` setup your code as follows:

```Swift
let channel: SBDGroupChannel // This is the SendBird Group Channel to present in the chat view

let chatViewController = ChatViewController()
chatViewController.setup(with: channel)
present(chatViewController, animated: true)
```

If you're following along in the example, the chat view is presented when tapping on a Group Channel in `ChatListController.swift`, but in this case we're using a segue to perform the presentation since it's setup in a Storyboard. If you're using a Storyboard be sure to call `(segue.destination as? ChatViewController).setup(with: channel)` in the `prepare(for segue:...)` function.

### Customizing the Chat View

`ChatBird` provides several defaults for the presentation of the chat view. You may subclass `ChatViewController` in your own project to customize how this appears. Override `createChatInputView()` to modify the input view (where the user types). To customize the chat bubbles override `createPresenterBuilders()`. Please refer to `ChatViewController.swift` for an example of how to setup these functions.

### Adding Message Actions

You may implement classes that conform to `MessageHandlerProtocol` to handle actions (user taps on avatar, selects message, etc). You may implement a class that conforms to `TextMessageMenuItemPresenterProtocol` to enable context menus when a user taps on a chat item. 

Be sure to reference these classes in your overridden functions as described above. Please refer to `ChatViewController.swift` for an example of how to setup these functions.

## Author

David Rajan, david@velosmobile.com

## License

**ChatBird** is available under the MIT license. See the LICENSE file for more info.

