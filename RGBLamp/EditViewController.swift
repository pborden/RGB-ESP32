//
//  EditViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 1/26/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit

protocol EditViewControllerDelegate: class {
    func EditViewControllerDidCancel(
        _ controller: EditViewController)
    func EditViewController(_ controller: EditViewController, didFinishEditing item: Preset)
}

class EditViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: EditViewControllerDelegate?
    var itemToEdit: Preset?
    
    //MARK:-Actions
    @IBAction func cancel() {
        delegate?.EditViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        print("Contents of the text field: \(textField.text!)")
        if var item = itemToEdit {
            item.name = textField.text!
            delegate?.EditViewController(self, didFinishEditing: item)
        }
    }

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
        return 0
    }
    
    //MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    //MARK:- TextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }

}
