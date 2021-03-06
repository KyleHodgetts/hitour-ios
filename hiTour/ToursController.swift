//
//  ToursController.swift
//  hiTour
//
//  Created by Dominik Kulon on 22/02/2016.
//  Copyright © 2016 stranders.kcl.ac.uk. All rights reserved.
//

import Foundation
import UIKit

/// The collection view that allows switching between tours.
class ToursController : UICollectionViewController {
    
    /// The flow layout responsible for defining position of collection cells.
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var tours: [Tour] = []
    
    /// Set up the size of a collection cell wrt the screen size.
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.registerNib(UINib(nibName: "ToursControllerCell", bundle: nil), forCellWithReuseIdentifier: "ToursControllerCellId")
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let v = self.storyboard!.instantiateViewControllerWithIdentifier("SplitViewController") as! UISplitViewController
            flowLayout.itemSize = CGSize(width: v.primaryColumnWidth * 0.98, height: screenSize.height / 3)
        } else {
            flowLayout.itemSize = CGSize(width: (screenSize.width - 22) / 2, height: screenSize.height / 3)
        }
        updateTours()
    }
    
    /// Reload the data when the view appears.
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.reloadData()
    }
    
    /// Update tours in a collection view.
    func updateTours() {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let coredata = delegate?.getCoreData()
        
        guard let nSessions = coredata?.fetch(name: Session.entityName).flatMap({$0 as? [Session]}) else {
            return
        }
        
        tours = nSessions.flatMap{$0.tour}
        collectionView?.reloadData()
    }
    
    /// Define layout details for each cell.
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ToursControllerCellId", forIndexPath: indexPath) as! ToursControllerCell
        
        cell.layer.cornerRadius = 7;
        let institution : String = tours[indexPath.row].name!
        cell.labelTitle.text = institution
        cell.labelDate.text = "N/A"
        
        // Get the tour expiration date.
        // There might be multiple sessions for the same tour 
        // so the code below is respondsible for finding the latest date.
        let tour = tours[indexPath.row]
        if let sessions = tour.sessions {
            let latestSession =
            (sessions.allObjects as? [Session])
                .flatMap({s in s.reduce(nil, combine: {(acc: Session?, ses: Session) in
                    if let accDate = acc?.endData, sesDate = ses.endData {
                        if(accDate.earlierDate(sesDate) == sesDate) {
                            return acc
                        } else {
                            return ses
                        }
                    } else {
                        return ses
                    }
                })
            })
            // Update the cell's date label with the latest date.
            if let session = latestSession {
                if let date = session.endData {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    cell.labelDate.text = dateFormatter.stringFromDate(date)
                    print(date)
                }
            }
        }
        
        return cell
    }
    
    /// - Returns: The number of items in the collection.
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tours.count
    }
    
    /// Switch the tour when the cell has been selected.
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        delegate?.setTour(tours[indexPath.row])
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.tabBarController?.selectedIndex = 0
            let feedControlelr = self.tabBarController?.selectedViewController as! FeedController
            feedControlelr.assignTour(tours[indexPath.row])
        } else {
            self.tabBarController?.selectedIndex = 0
            let feedControlelr = self.tabBarController?.selectedViewController?.childViewControllers.first! as! FeedController
            feedControlelr.assignTour(tours[indexPath.row])
        }
    }
    
}