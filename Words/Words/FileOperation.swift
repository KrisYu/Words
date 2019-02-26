//
//  FileOperation.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Foundation

struct FileOperation {
  
  
  /// openFile
  ///
  /// - Parameters:
  ///   - file: file URL
  ///   - lessons: generated lesson
  /// - Returns: opens successfully or not
  static func open(file: URL?, lessons: inout [Lesson]) -> Bool {
    guard let file = file else { return false }
    
    do {
      let data = try Data(contentsOf: file)
      let jsonDecoder = JSONDecoder()
      lessons = try jsonDecoder.decode([Lesson].self, from: data)
      return true
    } catch {
      print("Errors opening file")
      return false
    }
  }
  
  static func importFrom(file: URL?, toLines lines: inout [String]) -> Bool {
    guard let file = file else { return false }
    
    do {
      let data = try String(contentsOf: file, encoding: .utf8)
      lines = data.components(separatedBy: .newlines)
      return true
    } catch {
      print("Errors import file")
      return false
    }
  }
  
  static func saveDataTo(file: URL?, lessonsList: [Lesson]) -> Bool {
    guard let file = file else { return false }
    
    do {
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(lessonsList)
      try jsonData.write(to: file)
      return true
    } catch {
      print("Save data failed")
      return false
    }
  }
  
}
