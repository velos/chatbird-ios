/*

 Adapted from Chatto sample app by Zac White on 11/9/18
 https://github.com/badoo/Chatto

 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Chatto
import ChattoAdditions

public final class GenericMessageHandler<ViewModel: MessageViewModelProtocol>: BaseMessageInteractionHandlerProtocol {
    private let baseHandler: MessageHandlerProtocol
    private let presentingVC: UIViewController

    public init(baseHandler: MessageHandlerProtocol, presentingVC: UIViewController) {
        self.baseHandler = baseHandler
        self.presentingVC = presentingVC
    }

    public func userDidTapOnFailIcon(viewModel: ViewModel, failIconView: UIView) {
        self.baseHandler.userDidTapOnFailIcon(viewModel: viewModel)
    }

    public func userDidTapOnAvatar(viewModel: ViewModel) {
        self.baseHandler.userDidTapOnAvatar(viewModel: viewModel)
    }

    public func userDidTapOnBubble(viewModel: ViewModel) {
        self.baseHandler.userDidTapOnBubble(viewModel: viewModel)
    }

    public func userDidBeginLongPressOnBubble(viewModel: ViewModel) {
        let optionMenu = UIAlertController(title: nil, message: "Message Options", preferredStyle: .actionSheet)

        if let viewModel = viewModel as? SBDUserMessageViewModel {
            optionMenu.addAction(
                UIAlertAction(title: "Copy", style: .default) { action in
                    UIPasteboard.general.string = viewModel.text
                }
            )
            
            // Add additional long press actions for text messages here
        }
        else if let viewModel = viewModel as? SBDFileMessageViewModel {
            optionMenu.addAction(
                UIAlertAction(title: "Copy", style: .default) { action in
                    UIPasteboard.general.image = viewModel.photoMessage.image
                }
            )
            
            // Add additional long press actions for file messages here
        }

        guard optionMenu.actions.count > 0 else { return }

        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentingVC.present(optionMenu, animated: true, completion: nil)
    }

    public func userDidEndLongPressOnBubble(viewModel: ViewModel) {
        self.baseHandler.userDidEndLongPressOnBubble(viewModel: viewModel)
    }

    public func userDidSelectMessage(viewModel: ViewModel) {
        self.baseHandler.userDidSelectMessage(viewModel: viewModel)
    }

    public func userDidDeselectMessage(viewModel: ViewModel) {
        self.baseHandler.userDidDeselectMessage(viewModel: viewModel)
    }
}
