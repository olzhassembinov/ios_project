//
//  SceneDelegate.swift
//  StartHub
//
//  Created by Олжас Сембинов on 10.12.2025.
//

//
//  SceneDelegate.swift
//  StartHub
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Determine which screen to show
        if AuthManager.shared.isLoggedIn() {
            // User IS logged in → Show TabBar
            print("✅ User is logged in, showing TabBar")
            showMainApp()
        } else {
            // User NOT logged in → Show Login
            print("🔐 User not logged in, showing Login")
            showLogin()
        }
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Navigation Helpers
    
    /// Show the main TabBar interface (user is logged in)
    private func showMainApp() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("❌ ERROR: Could not find MainTabBarController")
            print("   Solution: Open Main.storyboard, select TabBarController")
            print("   Set Storyboard ID to: 'MainTabBarController'")
            return
        }
        
        window?.rootViewController = tabBarVC
    }
    
    /// Show the login/auth interface (user is NOT logged in)
    private func showLogin() {
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        
        guard let loginVC = authStoryboard.instantiateInitialViewController() else {
            print("❌ ERROR: Could not find initial view controller in Auth.storyboard")
            print("   Solution: Open Auth.storyboard, select LoginViewController")
            print("   Check 'Is Initial View Controller' in Attributes Inspector")
            return
        }
        
        window?.rootViewController = loginVC
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}
