import UIKit

/// Owns one example window and installs the Swift table demonstration for its scene.
final class TRKExampleSceneDelegate: UIResponder, UIWindowSceneDelegate {
    /// Keeps the scene's window alive; scene(_:willConnectTo:options:) assigns it on connection.
    var window: UIWindow?

    /// Creates the navigation stack when UIKit connects a window scene.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Only a window scene can own the example's visible UIKit window.
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: TRKExampleViewController())
        self.window = window
        window.makeKeyAndVisible()
    }
}
