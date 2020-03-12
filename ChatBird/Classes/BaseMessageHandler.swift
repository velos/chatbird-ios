//
//  BaseMessageHandler.swift
//  ChatBird
//
//  The MIT License (MIT)
//
//  Copyright (c) 2020 Velos Mobile LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Chatto
import ChattoAdditions

public protocol MessageHandlerProtocol {
    var presentingVC: UIViewController { get set }
    func userDidTapOnFailIcon(viewModel: MessageViewModelProtocol)
    func userDidTapOnAvatar(viewModel: MessageViewModelProtocol)
    func userDidTapOnBubble(viewModel: MessageViewModelProtocol)
    func userDidBeginLongPressOnBubble(viewModel: MessageViewModelProtocol)
    func userDidEndLongPressOnBubble(viewModel: MessageViewModelProtocol)
    func userDidSelectMessage(viewModel: MessageViewModelProtocol)
    func userDidDeselectMessage(viewModel: MessageViewModelProtocol)
}

open class BaseMessageHandler: MessageHandlerProtocol {
    public var presentingVC: UIViewController

    public init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
    }

    public func userDidTapOnFailIcon(viewModel: MessageViewModelProtocol) {
        print("userDidTapOnFailIcon")
    }

    public func userDidTapOnAvatar(viewModel: MessageViewModelProtocol) {
        print("userDidTapOnAvatar")
    }

    public func userDidTapOnBubble(viewModel: MessageViewModelProtocol) {
        print("userDidTapOnBubble")
    }

    public func userDidBeginLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        print("userDidBeginLongPressOnBubble")
    }

    public func userDidEndLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        print("userDidEndLongPressOnBubble")
    }

    public func userDidSelectMessage(viewModel: MessageViewModelProtocol) {
        print("userDidSelectMessage")
    }

    public func userDidDeselectMessage(viewModel: MessageViewModelProtocol) {
        print("userDidDeselectMessage")
    }
}
