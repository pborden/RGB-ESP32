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
    var fixedPresetArray = [Preset(name: "Cold white", red: 0.9, green: 0.9, blue: 1.0, alpha: 0.9, editable: false, check: false),
    Preset(name: "Neutral white", red: 0.9, green: 0.9, blue: 0.8, alpha: 0.9, editable: false, check: false),
    Preset(name: "Warm white", red: 0.9, green: 0.9, blue: 0.6, alpha: 0.9, editable: false, check: false),Preset(name: "Macular Degeneration", red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0, editable: false, check: false),
                            Preset(name: "Glaucoma", red: 0.1, green: 0.9, blue: 0.9, alpha: 0.5, editable: false, check: false),
    Preset(name: "Retinitis Pigmentosa", red: 0.9, green: 0.3, blue: 0.5, alpha: 0.9, editable: false, check: false),
    Preset(name: "Diabetic Retinopathy", red: 0.5, green: 0.9, blue: 0.4, alpha: 0.9, editable: false, check: false),
     ]
    
    var section0Array = [
        Preset(name: "Cold white", red: 0.86, green: 0.90, blue: 0.97, alpha: 0.9, editable: false, check: false),
        Preset(name: "Neutral white", red: 0.91, green: 0.80, blue: 0.58, alpha: 0.9, editable: false, check: false),
        Preset(name: "Warm white", red: 0.96, green: 0.68, blue: 0.28, alpha: 0.9, editable: false, check: false),
        Preset(name: "Light green", red: 0.15, green: 0.92, blue: 0.7, alpha: 0.9, editable: false, check: false)
                              ]
    
    var section1Array = [
        Preset(name: "Macular Degeneration", red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0, editable: false, check: false),
        Preset(name: "Glaucoma", red: 0.1, green: 0.9, blue: 0.9, alpha: 0.5, editable: false, check: false),
        Preset(name: "Retinitis Pigmentosa", red: 0.9, green: 0.3, blue: 0.5, alpha: 0.9, editable: false, check: false),
        Preset(name: "Diabetic Retinopathy", red: 0.5, green: 0.9, blue: 0.4, alpha: 0.9, editable: false, check: false)
     ]
    
    var section2Array = [
        Preset(name: "Light yellow (NoIR 58 or similar)", red: 0.563, green: 0.691, blue: 0.27, alpha: 1.0, editable: false, check: false),
        Preset(name: "Med yellow (NoIR 50 or similar)", red: 0.574, green: 0.707, blue: 0.035, alpha: 1.0, editable: false, check: false),
        Preset(name: "Dark yellow (NoIR 59 or similar)", red: 0.676, green: 0.617, blue: 0.0, alpha: 1.0, editable: false, check: false),
        Preset(name: "Light amber (NoIR 48 or similar)", red: 0.637, green: 0.617, blue: 0.613, alpha: 1.0, editable: false, check: false),
        Preset(name: "Med amber (NoIR 40 or similar)", red: 0.707, green: 0.457, blue: 0.238, alpha: 1.0, editable: false, check: false),
        Preset(name: "Dark amber (NoIR 43 or similar)", red: 0.691, green: 0.492, blue: 0.289, alpha: 0.5, editable: false, check: false),
        Preset(name: "Blue blocker (NoIR 465 or similar)", red: 0.684, green: 0.703, blue: 0.086, alpha: 1.0, editable: false, check: false),
        Preset(name: "Light grey-green (NoIR 12 or similar)", red: 0.664, green: 0.741, blue: 0.621, alpha: 1.0, editable: false, check: false),
        Preset(name: "Med grey-green (NoIR 02 or similar)", red: 0.660, green: 0.821, blue: 0.574, alpha: 0.7, editable: false, check: false),
        Preset(name: "Dark grey-green (NoIR 08 or similar)", red: 0.0, green: 0.648, blue: 0.258, alpha: 1.0, editable: false, check: false),
        Preset(name: "Green (NoIR 35 or similar)", red: 0.0, green: 0.719, blue: 0.246, alpha: 1.0, editable: false, check: false),
        Preset(name: "Blue (NoIR 26 or similar)", red: 0.0, green: 0.32, blue: 0.918, alpha: 1.0, editable: false, check: false),
        Preset(name: "Topaz (NoIR 47 or similar)", red: 0.820, green: 0.355, blue: 0.539, alpha: 1.0, editable: false, check: false),
        Preset(name: "Light Plum (NoIR 88 or similar)", red: 0.652, green: 0.609, blue: 0.621, alpha: 1.0, editable: false, check: false),
        Preset(name: "Plum (NoIR 81 or similar)", red: 0.777, green: 0.453, blue: 0.770, alpha: 1.0, editable: false, check: false),
        Preset(name: "Med Red (NoIR 90 or similar)", red: 0.996, green: 0.0, blue: 0.219, alpha: 1.0, editable: false, check: false),
        Preset(name: "Dark Red (NoIR 99 or similar)", red: 0.996, green: 0.0, blue: 0.277, alpha: 0.5, editable: false, check: false),
        Preset(name: "FL-41 (migraine)", red: 0.895, green: 0.59, blue: 0.57, alpha: 1.0, editable: false, check: false)]
    
    var titleString = [0 : "Stella IQ™ Presets", 1 : "Special Presets", 2: "Filters"]
    var selectedElement: IndexPath = [4, 0] // set to non-existent section so no check appears at start

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footerView:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width:320 , height: 50))
            footerView.text = "©2021 Jasper Ridge Inc. Patents pending"
            footerView.font = UIFont(name: "Helvetica", size: 12)
            footerView.numberOfLines = 0;
            footerView.sizeToFit()
            tableView.tableFooterView = footerView
        tableView.contentInset = (UIEdgeInsets(top: 0, left: 0, bottom: -footerView.frame.size.height, right: 8))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    // see reference: https://stackoverflow.com/questions/48658391/how-to-make-multiple-level-sections-in-uitableview-in-swift-4

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (section0Array.count)
        } else if section == 1 {
            return (section1Array.count)
        } else if section == 2 {
            return (section2Array.count)
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell", for: indexPath)
        
        // place a check mark on the selected row
        
        /*if cell.isSelected {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        } */
        
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
                //if section0Array[indexPath.row].check == true
                
                if ((selectedElement.section == 0) && (selectedElement.row == indexPath.row)){
                    cell.accessoryType = .checkmark
                    print("section 0 row \(indexPath.row) has check")
                } else {
                    cell.accessoryType = .none
                }
            case 1:
                redBack = CGFloat(section1Array[indexPath.row].red)
                greenBack = CGFloat(section1Array[indexPath.row].green)
                blueBack = CGFloat(section1Array[indexPath.row].blue)
                alphaBack = CGFloat(section1Array[indexPath.row].alpha)
                label.text = section1Array[indexPath.row].name
                if ((selectedElement.section == 1) && (selectedElement.row == indexPath.row)) {
                    cell.accessoryType = .checkmark
                    print("section 1 row \(indexPath.row) has check")
                } else {
                    cell.accessoryType = .none
                }
            case 2:
                redBack = CGFloat(section2Array[indexPath.row].red)
                greenBack = CGFloat(section2Array[indexPath.row].green)
                blueBack = CGFloat(section2Array[indexPath.row].blue)
                alphaBack = CGFloat(section2Array[indexPath.row].alpha)
                label.text = section2Array[indexPath.row].name
                if ((selectedElement.section == 2) && (selectedElement.row == indexPath.row)) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            default:
                redBack = CGFloat(defaultArray[indexPath.row].red)
                greenBack = CGFloat(defaultArray[indexPath.row].green)
                blueBack = CGFloat(defaultArray[indexPath.row].blue)
                alphaBack = CGFloat(defaultArray[indexPath.row].alpha)
                label.text = defaultArray[indexPath.row].name
                cell.accessoryType = .none
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
        
        selectedElement = indexPath
        print("Selected element: \(selectedElement)")
        // checksFalse() // set all check marks to false
        
        // set check mark in selected row to true
        
        let selectedRow = indexPath.row
        if indexPath.section == 0 {
            section0Array[selectedRow].check = true
        } else if indexPath.section == 1 {
            section1Array[selectedRow].check = true
        } else {
            section2Array[selectedRow].check = true
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
        if section == 2 {
            redColor = Float(section2Array[presetIndex].red)
            greenColor = Float(section2Array[presetIndex].green)
            blueColor = Float(section2Array[presetIndex].blue)
            alpha = Float(section2Array[presetIndex].alpha)
        }
        
        // convert to LED values using routine in ADCMaxValue.swift
        let redLED = ledValue(color: "red", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let greenLED = ledValue(color: "green", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let blueLED = ledValue(color: "blue", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let whiteLED: Int = 0
        
        saveValues(for: redColor, for: greenColor, for: blueColor, for: alpha)
        
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    func checksFalse() {

        for var element0 in section0Array {
            element0.check = false
        }
        for var element1 in section1Array {
            element1.check = false
        }
        for var element2 in section2Array {
            element2.check = false
        }
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
