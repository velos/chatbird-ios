//
//  SendingStatusPresenter.swift
//  ChatBird
//
//  Adapted from Chatto sample app
//  https://github.com/badoo/Chatto
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-present Badoo Trading Limited.
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

import UIKit
import Chatto
import ChattoAdditions

public class SendingStatusModel: ChatItemProtocol {
    public let uid: String
    public static var chatItemType: ChatItemType {
        return "decoration-status"
    }

    public var type: String { return SendingStatusModel.chatItemType }

    let status: MessageStatus
    let isMultiUserGroup: Bool
    let seenCount: Int32

    init (uid: String, status: MessageStatus, isMultiUserGroup: Bool, seenCount: Int32) {
        self.uid = uid
        self.status = status
        self.seenCount = seenCount
        self.isMultiUserGroup = isMultiUserGroup
    }
}

public class SendingStatusPresenterBuilder: ChatItemPresenterBuilderProtocol {
    
    public init() { }

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is SendingStatusModel ? true : false
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return SendingStatusPresenter(
            statusModel: chatItem as! SendingStatusModel
        )
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return SendingStatusPresenter.self
    }
}

class SendingStatusPresenter: ChatItemPresenterProtocol {

    let statusModel: SendingStatusModel
    init (statusModel: SendingStatusModel) {
        self.statusModel = statusModel
    }

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(SendingStatusCollectionViewCell.self, forCellWithReuseIdentifier: "SendingStatusCollectionViewCell")
    }

    let isItemUpdateSupported = false

    func update(with chatItem: ChatItemProtocol) {}

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SendingStatusCollectionViewCell", for: indexPath)
        return cell
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let statusCell = cell as? SendingStatusCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }

        let attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0),
            NSAttributedString.Key.foregroundColor: self.statusModel.status == .failed ? UIColor.red : UIColor.gray
        ]
        statusCell.text = NSAttributedString(
            string: self.statusText(),
            attributes: attrs)
    }

    func statusText() -> String {
        switch self.statusModel.status {
        case .failed:
            return NSLocalizedString("Sending failed", comment: "")
        case .sending:
            return NSLocalizedString("Sending...", comment: "")
        case .success:
            if self.statusModel.seenCount == 0 {
                return NSLocalizedString("Sent", comment: "Sent message")
            } else if self.statusModel.isMultiUserGroup {
                return String(format: NSLocalizedString("Read by %d participant%@", comment: ""), self.statusModel.seenCount, self.statusModel.seenCount == 1 ? "" : "s")
            } else {
                return NSLocalizedString("Read", comment: "Read message")
            }
        }
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 19
    }
}
