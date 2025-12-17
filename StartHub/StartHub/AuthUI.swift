import UIKit

enum AuthUI {

    static func applyBackground(to view: UIView) {
        view.backgroundColor = .systemGroupedBackground
    }

    static func style(textField: UITextField, placeholder: String, isSecure: Bool) {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = isSecure ? .default : .emailAddress

        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor

        // padding
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = pad
        textField.leftViewMode = .always

        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }

    static func stylePrimary(button: UIButton, title: String) {
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.filled()
            cfg.title = title
            cfg.baseBackgroundColor = .systemBlue
            cfg.baseForegroundColor = .white
            cfg.cornerStyle = .large
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            button.configuration = cfg
        } else {
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        }
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }

    static func styleLink(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    }
}
