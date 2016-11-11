//
//  MasterViewController.swift
//  Papers
//
//  Created by Massimo Moro on 10/11/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class MasterViewController: UICollectionViewController {
    private var paperDataSource = PapersDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = collectionView!.frame.width / 2
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        var a = paperDataSource.numberOfSections
        return paperDataSource.numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paperDataSource.numberOfPapersInSection(section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
        if let title = paperDataSource.titleForSectionAtIndexPath(indexPath) {
            sectionView.title = title
        }
        
        return sectionView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath) as! ItemsCell
        
        if let item = paperDataSource.paperForItemAtIndexPath(indexPath) {
            cell.item = item
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MasterToDetail" {
            if let indexPath = collectionView!.indexPathsForSelectedItems!.first as? NSIndexPath {
                if let item = paperDataSource.paperForItemAtIndexPath(indexPath as IndexPath) {
                    let detailViewController = segue.destination as! DetailViewController
                    detailViewController.paper = item
                }
            }
        }
    }
}
