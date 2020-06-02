//
//  FixedPresetViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/29/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit

class FixedPresetViewController: UITableViewController {
    
    var fixedPresetArray = [Preset(name: "Macular Degeneration", red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0, editable: false, check: false),
                            Preset(name: "Glaucoma", red: 0.1, green: 0.9, blue: 0.9, alpha: 0.5, editable: false, check: false),
    Preset(name: "Retinitis Pigmentosa", red: 0.9, green: 0.3, blue: 0.5, alpha: 0.9, editable: false, check: false),
    Preset(name: "Diabetic Retinopathy", red: 0.5, green: 0.9, blue: 0.4, alpha: 0.9, editable: false, check: false),
    Preset(name: "Cold white (most blue, daytime reading)", red: 0.9, green: 0.9, blue: 1.0, alpha: 0.9, editable: false, check: false),
    Preset(name: "Neutral white", red: 0.9, green: 0.9, blue: 0.8, alpha: 0.9, editable: false, check: false),
    Preset(name: "Warm white (least blue, nightime reading)", red: 0.9, green: 0.9, blue: 0.6, alpha: 0.9, editable: false, check: false),
     ]

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fixedPresetArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        setLEDs(presetIndex: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell", for: indexPath)

        // Configure the cell...
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        let redBack = CGFloat(fixedPresetArray[indexPath.row].red)
        let greenBack = CGFloat(fixedPresetArray[indexPath.row].green)
        let blueBack = CGFloat(fixedPresetArray[indexPath.row].blue)
        let alphaBack = CGFloat(fixedPresetArray[indexPath.row].alpha)
        print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
        cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
        
        label.textColor = UIColor.black
        label.text = fixedPresetArray[indexPath.row].name
       /* if indexPath.row == 0 {
            label.text = fixedPresetArray[0].name
        } else if indexPath.row == 1 {
            label.text =  fixedPresetArray[1].name
        } else if indexPath.row == 2 {
            label.text = fixedPresetArray[2].name
        } else if indexPath.row == 3 {
            label.text =  fixedPresetArray[3].name
        } else if indexPath.row == 4 {
            label.text =  fixedPresetArray[4].name
        } else if indexPath.row == 5 {
            label.text =  fixedPresetArray[5].name
        } else if indexPath.row == 6 {
            label.text =  fixedPresetArray[6].name
        } */

        return cell
    }
    
    func setLEDs(presetIndex: Int) {
        
        let redColor = fixedPresetArray[presetIndex].red
        let greenColor = fixedPresetArray[presetIndex].green
        let blueColor = fixedPresetArray[presetIndex].blue
        let alpha = fixedPresetArray[presetIndex].alpha
        
        // normalize so output independent of mix of colors, only dependent on alpha
        /*let colorSum = redColor + greenColor + blueColor
        let newRed = redColor / colorSum
        let newGreen = greenColor / colorSum
        let newBlue = blueColor / colorSum */
        
        let newRed = redColor
        let newGreen = greenColor
        let newBlue = blueColor
        
        let redLED = Int(Double(ADCMaximumValue) * newRed * alpha)
        let greenLED = Int(Double(ADCMaximumValue) * newGreen * alpha)
        let blueLED = Int(Double(ADCMaximumValue) * newBlue * alpha)
        let whiteLED = Int(Double(ADCMaximumValue) * 0.0 * alpha)
        
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
