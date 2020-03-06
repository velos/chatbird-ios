//
//  SBDMain+Observers.swift
//  ChatBird
//
//  Created by David Rajan on 12/30/19.
//

import Foundation
import SendBirdSDK

public enum MessageEvent {
    case received(channel: SBDBaseChannel, message: SBDBaseMessage)
    case updated(channel: SBDBaseChannel, message: SBDBaseMessage)
    case deleted(channel: SBDBaseChannel, id: Int64)
}

public typealias ChannelObservervation = UUID

private class ChannelDelegate: NSObject, SBDChannelDelegate {

    fileprivate let uuid: UUID
    private let channelFilter: String?

    private let typingStatusUpdated: () -> Void
    private let readReceiptUpdated: () -> Void
    private let messagesUpdated: (MessageEvent) -> Void
    private let userUpdated: (SBDGroupChannel, SBDUser) -> Void

    init(uuid: UUID, channelFilter: String? = nil, typingStatusUpdated: @escaping () -> Void = { }, readReceiptUpdated: @escaping () -> Void = { }, messagesUpdated: @escaping (MessageEvent) -> Void = { _ in }, userUpdated: @escaping (SBDGroupChannel, SBDUser) -> Void = { _, _ in }) {
        self.uuid = uuid
        self.channelFilter = channelFilter
        self.typingStatusUpdated = typingStatusUpdated
        self.readReceiptUpdated = readReceiptUpdated
        self.messagesUpdated = messagesUpdated
        self.userUpdated = userUpdated
    }

    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        typingStatusUpdated()
    }

    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        readReceiptUpdated()
    }

    func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        messagesUpdated(.updated(channel: sender, message: message))
    }

    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        messagesUpdated(.deleted(channel: sender, id: messageId))
    }

    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        messagesUpdated(.received(channel: sender, message: message))
    }

    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        userUpdated(sender, user)
    }

    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        guard channelFilter == nil || sender.channelUrl == channelFilter else { return }
        userUpdated(sender, user)
    }
}

extension SBDMain {

    static private var delegates: [ChannelDelegate] = []

    public static func addRead(observer: @escaping () -> Void, forChannel channel: SBDBaseChannel? = nil) -> ChannelObservervation {
        let uuid = UUID()
        let delegate = ChannelDelegate(uuid: uuid, channelFilter: channel?.channelUrl, readReceiptUpdated: observer)
        delegates.append(delegate)
        SBDMain.add(delegate, identifier: uuid.uuidString)
        return uuid
    }

    public static func addMessage(observer: @escaping (MessageEvent) -> Void, forChannel channel: SBDBaseChannel? = nil) -> ChannelObservervation {
        let uuid = UUID()
        let delegate = ChannelDelegate(uuid: uuid, channelFilter: channel?.channelUrl, messagesUpdated: observer)
        delegates.append(delegate)
        SBDMain.add(delegate, identifier: uuid.uuidString)
        return uuid
    }

    public static func addUser(observer: @escaping (SBDGroupChannel, SBDUser) -> Void, forChannel channel: SBDBaseChannel? = nil) -> ChannelObservervation {
        let uuid = UUID()
        let delegate = ChannelDelegate(uuid: uuid, channelFilter: channel?.channelUrl, userUpdated: observer)
        delegates.append(delegate)
        SBDMain.add(delegate, identifier: uuid.uuidString)
        return uuid
    }

    public static func remove(observer: ChannelObservervation) {
        SBDMain.removeChannelDelegate(forIdentifier: observer.uuidString)
        delegates.removeAll { $0.uuid == observer }
    }
}
