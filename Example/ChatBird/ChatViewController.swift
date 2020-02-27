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
import ChatBird
import Chatto
import ChattoAdditions

class GroupChannelViewController: BaseChatViewController {

    private var dataSource: GroupChannelDataSource?
    private var channel: SBDGroupChannel?
    
    func setup(with channel: SBDGroupChannel) {
        self.dataSource = GroupChannelDataSource(channel: channel)
        self.channel = channel
        self.title = channel.name.count > 0 ? channel.name : channel.membersString
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Details", style: .plain, target: self, action: #selector(showDetails))
        
        guard let channel = channel else { return }

        self.title = channel.name.count > 0 ? channel.name : channel.membersString
        chatDataSource = dataSource
        self.chatItemsDecorator = ChatBirdMessageDecorator(channel: channel)

        
    }

    @objc func showDetails() {
        performSegue(withIdentifier: "chatDetailsSegue", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataSource?.loadInitialMessages()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ChatDetailsController else { return }
        vc.channel = channel
    }

    var chatInputPresenter: AnyObject!
    override func createChatInputView() -> UIView {
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

    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: SBDUserMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: BaseMessageHandler(presentingVC: self), presentingVC: self),
            menuPresenter: ChatBirdMenuItemPresenter()
        )
        textMessagePresenter.textCellStyle = ChatBirdTextMessageCellStyle()
        textMessagePresenter.baseMessageStyle = ChatBirdBaseMessageCellStyle()

        let fileMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: SBDFileMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: FileMessageHandler(presentingVC: self), presentingVC: self)
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

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

class FileMessageHandler: MessageHandlerProtocol {
    var presentingVC: UIViewController
    
    init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
    }
    
    func userDidTapOnFailIcon(viewModel: MessageViewModelProtocol) {
        
    }
    
    func userDidTapOnAvatar(viewModel: MessageViewModelProtocol) {
        
    }
    
    func userDidTapOnBubble(viewModel: MessageViewModelProtocol) {
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
    
    func userDidBeginLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        
    }
    
    func userDidEndLongPressOnBubble(viewModel: MessageViewModelProtocol) {
        
    }
    
    func userDidSelectMessage(viewModel: MessageViewModelProtocol) {
        
    }
    
    func userDidDeselectMessage(viewModel: MessageViewModelProtocol) {
        
    }
}
