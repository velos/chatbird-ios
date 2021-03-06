//
//  ChatBirdDataSource.swift
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
import SendBirdSDK

public class GroupChannelDataSource: ChatDataSourceProtocol {
    private let channel: SBDGroupChannel
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    public var hasMoreNext: Bool = false
    public var hasMorePrevious: Bool = false
    
    public var chatItems: [ChatItemProtocol] = []
    public weak var delegate: ChatDataSourceDelegateProtocol?
    
    private var isLoadingPrevious: Bool = false
    private var isLoadingNext: Bool = false
    
    private var oldestTimestamp: Int64 = .max
    private var newestTimestamp: Int64?
    
    private let loadingToken = LoaderItem()
    
    private var observerToken: ChannelObservervation?
    private var readObserverToken: ChannelObservervation?
    
    var pageSize: Int = 20
    
    public func loadInitialMessages() {
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
    
    public func loadNext() {
        
        guard !isLoadingNext, let timestamp = newestTimestamp else { return }
        isLoadingNext = true
        
        channel.getNextMessages(byTimestamp: timestamp, limit: pageSize, reverse: false, messageType: .all, customType: nil) { [weak self] (messages, error) in
            guard let self = self else { return }
            guard let messages = messages else { return }
            
            self.append(messages: messages)
            self.isLoadingNext = false
        }
    }
    
    public func loadPrevious() {
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
    
    public func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        completion(false)
    }
    
    public func addTextMessage(_ text: String) {
        
        let messageIndex = chatItems.count
        let message = channel.sendUserMessage(text) { [weak self] (sentMessage, error) in
            guard let self = self else { return }
            guard let sentMessage = sentMessage else {
                fatalError("Could not create message: \(error!.localizedDescription)")
            }
            
            self.chatItems[messageIndex] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
        
        append(messages: [message])
    }
    
    public func addPhotoMessage(_ image: UIImage) {
        let messageIndex = chatItems.count
        
        let data = image.resizeForSending()
        let message = channel.sendFileMessage(withBinaryData: data, filename: UUID().uuidString, type: "image/jpeg", size: UInt(data.count), data: nil) { [weak self] (fileMessage, error) in
            guard let self = self else { return }
            guard let sentMessage = fileMessage else {
                print("Could not create message: \(error!.localizedDescription)")
                return
            }

            self.chatItems[messageIndex] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
        
        message.image = image
        append(messages: [message])
        
        self.delegate?.chatDataSourceDidUpdate(self)
    }

    public func resendTextMessage(_ message: SBDUserMessage) {
        channel.resendUserMessage(with: message) { [weak self] (sentMessage, error) in
            guard let self = self, let sentMessage = sentMessage else {
                print("Could not resend message: \(error!.localizedDescription)")
                return
            }
            
            guard let index = self.chatItems.firstIndex(where: { ($0 as? SBDUserMessage)?.requestId == sentMessage.requestId }) else {
                return
            }
            
            self.chatItems[index] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
    }
    
    public func resendPhotoMessage(_ message: SBDFileMessage) {
        channel.resendFileMessage(with: message, binaryData: message.image.jpegData(compressionQuality: 1.0)) { [weak self] (sentMessage, error) in
            guard let self = self, let sentMessage = sentMessage else {
                print("Could not resend message: \(error!.localizedDescription)")
                return
            }
            guard let index = self.chatItems.firstIndex(where: { ($0 as? SBDFileMessage)?.requestId == sentMessage.requestId }) else {
                return
            }
            
            self.chatItems[index] = sentMessage
            self.delegate?.chatDataSourceDidUpdate(self)
        }
    }

}

