//
//  CategoryPickedViewController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 04/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class CategoryPickedViewController: UITableViewController {
    
    // MARK : var and let
    
    var selectedCategoryName = ""
    
    let categories = [
        "No category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
    ]
    
    
    var selectedIndexPath = NSIndexPath()
    
    // MARK : func's
    
    
    
    
    // MARK : override func
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    // number of rows
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    // cell for row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // didSelectRowAtIndexPath
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            
            if let oldCell = tableView.cellForRowAtIndexPath(indexPath) {
                oldCell.accessoryType = .None
            }
            
            selectedIndexPath = indexPath
        }
    }
    
    
}
