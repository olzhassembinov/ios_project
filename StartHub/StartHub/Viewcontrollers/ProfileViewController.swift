import UIKit

final class ProfileViewController: UIViewController {

    @IBAction func didTapLogout(_ sender: UIButton) {
        AuthManager.shared.clearTokens()

        guard let window = (view.window ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first) else { return }

        RootRouter.shared.showAuth(in: window)
    }
}
