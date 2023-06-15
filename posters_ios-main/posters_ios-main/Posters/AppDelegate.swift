//
//  AppDelegate.swift
//  Posters
//
//  Created by Administrator on 2/26/23.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import TikTokOpenSDK
import BranchSDK
import OneSignal
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey(Google_Place_Key)
        GMSPlacesClient.provideAPIKey(Google_Place_Key)
        TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        Branch.setUseTestBranchKey(true)
        Branch.getInstance().checkPasteboardOnInstall()

        if Branch.getInstance().willShowPasteboardToast(){
            //developers can notify the user of what just occured here if they choose
            print("-----willShowPasteboardToast")
        }

        Branch.getInstance().initSession(launchOptions: launchOptions){(params,error) in
            print(params as? [String:AnyObject] ?? {})
            if let post_id = params?["post_id"] as? String{
                UserDefaults.post_id = post_id
                let social_type = params?["social_type"] as? String
                UserDefaults.social_type = social_type ?? "0"
                NotificationCenter.default.post(name: NSNotification.Name("OPENPOST"), object: nil)
                shouldOpenPostDetails = true

            }
        }
        
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("6dde79b7-7cb9-4c7c-86cc-9963e3854926")
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })


        return true
    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//
//        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//              let annotation = options[UIApplication.OpenURLOptionsKey.annotation] else {
//            return false
//        }
//
//        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation) {
//            return true
//        }
//
//        Branch.getInstance().application(app, open: url, options: options)
//        return false
//    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        Branch.getInstance().application(application, open: url, options: nil)

        return false
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: "") {
            return true
        }
        return false
    }


}

