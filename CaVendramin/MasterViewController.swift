//
//  MasterViewController.swift
//  Papers
//
//  Created by Massimo Moro on 10/11/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation

class MasterViewController: UICollectionViewController,CLLocationManagerDelegate {
    private var paperDataSource = PapersDataSource()
    
    //Beacons var
    @IBOutlet weak var lblBeaconReport: UILabel!
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsInit()
        switchSpotting()
        let width = collectionView!.frame.width / 3
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    func beaconsInit ()  {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = NSUUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid as! UUID, identifier: "com.appcoda.beacondemo")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyEntryStateOnDisplay = true
    }
    
    func switchSpotting() {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startUpdatingLocation()
            
          //  btnSwitchSpotting.setTitle("Stop Spotting", for: UIControlState())
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            //btnSwitchSpotting.setTitle("Start Spotting", for: UIControlState())
            lblBeaconReport.text = "Not running"
           // lblBeaconDetails.isHidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
            print(error)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
       // lblBeaconDetails.isHidden = false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
       // lblBeaconDetails.isHidden = true
    }
    private func locationManager(_ manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var shouldHideBeaconDetails = true
        
        if let foundBeacons = beacons {
            if foundBeacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.immediate:
                            proximityMessage = "Very close"
                            
                        case CLProximity.near:
                            proximityMessage = "Near"
                            
                        case CLProximity.far:
                            proximityMessage = "Far"
                            
                        default:
                            proximityMessage = "Where's the beacon?"
                        }
                        
                        shouldHideBeaconDetails = false
                        
            //            lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.int32Value) + "\nMinor = " + String(closestBeacon.minor.int32Value) + "\nDistance: " + proximityMessage
                    }
                }
            }
        }
        
       // lblBeaconDetails.isHidden = shouldHideBeaconDetails
    }
    
    //Collection
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
    
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
