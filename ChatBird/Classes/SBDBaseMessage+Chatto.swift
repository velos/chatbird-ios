//
//  SBDBaseMessage+Chatto.swift
//  ChatBird
//
//  Created by David Rajan on 12/30/19.
//

import Foundation
import Chatto
import ChattoAdditions
import SendBirdSDK

public enum MessageType: String {
    case text
    case photo
    case admin
}

extension SBDBaseMessage {
    public var messageType: MessageType {

        if self is SBDUserMessage {
            return .text
        } else if self is SBDFileMessage {
            return .photo
        } else if self is SBDAdminMessage {
            return .admin
        }

        fatalError("Unsupported message type: \(self)")
    }
}

extension SBDBaseMessage: ChatItemProtocol {
    public var type: ChatItemType {
        return messageType.rawValue
    }

    public var uid: String {
        return "\(messageId)"
    }
}

protocol UserMessageType {
    var sender: SBDSender? { get }
    var requestState: SBDMessageRequestState { get }

    func readCount(for channel: SBDGroupChannel) -> Int32
}

extension SBDFileMessage: UserMessageType { }
extension SBDUserMessage: UserMessageType { }

extension SBDBaseMessage: MessageModelProtocol {
    public var senderId: String {
        if self is SBDAdminMessage {
            return "admin"
        } else if let message = self as? UserMessageType {
            return message.sender?.userId ?? "no-sender"
        }

        return "unknown"
    }

    public var isIncoming: Bool {
        if self is SBDAdminMessage {
            return true
        }

        guard let message = self as? UserMessageType else {
            return true
        }

        return message.sender?.userId != nil && (message.sender?.userId != SBDMain.getCurrentUser()?.userId)
    }

    public var date: Date {
        return Date(timeIntervalSince1970: Double(createdAt) / 1000.0)
    }

    public var status: MessageStatus {
        guard let message = self as? UserMessageType else {
            return .success
        }

        switch message.requestState {
        case .none, .pending:
            return .sending
        case .failed:
            return .failed
        case .succeeded:
            return .success
        @unknown default:
            fatalError()
        }
    }

    public func readCount(for channel: SBDGroupChannel) -> Int32 {
        return Int32(channel.memberCount - 1) - channel.getReadReceipt(of: self)
    }
}
