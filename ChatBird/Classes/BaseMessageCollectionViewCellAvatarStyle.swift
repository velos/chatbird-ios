//
//  BaseMessageCollectionViewCellAvatarStyle.swift
//
//  Created by Zac White on 11/8/18.
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
