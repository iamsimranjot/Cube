//
//  AppDelegate.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

/* The Project meets the specifications of searching a movie and then displaying its required details to the user. Allowing user to filter with type option has been modified as the results shown on seacrh are already filterd by type for better user experience. Cool Animations has been applied to both the view controllers also. The Application has followed the MVC Design Pattern. Proper commenting of code and eficient use of language has been done in regards with the coding standard. */

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

