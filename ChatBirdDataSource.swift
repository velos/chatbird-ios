//
//  ChatBirdDataSource.swift
//  ChatBird
//
//  Created by David Rajan on 12/23/19.
//

import Foundation
import Chatto
import SendBirdSDK

class GroupChannelDataSource: ChatDataSourceProtocol {
    private let channel: SBDGroupChannel
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    var hasMoreNext: Bool = false
    var hasMorePrevious: Bool = false
    
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    private var isLoadingPrevious: Bool = false
    private var isLoadingNext: Bool = false
    
    private var oldestTimestamp: Int64 = .max
    private var newestTimestamp: Int64?
    
    private let loadingToken = LoaderItem()
    
    private var observerToken: ChannelObservervation?
    private var readObserverToken: ChannelObservervation?
    
    var pageSize: Int = 20
    
    func loadInitialMessages() {
        showLoading()
        
        channel.getPreviousMessages(byTimestamp: oldestTimestamp, limit: pageSize, reverse: false, messageType: .all, customType: nil) { [weak self] (messages, error) in
            guard let self = self else { return }
            guard let messages = messages else { return }
            
            self.prepend(messages: messages, updateType: .firstLoad)
            self.channel.markAsRead()
        }
        
        observerToken = SBDMain.addMessage(observer: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .received(_, let message):
                self.append(messages: [message])
            case .updated(_, let message):
                self.update(message: message)
            case .deleted(_, let id):
                self.remove(messageId: id)
            }
            }, forChannel: channel)
        
        readObserverToken = SBDMain.addRead(observer: { [weak self] in
            guard let self = self else { return }
            self.delegate?.chatDataSourceDidUpdate(self)
            }, forChannel: channel)
    }
    
    func loadNext() {
        
        guard !isLoadingNext, let timestamp = newestTimestamp else { return }
        isLoadingNext = true
        
        channel.getNextMessages(byTimestamp: timestamp, limit: pageSize, reverse: false, messageType: .all, customType: nil) { [weak self] (messages, error) in
            guard let self = self else { return }
            guard let messages = messages else { return }
            
            self.append(messages: messages)
            self.isLoadingNext = false
        }
    }
    
    func loadPrevious() {
        guard !isLoadingPrevious else { return }
        isLoadingPrevious = true
        
        showLoading()
        
        channel.getPreviousMessages(byTimestamp: oldestTimestamp, limit: pageSize, reverse: false, messageType: .all, customType: nil) { [weak self] (messages, error) in
            guard let self = self else { return }
            guard let messages = messages else { return }
            
            self.prepend(messages: messages, updateType: .pagination)
            self.isLoadingPrevious = false
        }
    }
    
    private func showLoading() {
        chatItems.insert(loadingToken, at: 0)
        delegate?.chatDataSourceDidUpdate(self)
    }
    
    private func hideLoading() {
        let loadingIndex = chatItems.firstIndex { $0.uid == loadingToken.uid }
        if let index = loadingIndex {
            chatItems.remove(at: index)
        }
        delegate?.chatDataSourceDidUpdate(self)
    }
    
    private func append(messages: [SBDBaseMessage]) {
        
        guard !messages.isEmpty else {
            hasMoreNext = false
            return
        }
        
        hasMoreNext = messages.count >= pageSize
        newestTimestamp = max((messages.last?.createdAt ?? 0), newestTimestamp ?? 0)
        
        chatItems.append(contentsOf: messages)
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
        
        // mark the channel as read once we load the new messages
        channel.markAsRead()
    }
    
    private func prepend(messages: [SBDBaseMessage], updateType: UpdateType) {
        hideLoading()
        
        guard !messages.isEmpty else {
            hasMorePrevious = false
            return
        }
        
        // assume that if we get back the number of messages we asked for, that there are more to fetch
        hasMorePrevious = messages.count >= pageSize
        
        oldestTimestamp = messages.first?.createdAt ?? oldestTimestamp
        newestTimestamp = max((messages.last?.createdAt ?? 0), newestTimestamp ?? 0)
        
        chatItems.insert(contentsOf: messages, at: 0)
        delegate?.chatDataSourceDidUpdate(self, updateType: updateType)
    }
    
    private func update(message: SBDBaseMessage) {
        guard let index = chatItems.firstIndex(where: { ($0 as? SBDBaseMessage)?.messageId == message.messageId }) else {
            return
        }
        
        chatItems[index] = message
        delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
    }
    
    private func remove(messageId: Int64) {
        guard let index = chatItems.firstIndex(where: { ($0 as? SBDBaseMessage)?.messageId == messageId }) else {
            return
        }
        
        chatItems.remove(at: index)
        delegate?.chatDataSourceDidUpdate(self, updateType: .messageCountReduction)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        completion(false)
    }
    
    func addTextMessage(_ text: String) {
        
        let messageIndex = chatItems.count
        let message = channel.sendUserMessage(text) { [weak self] (sentMessage, error) in
            guard let self = self else { return }
            guard let sentMessage = sentMessage else {
                fatalError("Could not create message: \(error)")
            }
            
            self.chatItems[messageIndex] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
        
        append(messages: [message])
    }
    
    func addPhotoMessage(_ image: UIImage) {
        let messageIndex = chatItems.count
        
        let data = resizeForSending(image)
        let message = channel.sendFileMessage(withBinaryData: data, filename: UUID().uuidString, type: "image/jpeg", size: UInt(data.count), data: nil) { [weak self] (fileMessage, error) in
            guard let self = self else { return }
            guard let sentMessage = fileMessage else {
                fatalError("Could not create message: \(error)")
            }
            
            print("error: \(error)")
            self.chatItems[messageIndex] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
        
        message.image = image
        append(messages: [message])
        
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    private func resizeForSending(_ image: UIImage) -> Data {
        
        let ratio = image.size.height / image.size.width
        let newSize = CGSize(width: 600, height: ratio * 600)
        
        
        return UIGraphicsImageRenderer(size: newSize)
            .jpegData(withCompressionQuality: 0.8) { context in
                image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
