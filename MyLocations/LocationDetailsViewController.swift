//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 04/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch // library for asychronous tasks
import CoreData

class LocationDetailsViewController: UITableViewController {
    
    // MARK: outlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    // MARK: var and let
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = NSDate()
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    var image: UIImage?
    var observer: AnyObject!
    
    deinit {
        print("deinit \(self)")
        
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
    
    // MARK: private var and let
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    // MARK: @IBActions
    @IBAction func done(){
        
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        let location: Location
        
        if let temp = locationToEdit {
            
            hudView.text = "Updated"
            location = temp
        } else {
            
            hudView.text = "Tagged"
        // 1 - create a new location object from CoreData
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
            location.photoID = nil
        
        }
        
        // 2 - proprietes for object
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.placemark = placemark
        location.date = date
        
        if let image = image {
            // 1 - need new ID for a location without a photo, otherwise, keep the same photo
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            // 2 - converting to jpg
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                // 3 - save NSData object
                do {
                    try data.writeToFile(location.photoPath, options: .DataWritingAtomic)
                } catch {
                    print("Error writting data \(error)")
                }
            }
        }
        
        // 3 - save new modified object
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        
        afterDelay(0.6, closure: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func cancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    // MARK : func's
    
    // listenForBackground
    // adds observer for NSNotification and call closure
    
    func listenForBackgroundNotification(){
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if let strongSelf = self {
            if strongSelf.presentedViewController != nil {
                strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
            strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    // showImage
    
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
    
    // hide keyboard on tableView
    func hideKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    // make string from placemark
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + ", "
        }
        
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        
        if let s = placemark.administrativeArea {
            text += s + ", "
        }
        
        if let s = placemark.postalCode {
            text += s + ", "
        }
        
        if let s = placemark.country {
            text += s + ", "
        }
        
        return text
    }
    
    // formateDate method
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    
    // MARK: override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
            if let image = location.photoImage {
                showImage(image)
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address found"
        }
        
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor.blackColor()
        
        addPhotoLabel.textColor = UIColor.whiteColor()
        addPhotoLabel.backgroundColor = UIColor.blackColor()
        
        addressLabel.textColor = UIColor.whiteColor()
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        
    }
    
    // MARK : UITablewViewDelegate section
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row){
        case (0,0):
            return 88
        case (1, _):
            return imageView.hidden ? 44 : 280
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
            
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }
    
    // MARK: segue section
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: func for camera pick
    
    func takePhotoWithCamera(){
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.view.tintColor = view.tintColor
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: func for library pick
    
    func choosePhotoFromLibrary(){
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.view.tintColor = view.tintColor
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = image {
            showImage(image)
        }
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
    }


}
