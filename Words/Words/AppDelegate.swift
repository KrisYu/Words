//
//  AppDelegate.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    let mainViewController = NSApplication.shared.mainWindow?.contentViewController as? MainViewController
    let url = URL(fileURLWithPath: filename)
    mainViewController?.openFile(openURL: url)
    return true
  }
  
  @IBAction func autoSpeak(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
  }
  
  @IBAction func shuffleWords(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
  }
  
  
  @IBAction func help(_ sender: NSMenuItem) {
    NSWorkspace.shared.open(URL(string: "https://github.com/KrisYu/Words")!)

  }
  
  
}

