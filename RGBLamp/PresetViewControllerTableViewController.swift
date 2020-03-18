//
//  PresetViewControllerTableViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/26/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit

struct Preset {
    var name: String = ""
    var red: Double = 0.9
    var green: Double = 0.9
    var blue: Double = 0.9
    var alpha: Double = 0.9
    var editable: Bool = true
    var check: Bool = false
}

class PresetViewControllerTableViewController: UITableViewController, EditViewControllerDelegate {
    func EditViewControllerDidCancel(_ controller: EditViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func EditViewController(_ controller: EditViewController, didFinishEditing item: Preset) {
        
        navigationController?.popViewController(animated: true)
    }
    
    //Mark:-Presets. Create instance of the main View Controller, then transfer saved user array.
    // Need to lazy initialize userArray to avoid initialization error.
    var newViewController = ViewController()
    lazy var userArray: [Hue] = newViewController.userPresets
    
    //var userArray = sourceViewController.savedHues
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count
    }

    
    


}
