//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@objc(MSFContactView)
open class ContactView: UIView {
    private struct Constants {
        static let contactWidth: CGFloat = 70.0
        static let avatarViewWidth: CGFloat = 70.0
        static let avatarViewHeight: CGFloat = 70.0
        static let labelMinimumHeight: CGFloat = 16.0
        static let titleLabelMaximumHeight: CGFloat = 28.0
        static let subtitleMaximumHeight: CGFloat = 24.0
        static let spacingBetweenAvatarAndFirstLabel: CGFloat = 13.0
    }

    @objc public var avatarImage: UIImage? {
        didSet {
            setupAvatarView(with: titleLabel?.text, and: subtitleLabel?.text, or: nil)
        }
    }

    private let avatarView: AvatarView
    private var titleLabel: UILabel?
    private var subtitleLabel: UILabel?
    private var labelContainer: UIView

    /// Initializes the contact view by creating an avatar view with a first name and last name
    ///
    /// - Parameters:
    ///   - title: String that will be the text of the top label
    ///   - subtitle: String that will be the text of the bottom label
    @objc public convenience init(title: String, subtitle: String) {
        self.init(title: title, subtitle: subtitle, identifier: nil)
    }

    /// Initializes the contact view by creating an avatar view with an identifier
    ///
    /// - Parameters:
    ///   - identifier: String that will be used to identify the contact (e.g. email, phone number, first name)
    @objc public convenience init(identifier: String) {
        self.init(title: nil, subtitle: nil, identifier: identifier)
    }

    private init(title: String?, subtitle: String?, identifier: String?) {
        avatarView = AvatarView(avatarSize: .extraExtraLarge, withBorder: false, style: .circle)
        labelContainer = UIView(frame: .zero)
        super.init(frame: .zero)

        if let title = title, let subtitle = subtitle {
            setupAvatarView(with: title, and: subtitle, or: nil)
            setupTitleLabel(using: title)
            setupSubtitleLabel(using: subtitle)
        } else if let identifier = identifier {
            setupAvatarView(with: nil, and: nil, or: identifier)
            setupTitleLabel(using: identifier)
        }

        backgroundColor = Colors.surfacePrimary
        setupLayout()
    }

    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    private func setupAvatarView(with firstName: String?, and lastName: String?, or identifier: String?) {
        if let firstName = firstName, let lastName = lastName {
            let fullName = firstName + " " + lastName
            avatarView.setup(primaryText: fullName, secondaryText: identifier, image: avatarImage)
        } else {
            avatarView.setup(primaryText: identifier, secondaryText: "", image: avatarImage)
        }
    }

    private func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(widthAnchor.constraint(equalToConstant: Constants.contactWidth))
        constraints.append(contentsOf: avatarLayoutConstraints())

        if let titleLabel = titleLabel {
            if let subtitleLabel = subtitleLabel {
                constraints.append(contentsOf: titleLabelLayoutConstraints())
                constraints.append(contentsOf: subtitleLabelLayoutConstraints())
                labelContainer.addSubview(subtitleLabel)
            } else {
                constraints.append(contentsOf: identifierLayoutConstraints())
            }
            labelContainer.addSubview(titleLabel)
        }

        constraints.append(contentsOf: labelContainerLayoutConstraints())
        labelContainer.addSubview(avatarView)
        addSubview(labelContainer)

        NSLayoutConstraint.activate(constraints)
    }

    private func avatarLayoutConstraints() -> [NSLayoutConstraint] {
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        return [
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarViewHeight),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarViewWidth),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
    }

    private func labelContainerLayoutConstraints() -> [NSLayoutConstraint] {
        labelContainer.translatesAutoresizingMaskIntoConstraints = false

        return [
            labelContainer.widthAnchor.constraint(equalToConstant: Constants.contactWidth),
            labelContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelContainer.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: Constants.spacingBetweenAvatarAndFirstLabel),
            labelContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 2 * Constants.labelMinimumHeight),
            labelContainer.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.titleLabelMaximumHeight + Constants.subtitleMaximumHeight)
        ]
    }

    private func titleLabelLayoutConstraints() -> [NSLayoutConstraint] {
        guard let titleLabel = titleLabel else {
            return []
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return [
            titleLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: Constants.spacingBetweenAvatarAndFirstLabel),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.labelMinimumHeight),
            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.titleLabelMaximumHeight)
        ]
    }

    private func subtitleLabelLayoutConstraints() -> [NSLayoutConstraint] {
        guard let subtitleLabel = subtitleLabel else {
            return []
        }

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.labelMinimumHeight),
            subtitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.subtitleMaximumHeight)
        ]

        if let titleLabel = titleLabel {
            constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor))
        }

        return constraints
    }

    private func identifierLayoutConstraints() -> [NSLayoutConstraint] {
        guard let titleLabel = titleLabel else {
            return []
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return [
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: Constants.spacingBetweenAvatarAndFirstLabel),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    }

    private func setupTitleLabel(using firstName: String) {
        let label = UILabel(frame: .zero)
        label.adjustsFontForContentSizeCategory = true
        label.font = Fonts.subhead
        label.text = firstName
        label.textAlignment = .center
        label.textColor = Colors.Contact.title

        if subtitleLabel == nil {
            label.numberOfLines = 2
        }

        titleLabel = label
    }

    private func setupSubtitleLabel(using lastName: String) {
        let label = UILabel(frame: .zero)
        label.adjustsFontForContentSizeCategory = true
        label.font = Fonts.footnote
        label.text = lastName
        label.textAlignment = .center
        label.textColor = Colors.Contact.subtitle

        subtitleLabel = label
    }
}
