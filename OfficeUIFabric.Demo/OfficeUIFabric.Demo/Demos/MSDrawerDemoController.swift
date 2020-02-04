//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import OfficeUIFabric
import UIKit

// MARK: MSDrawerDemoController

class MSDrawerDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(barButtonTapped))

        addTitle(text: "Top Drawer")
        container.addArrangedSubview(createButton(title: "Show resizable", action: #selector(showTopDrawerButtonTapped)))
        container.addArrangedSubview(createButton(title: "Show with no animation", action: #selector(showTopDrawerNotAnimatedButtonTapped)))
        container.addArrangedSubview(createButton(title: "Show from custom base", action: #selector(showTopDrawerCustomOffsetButtonTapped)))

        addTitle(text: "Left/Right Drawer")
        addRow(
            items: [
                createButton(title: "Show from leading", action: #selector(showLeftDrawerButtonTapped)),
                createButton(title: "Show from trailing", action: #selector(showRightDrawerButtonTapped))
            ],
            itemSpacing: DemoController.verticalSpacing,
            stretchItems: true
        )

        addTitle(text: "Bottom Drawer")
        container.addArrangedSubview(createButton(title: "Show resizable", action: #selector(showBottomDrawerButtonTapped)))
        container.addArrangedSubview(createButton(title: "Show with no animation", action: #selector(showBottomDrawerNotAnimatedButtonTapped)))
        container.addArrangedSubview(createButton(title: "Show from custom base", action: #selector(showBottomDrawerCustomOffsetButtonTapped)))

        container.addArrangedSubview(createButton(title: "Show always as slideover, resizable", action: #selector(showBottomDrawerCustomContentControllerButtonTapped)))

        container.addArrangedSubview(createButton(title: "Show with focusable content", action: #selector(showBottomDrawerFocusableContentButtonTapped)))

        container.addArrangedSubview(UIView())
    }

    @discardableResult
    private func presentDrawer(sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, presentationOrigin: CGFloat = -1, presentationDirection: MSDrawerPresentationDirection, presentationStyle: MSDrawerPresentationStyle = .automatic, presentationOffset: CGFloat = 0, presentationBackground: MSDrawerPresentationBackground = .black, contentController: UIViewController? = nil, contentView: UIView? = nil, resizingBehavior: MSDrawerResizingBehavior = .none, adjustHeightForKeyboard: Bool = false, animated: Bool = true) -> MSDrawerController {
        let controller: MSDrawerController
        if let sourceView = sourceView {
            controller = MSDrawerController(sourceView: sourceView, sourceRect: sourceView.bounds, presentationOrigin: presentationOrigin, presentationDirection: presentationDirection)
        } else if let barButtonItem = barButtonItem {
            controller = MSDrawerController(barButtonItem: barButtonItem, presentationOrigin: presentationOrigin, presentationDirection: presentationDirection)
        } else {
            fatalError("Presenting a drawer requires either a sourceView or a barButtonItem")
        }

        controller.presentationStyle = presentationStyle
        controller.presentationOffset = presentationOffset
        controller.presentationBackground = presentationBackground
        controller.resizingBehavior = resizingBehavior
        controller.adjustsHeightForKeyboard = adjustHeightForKeyboard

        if let contentView = contentView {
            // `preferredContentSize` can be used to specify the preferred size of a drawer,
            // but here we just define the width and allow it to calculate height automatically
            controller.preferredContentSize.width = 360
            //controller.preferredContentSize.height = 230
            controller.contentView = contentView
        } else {
            controller.contentController = contentController
        }

        present(controller, animated: animated)

        return controller
    }

    private func actionViews(drawerHasFlexibleHeight: Bool) -> [UIView] {
        let spacer = UIView()
        spacer.backgroundColor = .orange
        spacer.layer.borderWidth = 1
        spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

        var views = [UIView]()
        if drawerHasFlexibleHeight {
            views.append(createButton(title: "Change content height", action: #selector(changeContentHeightButtonTapped)))
            views.append(createButton(title: "Expand", action: #selector(expandButtonTapped)))
        }
        views.append(createButton(title: "Dismiss", action: #selector(dismissButtonTapped)))
        views.append(createButton(title: "Dismiss (no animation)", action: #selector(dismissNotAnimatedButtonTapped)))
        views.append(spacer)
        return views
    }

    private func containerForActionViews(drawerHasFlexibleHeight: Bool = true) -> UIView {
        let container = DemoController.createVerticalContainer()
        for view in actionViews(drawerHasFlexibleHeight: drawerHasFlexibleHeight) {
            container.addArrangedSubview(view)
        }
        return container
    }

    @objc private func barButtonTapped(sender: UIBarButtonItem) {
        presentDrawer(barButtonItem: sender, presentationDirection: .down, contentView: containerForActionViews())
    }

    @objc private func showTopDrawerButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .down, contentView: containerForActionViews(), resizingBehavior: .dismissOrExpand)
    }

    @objc private func showTopDrawerNotAnimatedButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .down, contentView: containerForActionViews(), animated: false)
    }

    @objc private func showTopDrawerCustomOffsetButtonTapped(sender: UIButton) {
        let rect = sender.superview!.convert(sender.frame, to: nil)
        presentDrawer(sourceView: sender, presentationOrigin: rect.maxY, presentationDirection: .down, contentView: containerForActionViews())
    }

    @objc private func showLeftDrawerButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .fromLeading, contentView: containerForActionViews(drawerHasFlexibleHeight: false), resizingBehavior: .dismiss)
    }

    @objc private func showRightDrawerButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .fromTrailing, contentView: containerForActionViews(drawerHasFlexibleHeight: false), resizingBehavior: .dismiss)
    }

    @objc private func showBottomDrawerButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .up, contentView: containerForActionViews(), resizingBehavior: .dismissOrExpand)
    }

    @objc private func showBottomDrawerNotAnimatedButtonTapped(sender: UIButton) {
        presentDrawer(sourceView: sender, presentationDirection: .up, contentView: containerForActionViews(), animated: false)
    }

    @objc private func showBottomDrawerCustomOffsetButtonTapped(sender: UIButton) {
        let rect = sender.superview!.convert(sender.frame, to: nil)
        presentDrawer(sourceView: sender, presentationOrigin: rect.minY, presentationDirection: .up, contentView: containerForActionViews())
    }

    @objc private func showBottomDrawerCustomContentControllerButtonTapped(sender: UIButton) {
        let controller = UIViewController()
        controller.title = "Resizable slideover drawer"
        controller.preferredContentSize = CGSize(width: 400, height: 400)

        let personaListView = MSPersonaListView()
        personaListView.personaList = samplePersonas
        controller.view.addSubview(personaListView)
        personaListView.fitIntoSuperview()

        let contentController = UINavigationController(rootViewController: controller)
        contentController.navigationBar.barTintColor = MSColors.background1

        let drawer = presentDrawer(sourceView: sender, presentationDirection: .up, presentationStyle: .slideover, presentationOffset: 20, presentationBackground: traitCollection.horizontalSizeClass == .regular ? .none : .black, contentController: contentController, resizingBehavior: .dismissOrExpand)

        drawer.contentScrollView = personaListView
    }

    @objc private func showBottomDrawerFocusableContentButtonTapped(sender: UIButton) {
        let contentController = UIViewController()

        let container = UIStackView()
        container.axis = .vertical
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        container.spacing = 10
        contentController.view.addSubview(container)
        container.fitIntoSuperview(usingConstraints: true)

        let textField = UITextField()
        textField.text = "Some focusable content"
        textField.delegate = self
        container.addArrangedSubview(textField)

        let button = MSButton(style: .primaryFilled)
        button.setTitle("Hide keyboard", for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.addTarget(self, action: #selector(hideKeyboardButtonTapped), for: .touchUpInside)
        container.addArrangedSubview(button)

        presentDrawer(sourceView: sender, presentationDirection: .up, contentController: contentController, resizingBehavior: .dismissOrExpand, adjustHeightForKeyboard: true)

        textField.becomeFirstResponder()
    }

    @objc private func changeContentHeightButtonTapped(sender: UIButton) {
        if let spacer = (sender.superview as? UIStackView)?.arrangedSubviews.last,
            let heightConstraint = spacer.constraints.first {
            heightConstraint.constant = heightConstraint.constant == 20 ? 100 : 20
        }
    }

    @objc private func expandButtonTapped(sender: UIButton) {
        guard let drawer = presentedViewController as? MSDrawerController else {
            return
        }
        drawer.isExpanded = !drawer.isExpanded
        sender.setTitle(drawer.isExpanded ? "Return to normal" : "Expand", for: .normal)
    }

    @objc private func dismissButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissNotAnimatedButtonTapped() {
        dismiss(animated: false)
    }

    @objc private func hideKeyboardButtonTapped(sender: UIButton) {
        if let stackView = sender.superview as? UIStackView {
            let textField = stackView.arrangedSubviews.first(where: { $0 is UITextField })
            textField?.resignFirstResponder()
        }
    }
}

// MARK: - MSDrawerDemoController: UITextFieldDelegate

extension MSDrawerDemoController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
