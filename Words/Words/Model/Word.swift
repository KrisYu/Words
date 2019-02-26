//
//  Word.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Foundation

class Word: NSObject, Codable {
  
  @objc dynamic var word: String
  @objc dynamic var defination: String
  @objc dynamic var comment: String
  
  init(word: String, defination: String, comment: String ) {
    self.word = word
    self.defination = defination
    self.comment = comment
  }
  
  convenience init?(line: String, separator: CharacterSet) {
    
    let array = line.components(separatedBy: separator)
    
    if array.count == 2 {
      self.init(word: array[0], defination: array[1], comment: "")
    } else if array.count == 3 {
      self.init(word: array[0], defination: array[1], comment: array[2])
    } else {
      return nil
    }
    
  }
  
  
  override public var description: String {
    return "word: \(word), defination: \(defination), comment: \(comment)"
  }
  
  
  
}
