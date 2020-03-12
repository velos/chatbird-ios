//
//  BaseMessageCollectionViewCellAvatarStyle.swift
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
import ChattoAdditions

public class ChatBirdTextMessageCellStyle: TextMessageCollectionViewCellDefaultStyle {

    public init() {
        super.init(
            bubbleImages: TextMessageCollectionViewCellDefaultStyle.BubbleImages(
                incomingTail: UIImage(named: "chatBubble", in: .chatBird, compatibleWith: nil)!,
                incomingNoTail: UIImage(named: "chatBubble", in: .chatBird, compatibleWith: nil)!,
                outgoingTail: UIImage(named: "chatBubble", in: .chatBird, compatibleWith: nil)!,
                outgoingNoTail: UIImage(named: "chatBubble", in: .chatBird, compatibleWith: nil)!
            ),
            textStyle: TextMessageCollectionViewCellDefaultStyle.TextStyle(
                font: UIFont.systemFont(ofSize: 14),
                incomingColor: .black,
                outgoingColor: .white,
                incomingInsets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12),
                outgoingInsets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            ),
            baseStyle: ChatBirdBaseMessageCellStyle()
        )
    }
}

public class ChatBirdBaseMessageCellStyle: BaseMessageCollectionViewCellDefaultStyle {

    public init() {
        super.init(
            colors: BaseMessageCollectionViewCellDefaultStyle.Colors(
                incoming: UIColor(white: 241.0/255.0, alpha: 1),
                outgoing: UIColor.systemBlue
            ),
            bubbleBorderImages: BaseMessageCollectionViewCellDefaultStyle.BubbleBorderImages(
                borderIncomingTail: UIImage(),
                borderIncomingNoTail: UIImage(),
                borderOutgoingTail: UIImage(),
                borderOutgoingNoTail: UIImage()
            ),
            layoutConstants: BaseMessageCollectionViewCellLayoutConstants(horizontalMargin: 11, horizontalInterspacing: 6, horizontalTimestampMargin: 11, maxContainerWidthPercentageForBubbleView: 0.68),
            avatarStyle: BaseMessageCollectionViewCellDefaultStyle.AvatarStyle(
                size: CGSize(width: 28, height: 28),
                alignment: .bottom
            )
        )
    }
}
