import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    @IBAction private func didTapLogin(_ sender: UIButton) {
        let username = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        NetworkManager.shared.request(
            endpoint: "/api/token/",
            method: .post,
            parameters: ["username": username, "password": password],
            requiresAuth: false
        ) { (result: Result<TokenPair, NetworkError>) in
            switch result {
            case .success(let tokens):
                AuthManager.shared.saveTokens(access: tokens.access, refresh: tokens.refresh)
                self.openMain()

            case .failure(let err):
                print("LOGIN failed:", err.localizedDescription)
            }
        }
    }

    @IBAction private func didTapRegister(_ sender: UIButton) {
        // Пока можешь оставить пустым или сделать push на RegisterVC позже
        print("Go to register")
    }

    private func openMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else {
            print("❌ Main storyboard has no Initial View Controller")
            return
        }

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = vc
            window.makeKeyAndVisible()
        } else {
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }
    }

}
