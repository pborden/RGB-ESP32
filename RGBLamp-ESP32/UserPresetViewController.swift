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

class UserPresetViewController: UITableViewController { // EditViewControllerDelegate {
    /*func EditViewControllerDidCancel(_ controller: EditViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func EditViewController(_ controller: EditViewController, didFinishEditing item: Preset) {
        
        navigationController?.popViewController(animated: true)
    } */
    
    //Mark:-Presets.
    
    var userName: [String] = []
    var userGreen: [Float] = []
    var userRed: [Float] = []
    var userBlue: [Float] = []
    var userAlpha: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pass values through user defaults
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserDefaults()
        self.tableView.reloadData()
        print("View appearing")
        print("Preset names from user defaults: \(userName)")
    }
    
    // make view disappear so it reloads and refreshes list of user presets
    override func viewWillDisappear(_ animated: Bool) {
        print("View disappearing")
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    } */
    
    // Number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell thinks data is \(userName)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPreset", for: indexPath)
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        // set background color of cell same as associated lamp hue RGB, alpha values
        let redBack = CGFloat(userRed[indexPath.row])
        let greenBack = CGFloat(userGreen[indexPath.row])
        let blueBack = CGFloat(userBlue[indexPath.row])
        let alphaBack = CGFloat(userAlpha[indexPath.row])
        print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
        cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
        
        // text in cell is black; put name of saved preset in cell
        label.textColor = UIColor.black
        label.text = userName[indexPath.row]
        
        return cell
    }
    
    // if row selected, set lamp color to hue associated with row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        
        setLEDs(presetIndex: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // provide abiity to delete a row using the swipe left and delete method
    override func tableView(_ tableView: UITableView, commit edititngStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        userName.remove(at: indexPath.row)
        userRed.remove(at: indexPath.row)
        userGreen.remove(at: indexPath.row)
        userBlue.remove(at: indexPath.row)
        userAlpha.remove(at: indexPath.row)
        
        // save new arrays without removed value
        setUserDefaults()
        
        // remove row from table
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func setLEDs(presetIndex: Int) {
        // normalize so output independent of mix of colors, only dependent on alpha
        
        // read associated RGB values and alpha
        let redColor = userRed[presetIndex]
        let greenColor = userGreen[presetIndex]
        let blueColor = userBlue[presetIndex]
        let alpha = userAlpha[presetIndex]
        
        // convert to LED values using routine in ADCMaxValue.swift
        let redLED = ledValue(color: "red", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let greenLED = ledValue(color: "green", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let blueLED = ledValue(color: "blue", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let whiteLED: Int = 0
        
        // save selected hue as current values
        saveValues(for: redColor, for: greenColor, for: blueColor, for: alpha)
        
        //sendToBT(color: color, white: white, red: red, green: green, blue: blue, frequency: maxFrequency, dutyCycle: maxDutyCycle)
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    func loadUserDefaults() {
        userName = UserDefaults.standard.stringArray(forKey: "userName") ?? [String]()
        userRed = UserDefaults.standard.array(forKey: "userRed") as? [Float] ?? [Float]()
        userGreen = UserDefaults.standard.array(forKey: "userGreen") as? [Float] ?? [Float]()
        userBlue = UserDefaults.standard.array(forKey: "userBlue") as? [Float] ?? [Float]()
        userAlpha = UserDefaults.standard.array(forKey: "userAlpha") as? [Float] ?? [Float]()
    }
    
    func setUserDefaults() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userRed, forKey: "userRed")
        UserDefaults.standard.set(userGreen, forKey: "userGreen")
        UserDefaults.standard.set(userBlue, forKey: "userBlue")
        UserDefaults.standard.set(userAlpha, forKey: "userAlpha")
    }

}
