//
//  EditViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/26/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit

class EditViewController: UITableViewController, UITextFieldDelegate {
    
    //Mark:-Presets.
       
       var userName: [String] = []
       var userGreen: [Float] = []
       var userRed: [Float] = []
       var userBlue: [Float] = []
       var userAlpha: [Float] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userName.count
    }
    
    //MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           print("cell thinks data is \(userName)")
           let cell = tableView.dequeueReusableCell(withIdentifier: "Edit", for: indexPath)
           
           let label = cell.viewWithTag(2000) as! UITextField
           
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //textField.becomeFirstResponder()
        loadUserDefaults()
        self.tableView.reloadData()
        print("View appearing")
        print("Preset names from user defaults: \(userName)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("View disappearing")
        
        for row in 0 ... userName.count - 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            let label = cell?.viewWithTag(2000) as! UITextField
            userName[row] = label.text ?? ""
        }
        
        UserDefaults.standard.set(userName, forKey: "userName")
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
//MARK:- TextField Delegates

}
