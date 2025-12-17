import UIKit

final class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func didTapCreate(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passwordTextField.text ?? ""
        let pass2 = confirmPasswordTextField.text ?? ""

        guard !email.isEmpty, !pass.isEmpty else { return }
        guard pass == pass2 else { return }

        AuthAPIClient.shared.register(email: email, password: pass) { [weak self] result in
            switch result {
            case .success:
                // автологин
                AuthAPIClient.shared.login(username: email, password: pass) { loginResult in
                    switch loginResult {
                    case .success(let tokens):
                        AuthManager.shared.saveTokens(access: tokens.access, refresh: tokens.refresh)
                        self?.openMain()
                    case .failure(let err):
                        print("AUTO LOGIN FAIL:", err)
                    }
                }
            case .failure(let err):
                print("REGISTER FAIL:", err)
            }
        }
    }

    private func openMain() {
        guard let window = (view.window ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first) else { return }
        RootRouter.shared.showMain(in: window)
    }
}
