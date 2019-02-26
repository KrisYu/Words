//
//  ViewController.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

  // MARK: - property
  @IBOutlet weak var wordTextField: NSTextField!
  @IBOutlet weak var definationTextField: NSTextField!
  @IBOutlet weak var commentTextField: NSTextField!
  
  @IBOutlet weak var wordsTableView: NSTableView!
  @IBOutlet weak var lessonsTableView: NSTableView!
  
  @IBOutlet var wordsListArrayController: NSArrayController!
  @objc dynamic var wordsList = [Word]()
  
  @IBOutlet var lessonsListArrayController: NSArrayController!
  @objc dynamic var lessonsList: [Lesson] = [Lesson(name: "Lesson 1", wordsList: [])]
  
  @IBOutlet weak var slideShowButton: NSButton!
  
  var selectedLessonIdx = 0
  {
    didSet {
      if selectedLessonIdx >= 0 && selectedLessonIdx < lessonsList.count {
        lessonsTableView.selectRowIndexes(IndexSet(integer: selectedLessonIdx), byExtendingSelection: false)
        wordsList = lessonsList[selectedLessonIdx].wordsList
        wordsTableView.reloadData()
        print("selectedLessonIdx: \(selectedLessonIdx)")
      }
    }
  }
  
  var shuffleWords: Bool {
    var shuffleWords = false
    
    let menus = NSApplication.shared.mainMenu?.item(withTitle: "SlideShow")?.submenu
    let state = menus?.item(withTitle: "Shuffle Words")?.state.rawValue
    if state == 1 {
      shuffleWords = true
    }
    
    return shuffleWords
  }
  
  
  // MARK: - outlet action
  @IBAction func addButtonClicked(_ sender: NSButton) {
    
    let word = wordTextField.stringValue
    let defination = definationTextField.stringValue
    let comment = commentTextField.stringValue
    
    let nullString = word.isEmpty && defination.isEmpty && comment.isEmpty
    
    if !nullString {
      wordTextField.stringValue = ""
      definationTextField.stringValue = ""
      commentTextField.stringValue = ""
      
      wordsList.append(Word(word: word, defination: defination, comment: comment))
      
      wordsTableView.reloadData()
      
      wordTextField.becomeFirstResponder()
    }
  }
  
  @objc func enterActionForTextFields(sender: NSTextField) {
    if sender == wordTextField {
      definationTextField.becomeFirstResponder()
    }
    if sender == definationTextField {
      commentTextField.becomeFirstResponder()
    }
    if sender == commentTextField {
      addButtonClicked(NSButton())
    }
  }
  
  // MARK: - lessonsTableView action
  @IBAction func addLessonClicked(_ sender: NSButton) {
    // save the previous lesson before append
    savePrevLesson()
    
    let lessonName = "Lesson \(lessonsList.count + 1)"
    lessonsList.append(Lesson(name: lessonName, wordsList: []))
    selectedLessonIdx = lessonsList.count - 1
    enableTextFields()
  }
  
  @IBAction func deleteLessonClicked(_ sender: NSButton) {
    
    if let selectedLesson = lessonsListArrayController.selectedObjects.first as? Lesson {
      lessonsListArrayController.removeObject(selectedLesson)
    }
    
    enableTextFields()
  }
  
  
  
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    guard let tableView = notification.object as? NSTableView else { return }
    
    if tableView == lessonsTableView {
      selectedLessonIdx = tableView.selectedRow
      enableTextFields()
      print("selectedLessonIdx: \(selectedLessonIdx)")
    }
  }
  
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    if tableView == lessonsTableView {
      
      guard lessonsTableView.selectedRowIndexes.count > 0 else { return true }
      
      // get the currently selected row
      
      let index = lessonsTableView.selectedRow
      lessonsList[index] = Lesson(name: lessonsList[index].name, wordsList: wordsList)
    }
    return true
  }
  
  // MARK: - wordsTableView action
  // delete selected words
  @IBAction func deleteWordsRows(_ sender: AnyObject) {
    wordsListArrayController.remove(atArrangedObjectIndexes: wordsListArrayController.selectionIndexes)
  }

  
  // MARK: - viewDidLoad
  override func viewDidLoad() {
    wordsTableView.delegate = self
    wordsTableView.dataSource = self
    lessonsTableView.delegate = self
    lessonsTableView.dataSource = self


    wordTextField.target = self
    wordTextField.action = #selector(enterActionForTextFields(sender:))
    
    definationTextField.target = self
    definationTextField.action = #selector(enterActionForTextFields(sender:))
    
    commentTextField.target = self
    commentTextField.action = #selector(enterActionForTextFields(sender:))
  
  }
  
  override func viewWillAppear() {
    
    let indexSet = IndexSet(integer: 0)
    lessonsTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
  }
  
  
  
  // MARK: - MenuItem Actions
  @IBAction func importFile(sender: NSMenuItem){
    guard let window = view.window else { return }
    
    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = ["txt", "csv"]
    
    panel.beginSheetModal(for: window) { (result) in
      if result == NSApplication.ModalResponse.OK {
        self.parseFile(file: panel.url)
      }
    }
  }
  
  @IBAction func saveFile(sender: NSMenuItem) {
    guard let window = view.window else { return }
    
    let panel = NSSavePanel()
    panel.allowedFileTypes = ["wnb"]
    panel.nameFieldStringValue = "Untitled.wnb"
    
    panel.beginSheetModal(for: window) { (result) in
      if result == NSApplication.ModalResponse.OK {
        FileOperation.saveDataTo(file: panel.url, lessonsList: self.lessonsList)
      }
    }
  }
  
  @IBAction func openFile(sender: NSMenuItem) {
    guard let window = view.window else { return }
    
    let panel = NSOpenPanel()
    panel.allowedFileTypes = ["wnb"]
    panel.allowsMultipleSelection = false
    
    panel.beginSheetModal(for: window) { (result) in
      let openUrl = panel.url
      self.openFile(openURL: openUrl)
    }
  }
  
  
  // MARK: - helper function
  // parse imported file to a new Lesson
  func parseFile(file: URL?) {
    
    guard let file = file else { return }
    
    let separator = file.pathExtension == "txt" ? CharacterSet.whitespaces : CharacterSet(charactersIn: ",")
    let filename = file.deletingPathExtension().lastPathComponent
    
    var lines = [String]()
    
    
    if FileOperation.importFrom(file: file, toLines: &lines) {
      var wordsList = [Word]()
      
      for line in lines {
        if let word = Word(line: line, separator: separator) {
          wordsList.append(word)
        }
      }
      
      // save the previous lesson before append
      savePrevLesson()

      lessonsList.append(Lesson(name: filename, wordsList: wordsList))
      selectedLessonIdx = lessonsList.count - 1
      print("selectedLessonIdx: \(selectedLessonIdx)")
    }
  }

  
  // open a file and select index 0
  func openFile(openURL: URL?) {
    FileOperation.open(file: openURL, lessons: &self.lessonsList)
    if lessonsList.count > 0 {
      selectedLessonIdx = 0
    }
  }
  
  func savePrevLesson() {
    // save the last lesson, if exists
    if selectedLessonIdx >= 0 && selectedLessonIdx < lessonsList.count {
      lessonsList[selectedLessonIdx] = Lesson(name: lessonsList[selectedLessonIdx].name, wordsList: wordsList)
    }
  }

  
  func enableTextFields(){
    // will not enable the textfield if no lesson
    wordTextField.isEditable = (lessonsList.count > 0 && (selectedLessonIdx >= 0 && selectedLessonIdx < lessonsList.count))
    definationTextField.isEditable = (lessonsList.count > 0 && (selectedLessonIdx >= 0 && selectedLessonIdx < lessonsList.count))
    commentTextField.isEditable = (lessonsList.count > 0 && (selectedLessonIdx >= 0 && selectedLessonIdx < lessonsList.count))
  }
  
  // MARK: - segue
  @IBAction func slideShow(_ sender: NSButton) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let slideshowWindowController = storyboard.instantiateController(withIdentifier: "Slideshow Window Controller") as! SlideshowWindowController
    
    let slideshowViewController = slideshowWindowController.contentViewController as! SlideshowViewController
    
    
    print("set words list")
    if shuffleWords {
      slideshowViewController.wordsList = wordsList.shuffled()
    } else {
      slideshowViewController.wordsList = wordsList
    }
    
    
    let application = NSApplication.shared
    guard let window = slideshowViewController.view.window else { return }
    application.runModal(for: window)
    
    window.close()
  }
  
  
}

extension MainViewController: NSTableViewDelegate{
  
  // use this to display row #
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      guard let tableColumn = tableColumn else { return nil }
      
      let cellView = tableView.makeView(withIdentifier: tableColumn.identifier, owner: nil) as? NSTableCellView
      
      if tableColumn.title == "#" {
        cellView?.textField?.stringValue = "\(row + 1)"
      }
      return cellView
  }
}

extension MainViewController: NSTableViewDataSource{
  
}
