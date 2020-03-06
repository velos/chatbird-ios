//
//  LoaderCollectionViewCell.swift
//
//  Created by Zac White on 11/11/18.
//

import Foundation
import UIKit

class LoaderCollectionViewCell: UICollectionViewCell
{
    let activityIndicator = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Must be set up in code.")
    }

    private func setupUI() {
        setupActivityIndicator()
    }

    private func setupActivityIndicator() {
        contentView.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
