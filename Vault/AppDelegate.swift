//
//  AppDelegate.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/8/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 11.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var agent: Agent!
    var nav_controller: UINavigationController!
    var welcomeVC: WelcomeViewController?
    var lastActiveVC: UIViewController?
    var appResigning: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.agent = Agent()
        self.welcomeVC = WelcomeViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.nav_controller = UINavigationController()
        self.nav_controller.isNavigationBarHidden = true
        self.nav_controller.viewControllers = [self.welcomeVC!]
        self.window?.rootViewController = nav_controller
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.loadViewIfNeeded()
            self.lastActiveVC = topController
        } else {
            self.lastActiveVC = nil
        }
        self.appResigning = true
        print("App Enters Background")
        if self.agent.imagePickerController != nil {
            if self.agent.isImagePickerControllerRecording {
                self.agent.stopVideoCapture()
                self.agent.isImagePickerControllerRecording = true      // Save State
            }
        }
        self.window?.endEditing(true)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("App Enters Foreground")
        self.appResigning = false
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.loadViewIfNeeded()
            //topController.viewWillAppear(true)
            if self.lastActiveVC == topController {
                print("Last Active VC Match: OK")
            } else {
                if self.lastActiveVC != nil {
                    print("Last Active VC Match: NOT OK")
                } else {
                    self.lastActiveVC = topController
                }
            }
            
            if self.agent.imagePickerController != nil {
                if self.agent.isImagePickerControllerRecording {
                    self.agent.startVideoCapture()
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    func returnCustomAlertView(titleText: String, messageText: String, yesCompletionHandler: (() -> Void)? = nil, noCompletionHandler: (() -> Void)? = nil, yesButtonText: String? = nil, noButtonString: String? = nil) -> UIAlertController {
        let alertView = UIAlertController(title: titleText, message: messageText as String, preferredStyle:.alert)
        
        if noCompletionHandler != nil {
            if noButtonString != nil {
                let noAction = UIAlertAction(title: noButtonString!, style: .destructive, handler: { action in
                    noCompletionHandler!()
                })
                alertView.addAction(noAction)
            } else {
                let noAction = UIAlertAction(title: "No", style: .destructive, handler: { action in
                    noCompletionHandler!()
                })
                alertView.addAction(noAction)
            }
        }
        
        if yesCompletionHandler != nil && noCompletionHandler != nil {
            if yesButtonText != nil {
                let yesAction = UIAlertAction(title: yesButtonText!, style: .default, handler: { action in
                    yesCompletionHandler!()
                })
                alertView.addAction(yesAction)
            } else {
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                    yesCompletionHandler!()
                })
                alertView.addAction(yesAction)
            }
        } else {
            if yesCompletionHandler != nil {
                if yesButtonText != nil {
                    let yesAction = UIAlertAction(title: yesButtonText!, style: .default, handler: { action in
                        yesCompletionHandler!()
                    })
                    alertView.addAction(yesAction)
                } else {
                    let yesAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
                        yesCompletionHandler!()
                    })
                    alertView.addAction(yesAction)
                }
            } else {
                let yesAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertView.addAction(yesAction)
            }
            
        }
        
        alertView.view.layer.borderColor = UIColor.black.cgColor
        alertView.view.layer.borderWidth = 2.5
        alertView.view.layer.cornerRadius = 10.0
        alertView.view.layer.masksToBounds = true
        alertView.view.tintColor = UIColor.white
        alertView.view.backgroundColor = UIColor.black //.withAlphaComponent(1.0)
        
        for view in alertView.view.subviews {
            if view.isKind(of: UILabel.self) {
                (view as! UILabel).textColor = UIColor.white
            }
            //view.backgroundColor = UIColor.black
        }
        return alertView
    }
    
    func customizeAlertView(alertView: UIAlertController) {
        alertView.view.layer.borderColor = UIColor.black.cgColor
        alertView.view.layer.borderWidth = 2.5
        alertView.view.layer.cornerRadius = 10.0
        alertView.view.layer.masksToBounds = true
        alertView.view.tintColor = UIColor.white
        alertView.view.backgroundColor = UIColor.black //.withAlphaComponent(1.0)
        
        for view in alertView.view.subviews {
            if view.isKind(of: UILabel.self) {
                (view as! UILabel).textColor = UIColor.white
            }
            //view.backgroundColor = UIColor.black
        }
    }

    // MARK: - Core Data stack

    /*lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Vault")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }*/

}

