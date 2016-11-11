//
//  PapersDataSource.swift
//  Wallpapers
//
/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/


import UIKit

class PapersDataSource {
  
  fileprivate var papers: [Paper] = []
  fileprivate var immutablePapers: [Paper] = []
  fileprivate var sections: [String] = []
  
  var count: Int {
    return papers.count
  }
  
  var numberOfSections: Int {
    return sections.count
  }
  
  // MARK: Public
  
  init() {
    papers = loadPapersFromDisk()
    immutablePapers = papers
  }
  
  func deleteItemsAtIndexPaths(_ indexPaths: [IndexPath]) {
    var indexes: [Int] = []
    for indexPath in indexPaths {
      indexes.append(absoluteIndexForIndexPath(indexPath))
    }
    var newPapers: [Paper] = []
    for (index, paper) in papers.enumerated() {
      if !indexes.contains(index) {
        newPapers.append(paper)
      }
    }
    papers = newPapers
  }
  
  func indexPathForNewRandomPaper() -> IndexPath {
    let index = Int(arc4random_uniform(UInt32(immutablePapers.count)))
    let paperToCopy = immutablePapers[index]
    let newPaper = Paper(copying: paperToCopy)
    papers.append(newPaper)
    papers.sort { $0.index < $1.index }
    return indexPathForPaper(newPaper)
  }
  
  func indexPathForPaper(_ paper: Paper) -> IndexPath {
    let section = sections.index(of: paper.section)!
    var item = 0
    for (index, currentPaper) in papersForSection(section).enumerated() {
      if currentPaper === paper {
        item = index
        break
      }
    }
    return IndexPath(item: item, section: section)
  }
  
  func movePaperAtIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath) {
    if indexPath == newIndexPath {
      return
    }
    let index = absoluteIndexForIndexPath(indexPath)
    let paper = papers[index]
    paper.section = sections[newIndexPath.section]
    let newIndex = absoluteIndexForIndexPath(newIndexPath)
    papers.remove(at: index)
    papers.insert(paper, at: newIndex)
  }
  
  func numberOfPapersInSection(_ index: Int) -> Int {
    let papers = papersForSection(index)
    return papers.count
  }
  
  func paperForItemAtIndexPath(_ indexPath: IndexPath) -> Paper? {
    if indexPath.section > 0 {
      let papers = papersForSection(indexPath.section)
      return papers[indexPath.item]
    } else {
      return papers[indexPath.item]
    }
  }
  
  func titleForSectionAtIndexPath(_ indexPath: IndexPath) -> String? {
    if indexPath.section < sections.count {
      return sections[indexPath.section]
    }
    return nil
  }
  
  // MARK: Private
  
  fileprivate func absoluteIndexForIndexPath(_ indexPath: IndexPath) -> Int {
    var index = 0
    for i in 0..<indexPath.section {
      index += numberOfPapersInSection(i)
    }
    index += indexPath.item
    return index
  }
  
  fileprivate func loadPapersFromDisk() -> [Paper] {
    sections.removeAll(keepingCapacity: false)
    if let path = Bundle.main.path(forResource: "Papers", ofType: "plist") {
      if let dictArray = NSArray(contentsOfFile: path) {
        var papers: [Paper] = []
        for item in dictArray {
          if let dict = item as? NSDictionary {
            let caption = dict["caption"] as! String
            let imageName = dict["imageName"] as! String
            let section = dict["section"] as! String
            let index = dict["index"] as! Int
            let text = dict["text"] as! String
            let paper = Paper(caption: caption, imageName: imageName, section: section, index: index, text: text)
            if !sections.contains(section) {
              sections.append(section)
            }
            papers.append(paper)
          }
        }
        return papers
      }
    }
    return []
  }
  
  fileprivate func papersForSection(_ index: Int) -> [Paper] {
    let section = sections[index]
    let papersInSection = papers.filter { (paper: Paper) -> Bool in
      return paper.section == section
    }
    return papersInSection
  }
  
}
