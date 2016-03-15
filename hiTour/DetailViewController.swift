//
//  DetailViewController.swift
//  hiTour
//
//  Created by Dominik Kulon & Charlie Baker on 23/02/2016.
//  Copyright © 2016 stranders.kcl.ac.uk. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import MediaPlayer

///  View Controller in order to display the detail for a particular point in a tour.
///  This includes a title, description and dyanmic views to populate each peice of data content
///  for that particular point.
class DetailViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    let TEST = "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24"
    
    ///  Reference variable to a point
    var point : Point?
    
    /// Reference to audience that this point if for
    var audience: Audience!
    
    ///  Reference variable to populate the point description text
    var textDetail: UITextView!
    
    ///  AVPlayer in order to play the data item's video
    var videoPlayers : [AVPlayer!] = []
    
    /// Array storing data for the current point.
    var pointData: [PointData] = []

    ///  Outlet reference to the point's image on the storyboard
    @IBOutlet weak var imageDetail: UIImageView!
    
    /// Reference to the collection view on the storyboard.
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Reference to the flow layout on the storyboard.
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    ///  Outlet reference to the point's name title labe on the storyboard
    @IBOutlet weak var titleDetail: UILabel!
    
    ///  Outlet reference to the main scroll view for the view controller on the storyboard
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tapFullScreenGesture: UITapGestureRecognizer!
    
    
    ///  Set's up and instantiates all of the views including setting the values for the point's
    ///  title, description and image
    ///  Calls the function to populate the view controller with its content data into the stackview
    override func viewDidLoad() {
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.registerNib(UINib(nibName: "ImageDataViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageDataViewCellId")
        collectionView!.registerNib(UINib(nibName: "TextDataViewCell", bundle: nil), forCellWithReuseIdentifier: "TextDataViewCellId")
        collectionView!.registerNib(UINib(nibName: "VideoDataViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoDataViewCellId")
        
        flowLayout.minimumLineSpacing = 0.0
        
        guard let t = point, imageData = point!.data else {
            return
        }
        
        pointData = point!.getPointDataFor(audience)

        self.imageDetail!.image = UIImage(data: imageData)
        self.imageDetail!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.titleDetail.text = t.name
//        self.textDetail.text = t.descriptionP
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let url = pointData[indexPath.row].data!.url!
       
        if url.containsString(".mp4") {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoDataViewCellId", forIndexPath: indexPath) as! VideoDataViewCell
            
            cell.title.text = pointData[indexPath.row].data!.title!
            cell.dataDescription.text = pointData[indexPath.row].data!.descriptionD!
            addVideoContent(cell, dataId: "\(pointData[indexPath.row].data!.dataId!)-\(audience.audienceId!)", data: pointData[indexPath.row].data!.data!)
            
            return cell
        } else if url.containsString(".txt") {
        
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TextDataViewCellId", forIndexPath: indexPath) as! TextDataViewCell
            
            cell.title.text = pointData[indexPath.row].data!.title!
            cell.dataDescription.text = pointData[indexPath.row].data!.descriptionD!
            addTextContent(cell, url: url)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageDataViewCellId", forIndexPath: indexPath) as! ImageDataViewCell
            cell.presentingViewController = self
            
            cell.title.text = pointData[indexPath.row].data!.title!
            cell.dataDescription.text = pointData[indexPath.row].data!.descriptionD!
            cell.imageView.image = UIImage(data: pointData[indexPath.row].data!.data!)
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("ABBBA1")
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageDataViewCell {
            print("ABBBA2")
            self.performSegueWithIdentifier("imageFullScreenSegue", sender: cell.imageView)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pointData.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height : CGFloat = 300 + calculateTextViewHeight(pointData[indexPath.row].data!.descriptionD!)
        let url = pointData[indexPath.row].data!.url!

        if url.containsString(".txt") {
            do {
                let text = try String(contentsOfFile: url, encoding: NSUTF8StringEncoding)
                height += calculateTextViewHeight(text) - 200
            } catch {
                print("Error reading text file resource")
            }
        }
        
        return CGSizeMake(collectionView.frame.width, height)
    }
    
    func addTextContent(let cell: TextDataViewCell, url: String) {
        do {
            try cell.dataText.text = String(contentsOfFile: url, encoding: NSUTF8StringEncoding)
        } catch {
            cell.dataText.text = ""
            print("Error reading text file resource")
        }
    }
    
    //  Function that handles a tap gesture to the video view controller display so that it shows or hides the
    //  video player controls upon a tap.
//    func showVideoControls(sender: UITapGestureRecognizer? = nil) {
//        playerController.showsPlaybackControls = true
//    }
    
    //  Function that adds to the stack view a video and sets up its constraints and tap gesture to display its controls.
    func addVideoContent(cell: VideoDataViewCell, dataId: String, data: NSData) {

        let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tmpDirURL.URLByAppendingPathComponent(dataId).URLByAppendingPathExtension("mp4")
        let checkValidation = NSFileManager.defaultManager()
        
        if !checkValidation.fileExistsAtPath(fileURL.absoluteString) {
            
            data.writeToURL(fileURL, atomically: true)
            let videoPlayer = AVPlayer(URL: fileURL)
            let playerController = AVPlayerViewController()
            playerController.videoGravity = AVLayerVideoGravityResizeAspect
            playerController.player = videoPlayer
            cell.videStackView.addArrangedSubview(playerController.view)
        
            videoPlayers.append(videoPlayer)
        }
       
//        let tap = UITapGestureRecognizer(target: self, action: Selector("showVideoControls"))
//        tap.delegate = self
//        playerController.view.addGestureRecognizer(tap)
    }
    
    //  Prepares the view controller segue for when an image is tapped, the image displays full screen for the user to
    //  zoom and pan the image. This function prepares the FullScreenImageViewController with the image that the user has tapped on.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("ABBBA3")
        if segue.identifier == "imageFullScreenSegue" {
            print("ABBBA4")
            let destination = segue.destinationViewController as! FullScreenImageViewController
            let imageV = sender as! UIImageView
            destination.originalImageView = imageV
        }
    }
    
    // Closes down the view by ensuring any videos that are playing are stopped when the view is dismissed
    override func viewDidDisappear(animated: Bool) {
        for video in videoPlayers {
            if video != nil && video.rate != 0 && video.error == nil {
                video.pause()
            }
        }
    }
    
    func calculateTextViewHeight(text: String) -> CGFloat {
        let textView = UITextView()
        textView.scrollEnabled = false
        textView.text = text
        let fixedWidth = collectionView.frame.width * 0.8
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        return textView.frame.height + 16
    }
}
