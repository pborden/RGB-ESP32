//
//  UserPresetViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/26/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//  Handles user presets
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

class UserPresetViewController: UITableViewController {
    
    //Mark: Presets.
    var userName: [String] = []
    var userRed: [Float] = []
    var userGreen: [Float] = []
    var userBlue: [Float] = []
    var userAlpha: [Float] = []
    var selectedElement: IndexPath = [4, 0] // set to non-existent section so no check appears at start
    let numberOfSettingsToLoad = 5  //when changing, also change line below in name
    var firstElement: Preset = Preset(name: "Touch to upload 5 most recent to lamp", red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0, editable: false, check: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
        return userName.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell thinks data is \(userName)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPreset", for: indexPath)
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        if ((selectedElement.section == 1) && (selectedElement.row == indexPath.row)){
            cell.accessoryType = .checkmark
            print("section 0 row \(indexPath.row) has check")
        } else {
            cell.accessoryType = .none
        }
        if indexPath.section == 0 {
            let redBack = CGFloat(firstElement.red)
            let greenBack = CGFloat(firstElement.green)
            let blueBack = CGFloat(firstElement.blue)
            let alphaBack = CGFloat(firstElement.alpha)
            print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
            cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
            
            // text in cell and checkmark is black; put name of saved preset in cell
            label.textColor = UIColor.systemBlue
            cell.tintColor = UIColor.black
            label.text = firstElement.name
            
        } else {
            // set background color of cell same as associated lamp hue RGB, alpha values
            let redBack = CGFloat(userRed[indexPath.row])
            let greenBack = CGFloat(userGreen[indexPath.row])
            let blueBack = CGFloat(userBlue[indexPath.row])
            let alphaBack = CGFloat(userAlpha[indexPath.row])
            print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
            cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
            
            // text in cell and checkmark is black; put name of saved preset in cell
            label.textColor = UIColor.black
            cell.tintColor = UIColor.black
            label.text = userName[indexPath.row]
        } // else
        
        return cell
    }
    
    // if row selected, set lamp color to hue associated with row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        // place a check mark in the selected row to indicate it was selected
        if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        if indexPath.section == 0 {  // upload presets to lamp
            loadSettingsToLamp()
        } else {
            let redColor = userRed[indexPath.row]
            let greenColor = userGreen[indexPath.row]
            let blueColor = userBlue[indexPath.row]
            let alpha = userAlpha[indexPath.row]
            setLEDs(redColor: redColor, greenColor: greenColor, blueColor: blueColor, alpha: alpha)
        }
        
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
    
    func setLEDs(redColor: Float, greenColor: Float, blueColor: Float, alpha: Float) {
        // normalize so output independent of mix of colors, only dependent on alpha
        
        // convert to LED values using routine in ADCMaxValue.swift
        let redLED = ledValue(color: "red", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let greenLED = ledValue(color: "green", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let blueLED = ledValue(color: "blue", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let whiteLED: Int = 0
        
        // save selected hue as current values
        saveValues(for: redColor, for: greenColor, for: blueColor, for: alpha)
        
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    func loadSettingsToLamp() {
        // upload last five settings; put in delay so lamp will rapidly flash through them
        // first, upload a zero output setting (provides way to turn lamp off)
        let redOff: Float = 0.9
        let greenOff: Float = 0.9
        let blueOff: Float = 0.9
        let alphaOff: Float = 0.0
        
        setLEDs(redColor: redOff, greenColor: greenOff, blueColor: blueOff, alpha: alphaOff)
        
        let numberOfSettings = userName.count
        var uploadCount = numberOfSettingsToLoad
        if uploadCount > numberOfSettings {
            uploadCount = numberOfSettings
        }
        var firstIndex = numberOfSettings - uploadCount
        if firstIndex < 0 {
            firstIndex = 0
        }
        
            var i = firstIndex

            func nextIteration() {
                if i < numberOfSettings {
                    let redColor = userRed[i]
                    let greenColor = userGreen[i]
                    let blueColor = userBlue[i]
                    let alpha = userAlpha[i]
                    setLEDs(redColor: redColor, greenColor: greenColor, blueColor: blueColor, alpha: alpha)
                    i+=1
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        nextIteration()
                    }
                }
            }
            nextIteration()
    } // loadSettingsToLamp
    
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
