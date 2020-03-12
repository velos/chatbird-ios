//
//  AvatarView.swift
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

import SendBirdSDK
import Nuke

public class AvatarView: UIView {
    private lazy var primaryAvatarView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private lazy var secondaryAvatarView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var presenceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 7.0
        return view
    }()

    private var singleConstraints: [NSLayoutConstraint] = []

    private var multiConstraints: [NSLayoutConstraint] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        primaryAvatarView.layer.cornerRadius = round(primaryAvatarView.frame.width / 2.0)
        secondaryAvatarView.layer.cornerRadius = round(primaryAvatarView.frame.width / 2.0)
    }

    private func setupUI() {
        addSubview(secondaryAvatarView)
        addSubview(primaryAvatarView)
        addSubview(presenceView)

        singleConstraints = [
            primaryAvatarView.widthAnchor.constraint(equalTo: widthAnchor),
            primaryAvatarView.heightAnchor.constraint(equalTo: heightAnchor),
            primaryAvatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            primaryAvatarView.centerYAnchor.constraint(equalTo: centerYAnchor),

            presenceView.trailingAnchor.constraint(equalTo: trailingAnchor),
            presenceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            presenceView.widthAnchor.constraint(equalToConstant: 14.0),
            presenceView.heightAnchor.constraint(equalToConstant: 14.0)
        ]

        let multiplier: CGFloat = 0.75
        let layoutConstant = primaryAvatarView.layer.borderWidth
        let sizeConstant = layoutConstant * 2

        multiConstraints = [
            primaryAvatarView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier, constant: sizeConstant),
            primaryAvatarView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier, constant: sizeConstant),
            primaryAvatarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: layoutConstant),
            primaryAvatarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: layoutConstant),

            secondaryAvatarView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier),
            secondaryAvatarView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier),
            secondaryAvatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            secondaryAvatarView.topAnchor.constraint(equalTo: topAnchor)
        ]
    }

    private func resetLayout() {
        singleConstraints.forEach { $0.isActive = false }
        multiConstraints.forEach { $0.isActive = false }
        primaryAvatarView.layer.borderWidth = 0
        secondaryAvatarView.layer.borderWidth = 0
        secondaryAvatarView.isHidden = true
        presenceView.isHidden = true
    }
    
    private func setupImageView(_ imageView: UIImageView, member: SBDMember?) {
        guard let url = URL(string: member?.profileUrl ?? "") else {
            imageView.image = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
            return
        }

        Nuke.loadImage(with: url, into: imageView)
    }

    public func setup(with members: [SBDMember]) {
        resetLayout()

        if members.count < 2 {
            setupImageView(primaryAvatarView, member: members.first)
            primaryAvatarView.layer.borderWidth = 0
            presenceView.layer.borderWidth = 2.0
            presenceView.backgroundColor  = members.first?.connectionStatus == .online ? .green : .lightGray
            presenceView.isHidden = false
            NSLayoutConstraint.activate(singleConstraints)
        }
        else {
            if members.count == 2 {
                setupImageView(secondaryAvatarView, member: members.last)
            }
            else {
                secondaryAvatarView.image = UIImage(named: "person.2.square.stack.fill", in: .chatBird, compatibleWith: nil)
            }

            secondaryAvatarView.isHidden = false
            presenceView.isHidden = true
            setupImageView(primaryAvatarView, member: members.first)
            primaryAvatarView.layer.borderWidth = 2.0
            NSLayoutConstraint.activate(multiConstraints)
        }
    }
}
