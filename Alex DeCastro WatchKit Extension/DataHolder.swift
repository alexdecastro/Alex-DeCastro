//
//  DataHolder.swift
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//
//  Singleton pattern in swift
//  http://code.martinrue.com/posts/the-singleton-pattern-in-swift
//

import Foundation

class DataHolder {
    class var sharedInstance: DataHolder {
        struct Static {
            static var instance: DataHolder?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataHolder()
        }
        
        return Static.instance!
    }
    
    var appState:String {
        set {
            let defaults = NSUserDefaults(suiteName: "group.com.alexdecastro.wordgame.v01")
            defaults?.setObject(appState, forKey: "kAppState")
            defaults?.synchronize()
        }
        get {
            let defaults = NSUserDefaults(suiteName: "group.com.alexdecastro.wordgame.v01")
            defaults?.synchronize()
            if let receivedString = defaults!.stringForKey("kAppState") {
                return receivedString
            }
            return "01-Initial-State"
        }
    }
}
