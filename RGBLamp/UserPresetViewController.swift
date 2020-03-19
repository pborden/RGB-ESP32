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

class UserPresetViewController: UITableViewController, EditViewControllerDelegate {
    func EditViewControllerDidCancel(_ controller: EditViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func EditViewController(_ controller: EditViewController, didFinishEditing item: Preset) {
        
        navigationController?.popViewController(animated: true)
    }
    
    //Mark:-Presets. Create instance of the main View Controller, then transfer saved user array.
    // Need to lazy initialize userArray to avoid initialization error.
    var newViewController = ViewController()
    lazy var names: [String] = newViewController.userName
    lazy var reds: [Float] = newViewController.userRed
    lazy var greens: [Float] = newViewController.userGreen
    lazy var blues: [Float] = newViewController.userBlue
    lazy var alphas: [Float] = newViewController.userAlpha
    
    var userName: [String] = []
    var userGreen: [Float] = []
     var userRed: [Float] = []
     var userBlue: [Float] = []
     var userAlpha: [Float] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pass values through user defaults
        userName = UserDefaults.standard.stringArray(forKey: "userName") ?? [String]()
        userRed = UserDefaults.standard.array(forKey: "userRed") as? [Float] ?? [Float]()
        userGreen = UserDefaults.standard.array(forKey: "userGreen") as? [Float] ?? [Float]()
        userBlue = UserDefaults.standard.array(forKey: "userBlue") as? [Float] ?? [Float]()
        userAlpha = UserDefaults.standard.array(forKey: "userAlpha") as? [Float] ?? [Float]()
        // pass values directly
        names = newViewController.userName
        reds = newViewController.userRed
        greens = newViewController.userGreen
        blues = newViewController.userBlue
        alphas = newViewController.userAlpha

            print("Preset names: \(userName)")
            print("Names passed: \(names)")
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
        return userName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPreset", for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit edititngStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        names.remove(at: indexPath.row)
        reds.remove(at: indexPath.row)
        greens.remove(at: indexPath.row)
        blues.remove(at: indexPath.row)
        alphas.remove(at: indexPath.row)
        
        UserDefaults.standard.set(names, forKey: "userName")
        UserDefaults.standard.set(reds, forKey: "userRed")
        UserDefaults.standard.set(greens, forKey: "userGreen")
        UserDefaults.standard.set(blues, forKey: "userBlue")
        UserDefaults.standard.set(alphas, forKey: "userAlpha")
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

}
