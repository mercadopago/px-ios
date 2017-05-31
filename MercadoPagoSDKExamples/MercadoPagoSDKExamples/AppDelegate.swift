//
//  AppDelegate.swift
//  MercadoPagoSDKExamples
//
//  Created by Matias Gualino on 6/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import UIKit
import CoreData
import MercadoPagoSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var nav: UINavigationController?


    
    func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
    
        MercadoPagoContext.setPublicKey("TEST-971766e1-383e-420f-9b69-cecd4c63d071")
        
        //MercadoPagoContext.setPublicKey("TEST-ad365c37-8012-4014-84f5-6c895b3f8e0a")

     
        
     //   MercadoPagoContext.setMerchantAccessToken(ExamplesUtils.MERCHANT_ACCESS_TOKEN)

        MercadoPagoContext.setDisplayDefaultLoading(flag: false)
        
        MercadoPagoContext.setLanguage(language: MercadoPagoContext.Languages._SPANISH)
        
//        let tracker = TrackerExample()
//        
//        MercadoPagoContext.setTrack(listener: tracker)
        MercadoPagoContext.setBaseURL("https://private-0c3e9-testingcustomer.apiary-mock.com")
        MercadoPagoContext.setCustomerURI("/get_customer")

        

        //MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        //Pinto de rojo el color primerio


        //MercadoPagoContext.setupPrimaryColor(UIColor.black, complementaryColor: UIColor.black)
        let decorationPreference = DecorationPreference()
        decorationPreference.setBaseColor(hexColor: "#CA254D")
        
        MercadoPagoContext.setDecorationPreference(decorationPreference: decorationPreference)
        
        CardFormViewController.showBankDeals = true
        
        
        // Initialize window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.px_white()
        
        self.nav = UINavigationController()

        
        let exmaplesViewController = MainExamplesViewController()
        
        // Put vaultController at the top of navigator.
        self.nav!.pushViewController(exmaplesViewController, animated: false)
        
        self.window?.rootViewController = self.nav

        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mercadopago.MercadoPagoSDKExamples" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MercadoPagoSDKExamples", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("MercadoPagoSDKExamples.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
		do {
			var aux : AnyObject? = try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
			if aux == nil {
				coordinator = nil
				// Report any error we got.
				var dict = [String: AnyObject]()
				dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
				dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
				dict[NSUnderlyingErrorKey] = error
				error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
				// Replace this with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				NSLog("Unresolved error \(error), \(error!.userInfo)")
				abort()
			}

		} catch {
			
		}
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
			do {
				try moc.save()
				if moc.hasChanges {
					// Replace this implementation with code to handle the error appropriately.
					// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
					//NSLog("Unresolved error \(error), \(error!.userInfo)")
					abort()
				}
			} catch {
				
			}
        }
    }

}

//class TrackerExample :  MPTrackListener {
//    func trackScreen(screenName : String){
//        print("***** Trackeada \(screenName)")
//    }
//    func trackEvent(screenName : String?, action: String!, result: String?, extraParams: [String:String]?){
//        print("***** Trackeado Evento en \(screenName) accion \(action) y result \(result)")
//    }
//}

