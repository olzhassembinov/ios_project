import UIKit

final class RootRouter {
    static let shared = RootRouter()
    private init() {}

    func showAuth(in window: UIWindow) {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func showMain(in window: UIWindow) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    /// старт: если токен есть — проверяем /me
    func start(in window: UIWindow) {
        if AuthManager.shared.isLoggedIn {
            AuthAPIClient.shared.me { result in
                switch result {
                case .success:
                    self.showMain(in: window)
                case .failure:
                    AuthManager.shared.clearTokens()
                    self.showAuth(in: window)
                }
            }
        } else {
            showAuth(in: window)
        }
    }
}
