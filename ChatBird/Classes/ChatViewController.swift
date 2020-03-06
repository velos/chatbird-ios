//
//  ChatViewController.swift
//  ChatBird_Example
//
//  Created by David Rajan on 12/31/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AVKit
import WebKit
import SendBirdSDK
import Chatto
import ChattoAdditions

/// Default ChatBird implementation of BaseChatViewController.
/// The SendBird data source, basic presenters, and message handlers have been provided.
/// This class can be used as-is in your app or may be subclassed and customized.
open class ChatViewController: BaseChatViewController {

    /// Points to the SendBird data source we are using
    public var dataSource: GroupChannelDataSource?
    
    /// SendBird channel to use
    public var channel: SBDGroupChannel?
    
    /// Set these if you want a custom message handler, otherwise the default implementation will be used
    public var textMessageHandler: MessageHandlerProtocol?
    public var fileMessageHandler: MessageHandlerProtocol?
    
    
    /// Provide the SendBird channel and (optionally) message handlers when configuring this class
    open func setup(with channel: SBDGroupChannel, textMessageHandler: MessageHandlerProtocol? = nil, fileMessageHandler: MessageHandlerProtocol? = nil) {
        self.dataSource = GroupChannelDataSource(channel: channel)
        self.channel = channel
        self.textMessageHandler = textMessageHandler
        self.fileMessageHandler = fileMessageHandler
        self.title = channel.name.count > 0 ? channel.name : channel.membersString
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let channel = channel else { return }

        self.title = channel.name.count > 0 ? channel.name : channel.membersString
        chatDataSource = dataSource
        self.chatItemsDecorator = ChatBirdMessageDecorator(channel: channel)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataSource?.loadInitialMessages()
    }

    /// Sets up the default chat bar at the bottom of the chat view, override this to create your own.
    /// You can create a custom ChatInputBar following the guidance at: https://github.com/badoo/Chatto/issues/148
    public var chatInputPresenter: AnyObject!
    override open func createChatInputView() -> UIView {
        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.font = UIFont.systemFont(ofSize: 14)
        appearance.textInputAppearance.placeholderFont = UIFont.systemFont(ofSize: 14)
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
        self.chatInputPresenter = BasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
        chatInputView.maxCharactersCount = 1000
        return chatInputView
    }

    private func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        items.append(self.createPhotoInputItem())
        return items
    }

    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource?.addTextMessage(text)
        }
        return item
    }

    private func createPhotoInputItem() -> PhotosChatInputItem {
        let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] image, _ in
            self?.dataSource?.addPhotoMessage(image)
        }
        return item
    }

    /// Default implementation of message presenters.
    /// Override this to customize how your chat view elements look/behave.
    override open func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: SBDUserMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: textMessageHandler ?? BaseMessageHandler(presentingVC: self), presentingVC: self),
            menuPresenter: ChatBirdMenuItemPresenter()
        )
        textMessagePresenter.textCellStyle = ChatBirdTextMessageCellStyle()
        textMessagePresenter.baseMessageStyle = ChatBirdBaseMessageCellStyle()

        let fileMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: SBDFileMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: fileMessageHandler ?? FileMessageHandler(presentingVC: self), presentingVC: self)
        )
        fileMessagePresenter.baseCellStyle = ChatBirdBaseMessageCellStyle()

        return [
            MessageType.text.rawValue: [textMessagePresenter],
            MessageType.photo.rawValue: [fileMessagePresenter],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
            NameModel.chatItemType: [NamePresenterBuilder()],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
            LoaderItem.chatItemType: [LoaderPresenterBuilder()]
        ]
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

/// Implement your own `TextMessageMenuItemPresenterProtocol` to enable context menus for your chat items.
class ChatBirdMenuItemPresenter: TextMessageMenuItemPresenterProtocol {
    func shouldShowMenu(for text: String, item: MessageModelProtocol) -> Bool {
        return false
    }

    func canPerformMenuControllerAction(_ action: Selector, for text: String, item: MessageModelProtocol) -> Bool {
        return false
    }

    func performMenuControllerAction(_ action: Selector, for text: String, item: MessageModelProtocol) {
        return
    }
}

/// Default message handler for file messages.
/// Implement your own `MessageHandlerProtocol` to customize these actions and pass this in to the `setup()` function
public class FileMessageHandler: MessageHandlerProtocol {
    public var presentingVC: UIViewController
    
    init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
    }
    
    public func userDidTapOnFailIcon(viewModel: MessageViewModelProtocol) {
        
    }
    
    public func userDidTapOnAvatar(viewModel: MessageViewModelProtocol) {
        
    }
    
    public func userDidTapOnBubble(viewModel: MessageViewModelProtocol) {
        guard let viewModel = viewModel as? SBDFileMessageViewModel, let message = viewModel.photoMessage as? SBDFileMessage else { return }
        
        if message.type.hasPrefix("image") {
            let vc = ImageZoomViewController()
            vc.image = message.image
            vc.modalPresentationStyle = .fullScreen
            presentingVC.present(vc, animated: true, completion: nil)
        }
        else if message.type.hasPrefix("video") || message.type.hasPrefix("audio") {
            guard let url = URL(string: message.url) else { return }
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            presentingVC.present(vc, animated: true) {
                player.play()
            }
        }
        else {
            guard let url = URL(string: message.url) else { return }
            let vc = UIViewController()
            let webView = WKWebView(frame: vc.view.frame)
            vc.view = webView
            presentingVC.present(vc, animated: true) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    public func userDidBeginLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        
    }
    
    public func userDidEndLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        
    }
    
    public func userDidSelectMessage(viewModel: MessageViewModelProtocol) {
        
    }
    
    public func userDidDeselectMessage(viewModel: MessageViewModelProtocol) {
        
    }
}
