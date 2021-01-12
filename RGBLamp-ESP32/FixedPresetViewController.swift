//
//  FixedPresetViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/29/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit

class FixedPresetViewController: UITableViewController {
    
    // Array of fixed presets with name and RGB vlaues. These are not user editable
    var fixedPresetArray = [Preset(name: "Cold white", red: 0.9, green: 0.9, blue: 1.0, alpha: 0.6, editable: false, check: false),
    Preset(name: "Neutral white", red: 0.9, green: 0.9, blue: 0.8, alpha: 0.6, editable: false, check: false),
    Preset(name: "Warm white", red: 0.9, green: 0.9, blue: 0.6, alpha: 0.6, editable: false, check: false),Preset(name: "Macular Degeneration", red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0, editable: false, check: false),
                            Preset(name: "Glaucoma", red: 0.1, green: 0.9, blue: 0.9, alpha: 0.5, editable: false, check: false),
    Preset(name: "Retinitis Pigmentosa", red: 0.9, green: 0.3, blue: 0.5, alpha: 0.9, editable: false, check: false),
    Preset(name: "Diabetic Retinopathy", red: 0.5, green: 0.9, blue: 0.4, alpha: 0.9, editable: false, check: false),
     ]
    
    var section0Array = [Preset(name: "Cold white", red: 0.9, green: 0.9, blue: 1.0, alpha: 0.6, editable: false, check: false),
                             Preset(name: "Neutral white", red: 0.9, green: 0.9, blue: 0.8, alpha: 0.6, editable: false, check: false),
                             Preset(name: "Warm white", red: 0.9, green: 0.9, blue: 0.6, alpha: 0.6, editable: false, check: false)
                              ]
    
    var section1Array = [Preset(name: "Macular Degeneration", red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0, editable: false, check: false),
                            Preset(name: "Glaucoma", red: 0.1, green: 0.9, blue: 0.9, alpha: 0.5, editable: false, check: false),
    Preset(name: "Retinitis Pigmentosa", red: 0.9, green: 0.3, blue: 0.5, alpha: 0.9, editable: false, check: false),
    Preset(name: "Diabetic Retinopathy", red: 0.5, green: 0.9, blue: 0.4, alpha: 0.9, editable: false, check: false)
     ]
    
    var titleString = [0 : "Stella IQ™ Presets", 1 : "Stella IQ™ Special Presets"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    // see reference: https://stackoverflow.com/questions/48658391/how-to-make-multiple-level-sections-in-uitableview-in-swift-4

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (section0Array.count)
        } else if section == 1 {
            return (section1Array.count)
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell", for: indexPath)

        // Configure the cell...
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        var redBack: CGFloat = 0.0
        var greenBack: CGFloat = 0.0
        var blueBack: CGFloat = 0.0
        var alphaBack: CGFloat = 0.0
        
        let defaultArray = section1Array
        
        switch (indexPath.section) {
            case 0:
                redBack = CGFloat(section0Array[indexPath.row].red)
                greenBack = CGFloat(section0Array[indexPath.row].green)
                blueBack = CGFloat(section0Array[indexPath.row].blue)
                alphaBack = CGFloat(section0Array[indexPath.row].alpha)
                label.text = section0Array[indexPath.row].name
            case 1:
                redBack = CGFloat(section1Array[indexPath.row].red)
                greenBack = CGFloat(section1Array[indexPath.row].green)
                blueBack = CGFloat(section1Array[indexPath.row].blue)
                alphaBack = CGFloat(section1Array[indexPath.row].alpha)
                label.text = section1Array[indexPath.row].name
            default:
                redBack = CGFloat(defaultArray[indexPath.row].red)
                greenBack = CGFloat(defaultArray[indexPath.row].green)
                blueBack = CGFloat(defaultArray[indexPath.row].blue)
                alphaBack = CGFloat(defaultArray[indexPath.row].alpha)
                label.text = defaultArray[indexPath.row].name
        }
        
        print("IndexPath \(indexPath.row), red \(redBack), green \(greenBack), blue \(blueBack)")
        cell.backgroundColor = UIColor(red: redBack, green: greenBack, blue: blueBack, alpha: alphaBack)
        cell.tintColor = UIColor.black
        label.textColor = UIColor.black

        return cell
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        sectionView.backgroundColor = UIColor.black

        let sectionName = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.size.width, height: 50))
        sectionName.text = titleString[section]
        sectionName.textColor = UIColor.white
        sectionName.font = UIFont.systemFont(ofSize: 18)
        sectionName.textAlignment = .left

        sectionView.addSubview(sectionName)
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        // place a check mark on the selected row
        if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        let section = indexPath.section
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        setLEDs(presetIndex: indexPath.row, section: Int64(section))
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setLEDs(presetIndex: Int, section: Int64) {
        var redColor: Float = 0.0
        var greenColor: Float = 0.0
        var blueColor: Float = 0.0
        var alpha: Float = 0.0
        if section == 0 {
            redColor = Float(section0Array[presetIndex].red)
            greenColor = Float(section0Array[presetIndex].green)
            blueColor = Float(section0Array[presetIndex].blue)
            alpha = Float(section0Array[presetIndex].alpha)
        }
        if section == 1 {
            redColor = Float(section1Array[presetIndex].red)
            greenColor = Float(section1Array[presetIndex].green)
            blueColor = Float(section1Array[presetIndex].blue)
            alpha = Float(section1Array[presetIndex].alpha)
        }
        
        // convert to LED values using routine in ADCMaxValue.swift
        let redLED = ledValue(color: "red", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let greenLED = ledValue(color: "green", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let blueLED = ledValue(color: "blue", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let whiteLED: Int = 0
        
        saveValues(for: redColor, for: greenColor, for: blueColor, for: alpha)
        
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    
    
   /* // Create a standard header that includes the returned text.
     
     /*override func numberOfSections(in tableView: UITableView) -> Int {
         // #warning Incomplete implementation, return the number of sections
         return 1
     } */
     
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       return "StellaIQ™ Presets"
    }
    
    // number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fixedPresetArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        // place a check mark on the selected row
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
        
        //Change text and checkmark color to black
        cell.tintColor = UIColor.black
        label.textColor = UIColor.black
        label.text = fixedPresetArray[indexPath.row].name

        return cell
    }
 
 */
   
    

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
