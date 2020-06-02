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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell thinks data is \(userName)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPreset", for: indexPath)
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        let redBack = CGFloat(userRed[indexPath.row])
        let greenBack = CGFloat(userGreen[indexPath.row])
        let blueBack = CGFloat(userBlue[indexPath.row])
        let alphaBack = CGFloat(userAlpha[indexPath.row])
        print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
        cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
        
        label.textColor = UIColor.black
        label.text = userName[indexPath.row]
        
        return cell
    }
    
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
    
    override func tableView(_ tableView: UITableView, commit edititngStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        userName.remove(at: indexPath.row)
        userRed.remove(at: indexPath.row)
        userGreen.remove(at: indexPath.row)
        userBlue.remove(at: indexPath.row)
        userAlpha.remove(at: indexPath.row)
        
        setUserDefaults()
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func setLEDs(presetIndex: Int) {
        // normalize so output independent of mix of colors, only dependent on alpha
        
        let redColor = userRed[presetIndex]
        let greenColor = userGreen[presetIndex]
        let blueColor = userBlue[presetIndex]
        let alpha = userAlpha[presetIndex]
        
        let redLED = ledValue(color: "red", for: presetIndex, for: redColor)
        let greenLED = ledValue(color: "green", for: presetIndex, for: greenColor)
        let blueLED = ledValue(color: "blue", for: presetIndex, for: blueColor)
        let whiteLED = 0
        
        BTComm.shared().research.alpha = Float(alpha)
        BTComm.shared().research.red = Float(redColor)
        BTComm.shared().research.green = Float(greenColor)
        BTComm.shared().research.blue = Float(blueColor)
        
        UserDefaults.standard.set(redColor, forKey: "red")
        UserDefaults.standard.set(greenColor, forKey: "green")
        UserDefaults.standard.set(blueColor, forKey: "blue")
        UserDefaults.standard.set(alpha, forKey: "alpha")
        
        //sendToBT(color: color, white: white, red: red, green: green, blue: blue, frequency: maxFrequency, dutyCycle: maxDutyCycle)
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    func ledValue(color: String, for index: Int, for value: Float) -> Int {
        var LED = 0
        
        let red = userRed[index]
        let green = userGreen[index]
        let blue = userBlue[index]
        let alpha = userAlpha[index]
        
        let intensity = alpha * value
        
        // find lux value for the color
        let redLedLux = redCoeff[0] + intensity * (redCoeff[1] + intensity * redCoeff[2])
        let greenLedLux = greenCoeff[0] + intensity * (greenCoeff[1] + intensity * greenCoeff[2])
        let blueLedLux = blueCoeff[0] + intensity * (blueCoeff[1] + intensity * blueCoeff[2])
        
        // find scaling factors
        var maxLux = redLedLux
        if greenLedLux < maxLux {
            maxLux = greenLedLux
        }
        if blueLedLux < maxLux {
            maxLux = blueLedLux
        }
        
        let redScale = redLedLux / maxLux
        let greenScale = greenLedLux / maxLux
        let blueScale = blueLedLux / maxLux
        
        if color == "red" {
            LED = Int(ADCMaximumValue * redScale * red * alpha)
        } else if color == "green" {
            LED = Int(ADCMaximumValue * greenScale * green * alpha)
        } else if color == "blue" {
            LED = Int(ADCMaximumValue * blueScale * blue * alpha)
        }
        
        return LED
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
