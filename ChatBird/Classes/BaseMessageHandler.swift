//
//  BaseMessageHandler.swift
//
//  Created by David Rajan on 1/2/20.
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
        
        guard let viewModel = viewModel as? SBDUserMessageViewModel, let datasource = (presentingVC as? ChatViewController)?.dataSource else { return }
        datasource.resendTextMessage(viewModel.textMessage)
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
