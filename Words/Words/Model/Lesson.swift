//
//  Lesson.swift
//  Words
//
//  Created by Xue Yu on 2019/2/24.
//  Copyright © 2019 XueYu. All rights reserved.
//

import Foundation


class Lesson: NSObject, Codable {
  @objc dynamic var name: String
  @objc dynamic var wordsList: [Word]
  
  init(name: String, wordsList: [Word]) {
    self.name = name
    self.wordsList = wordsList
  }
}
