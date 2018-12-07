//
//  AppDelegate.swift
//  RsaTest
//
//  Created by Nick on 2018/12/5.
//  Copyright © 2018 kcin.nil.app. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

public func print<T>(msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    Swift.print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(msg)")
    #endif
}
