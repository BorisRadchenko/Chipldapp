//
//  AppDelegate.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // MPNowPlayingInfoCenter
        UIApplication.shared.beginReceivingRemoteControlEvents()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    // MARK: - Remote Controls
    
    // override func remoteControlReceived(with event: UIEvent?) {
    //     super.remoteControlReceived(with: event)
    // 
    //     guard let event = event, event.type == UIEvent.EventType.remoteControl else { return }
    // 
    //     switch event.subtype {
    //     case .remoteControlPlay:
    //         //FRadioPlayer.shared.play()
    //         ChiplRadioController.shared.play()
    //     // case .remoteControlPause:
    //         //FRadioPlayer.shared.pause()
    //     case .remoteControlStop:
    //         ChiplRadioController.shared.stop()
    //     // case .remoteControlTogglePlayPause:
    //         //FRadioPlayer.shared.togglePlaying()
    //     //case .remoteControlNextTrack:
    //         //stationsViewController?.didPressNextButton()
    //     //case .remoteControlPreviousTrack:
    //         //stationsViewController?.didPressPreviousButton()
    //     default:
    //         break
    //     }
    // }


}

