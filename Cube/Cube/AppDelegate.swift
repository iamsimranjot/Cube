//
//  AppDelegate.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().backgroundColor = UIColor(hex: 0x009688)
        UINavigationBar.appearance().tintColor = UIColor(hex: 0x009688)
        return true
    }


}

