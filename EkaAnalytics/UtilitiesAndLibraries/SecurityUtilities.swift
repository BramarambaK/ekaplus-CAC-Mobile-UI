//
//  SecurityUtilities.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 20/12/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import Foundation


class SecurityUtilities {
    
    
    func isJailbroken() -> Bool {
        if TARGET_IPHONE_SIMULATOR != 1
        {
            // Check 1 : check if we can open Cydia App
            if UIApplication.shared.canOpenURL(URL(string: "cydia://")!) {
                return true
            }
            
            // Check 2 : existence of files that are common for jailbroken devices
            if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                || FileManager.default.fileExists(atPath: "/Applications/RockApp.app")
                || FileManager.default.fileExists(atPath: "/Applications/Icy.app")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                || FileManager.default.fileExists(atPath: "/bin/bash")
                || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                || FileManager.default.fileExists(atPath: "/etc/apt")
                || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist")
                || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.ikey.bbot.plist")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/Veency.plist")
                || FileManager.default.fileExists(atPath: "/bin/sh")
                || FileManager.default.fileExists(atPath: "/usr/libexec/sftp-server")
                || FileManager.default.fileExists(atPath: "usr/libexec/ssh-keysign")
                || FileManager.default.fileExists(atPath: "/pangueaxe")
                || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/io.pangu.axe.untether.plist")
                || FileManager.default.fileExists(atPath: "/private/var/stash")
                || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)
            {
                return true
            }
            // Check 3 : Reading and writing in system directories (sandbox violation)
            let stringToWrite = "Jailbreak Test"
            do
               {
                try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
                //Device is jailbroken
                return true
               }catch
               {
                return false
               }
            
        }else
        {
            return false
        }
    }
    
    func ExitOnJailbreak() {
        if isJailbroken() == true {
            // Exit the app if Jailbroken
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
    
    
}
