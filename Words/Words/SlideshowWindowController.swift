//
//  SlideshowWindowController.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Cocoa

protocol WindowControllerDelegate {
  func keyDown(aEvent: NSEvent)
}

class SlideshowWindowController: NSWindowController {
  
  var delegate: WindowControllerDelegate?
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    guard let window = window,
      let screen = window.screen
      else { return }

    window.setFrame(window.frameRect(forContentRect: screen.frame), display: true)
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    
    // hide the dock and menu bar 
    NSMenu.setMenuBarVisible(false)

    delegate = window.contentViewController as! SlideshowViewController
    
  }
  
  override func keyDown(with event: NSEvent) {
    delegate?.keyDown(aEvent: event)
  }
  
  //handles escape key pressed
  @objc func cancel(_ sender: Any?){
    NSMenu.setMenuBarVisible(true)
    NSApplication.shared.stopModal()
  }


}
