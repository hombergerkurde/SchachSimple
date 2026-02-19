import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // iOS 12 und älter: kein SceneDelegate
        if #available(iOS 13.0, *) {
            // handled in SceneDelegate
        } else {
            let w = UIWindow(frame: UIScreen.main.bounds)
            let root = UINavigationController(rootViewController: MenuViewController())
            w.rootViewController = root
            w.makeKeyAndVisible()
            self.window = w
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
