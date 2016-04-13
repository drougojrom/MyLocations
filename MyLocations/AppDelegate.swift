//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 01/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error: ErrorType) {
    print("Fatal Error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func listenForFatalCoreDataNotofications(){
        // 1 - tell NSNotificationCenter that you want to be notified
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
            // 2 - create a UIAlert to show error message
            let alert = UIAlertController(title: "Internal error", message: "There was a fatal error in the app and it can not continue.\n\n" + "Press OK to terminate the App. Sorry for inconvenience", preferredStyle: .Alert)
            
            // 3 - add an action to button
            let action = UIAlertAction(title: "OK", style: .Default, handler: { _ in
            
                let exeption = NSException(name: NSInternalInconsistencyException, reason: "Fatal CoreData Error", userInfo: nil)
                exeption.raise()
                
            })
            
            alert.addAction(action)
            
            // 4 - present alert
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        
        })
    }
    
    // 5 - to present alert we need a viewController, which is visible, this func helps us in it
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }

    var window: UIWindow?
    // creating NSManagedObjectContext
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        // 1 - create NSURL pointing to a folder, which points on my DataModel.momd file
        guard let modeURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find model in app bundle")
        }
        
        // 2 - create an NSManagedObjectModel from that URL
        guard let model = NSManagedObjectModel(contentsOfURL: modeURL) else {
            fatalError("Unable to initialize mode from \(modeURL)")
        }
        
        // 3 - create an object pointing to DataStore.sqlite file
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0]
        
        let storeURL = documentDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        print(storeURL)
        do {
            // 4 - creating an object which is in charge of SQLite databese
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            // 5 - add SQLite database to the store coordinator
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            // 6 - create NSManagedObjectContext object and return it
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        } catch { // 7 - catch an error; just in case
            fatalError("Error adding persistent store at \(storeURL): \(error) ")
        }
        
    }()
    
    func customizeAppearance(){
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        customizeAppearance()
        // Override point for customization after application launch.
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            
            locationsViewController.managedObjectContext = managedObjectContext
            
            currentLocationViewController.managedObjectContext = managedObjectContext
        }
        
        listenForFatalCoreDataNotofications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

