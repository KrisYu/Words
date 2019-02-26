//
//  SlideshowViewController.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Cocoa

class SlideshowViewController: NSViewController, WindowControllerDelegate {
  
  // MARK: - private property
  @objc dynamic var wordsList = [Word]()
  
  let wText = NSTextField()
  let dText = NSTextField()
  var isDefinationShowed = false
  
  let marginX: CGFloat = 20
  let marginY: CGFloat = 50
  let fontSize: CGFloat = 80
  
  var currentWordIdx = 0 {
    didSet{
      if currentWordIdx >= wordsList.count {
        self.dismissSlideshowWindow(NSButton())
      }
    }
  }
  
  var currentWord: Word {
    if currentWordIdx >= 0 && currentWordIdx < wordsList.count {
      return wordsList[currentWordIdx]
    }
    return Word(word: "Exit", defination: "", comment: "")
  }
  
  var topRect: NSRect {
    
    var topRect = self.view.bounds
    topRect.size.height = topRect.size.height / 2
    topRect.origin.y += (topRect.size.height)
    // make the upper rect smaller to look nicer?
    topRect.size.height *= 0.7
    
    return NSInsetRect(topRect, marginX, marginY)
  }
  
  var bottomRect: NSRect {
    
    var bottomRect = self.view.bounds
    bottomRect.size.height = bottomRect.size.height / 2
    
    return NSInsetRect(bottomRect, marginX, marginY)
  }

  let speech = NSSpeechSynthesizer()

  
  var autoSpeak:Bool {
    var autoSpeak = false
    
    let menus = NSApplication.shared.mainMenu?.item(withTitle: "SlideShow")?.submenu
    let state = menus?.item(withTitle: "Auto Speak")?.state.rawValue
    if state == 1 {
      autoSpeak = true
    }
    
    return autoSpeak
  }
  
  
  
  // MARK: - viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    wText.isSelectable = false
    wText.isEditable = false
    wText.drawsBackground = false
    wText.isBezeled = false
    
    
    dText.isSelectable = false
    dText.isEditable = false
    dText.drawsBackground = false
    dText.isBezeled = false
    
    wText.frame = topRect
    dText.frame = bottomRect
    
    self.view.addSubview(wText)
    self.view.addSubview(dText)
    
  }
  
  override func viewWillAppear(){
    self.view.setValue(NSColor.darkGray, forKey: "backgroundColor")
    setWText()

  }
  
  override func viewWillLayout() {
    wText.frame = topRect
    dText.frame = bottomRect
  }

  // MARK: - methods
  func setWText() {
    wText.attributedStringValue = attributedString(with: currentWord.word,
                                                   color: NSColor.white,
                                                   size: fontSize,
                                                   fittingIn: topRect.size)
    if autoSpeak {
      speech.startSpeaking(currentWord.word)
    }
    
  }
  
  func setDText() {
    dText.attributedStringValue = attributedString(with: currentWord.defination,
                                                   color: NSColor.white,
                                                   size: fontSize,
                                                   fittingIn: bottomRect.size)
  }
  
  func showDefination(){
    if isDefinationShowed {
      nextWord()
    } else {
      setDText()
      isDefinationShowed = true
    }
  }
  
  func nextWord() {
    isDefinationShowed = false
    currentWordIdx += 1
    setWText()
    
    // blank defination
    let dTextPlaceHolder = String.init(repeating: " ", count: currentWord.defination.count)
    dText.attributedStringValue = attributedString(with: dTextPlaceHolder, color: NSColor.darkGray, size: fontSize, fittingIn: bottomRect.size)
  }
  
  // MARK: - mouse & key actions
  // delegate method
  func keyDown(aEvent: NSEvent){
    // enter, space, next arrow to next word
    if aEvent.keyCode == 36 || aEvent.keyCode == 124 || aEvent.keyCode == 31 {
      showDefination()
    }
  }
  

  
  
  override func mouseDown(with event: NSEvent) {
    showDefination()
  }
  
  
  //MARK: - attributedString
  
  func font(size: CGFloat) -> NSFont{
    let font = NSFont.systemFont(ofSize: size)
    return font
  }
  
  
  func attributedString(with inString: String, color inColor: NSColor, size inFontSize: CGFloat, fittingIn inSize: NSSize) -> NSAttributedString {
    var inFontSize = inFontSize
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    let attributes : [NSAttributedString.Key: Any] = [.foregroundColor: inColor ,
                                                      .font: font(size: inFontSize),
                                                      .paragraphStyle : paragraphStyle,
                                                      .shadow: shadow()]
    
    let attributedString = NSMutableAttributedString(string: inString, attributes: attributes)
    while attributedString.height(forWidth: inSize.width) > inSize.height  {
      if inFontSize > 20 {
        inFontSize -= 10
      } else {
        inFontSize -= 1
      }
      attributedString.addAttribute(.font, value: font(size: inFontSize), range: NSMakeRange(0, attributedString.length))
      
    }
    return attributedString
  }
  
  
  func shadow() -> NSShadow {
    let shadow = NSShadow()
    
    shadow.shadowColor = NSColor.init(calibratedWhite: 0.0, alpha: 0.5)
    shadow.shadowBlurRadius = 6
    shadow.shadowOffset = NSMakeSize(2, -2)
    
    return shadow
  }
  
  
  
  @IBAction func dismissSlideshowWindow(_ sender: AnyObject) {
    NSMenu.setMenuBarVisible(true)
    let application = NSApplication.shared
    application.stopModal()
  }
  
    
}

extension NSAttributedString {
  
  func height(forWidth width: CGFloat) -> CGFloat {
    let textStorage = NSTextStorage(attributedString: self)
    let textContainer = NSTextContainer(containerSize: NSSize(width: width, height: .greatestFiniteMagnitude))
    let layoutManager = NSLayoutManager()
    
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    textContainer.lineFragmentPadding = 0
    
    layoutManager.glyphRange(for: textContainer)
    let height = layoutManager.usedRect(for: textContainer).size.height
    
    return height
  }
}
