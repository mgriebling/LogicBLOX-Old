//
//  LBDesignTableViewController.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 6Sep2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBDesignTableViewController: UITableViewController {
  
    @IBOutlet var openBarButton: UIBarButtonItem!
    @IBOutlet var AddItemBarButton: UIBarButtonItem!
    
    struct consts {
        static let None = -1
    }

    var selectedItem : Int = 0
    var editingItem : Int = consts.None
    var callback : (_ selected: Int) -> () = { _ in }
    
    var editingText : String = ""   // design name being edited
    
    // MARK: - Table view life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.isEnabled = Designs.list.count > 1
        tableView.selectRow(at: IndexPath(row: selectedItem, section: 0), animated: false, scrollPosition: .middle)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callback(selectedItem)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Designs.list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var designID = "Design ID"
        if indexPath.row == editingItem {
            designID = "Edit " + designID
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: designID, for: indexPath)

        // Configure the cell...
        let design = Designs.list[indexPath.row]
        if indexPath.row == editingItem {
            let editCell = cell as! EditTableCell
            editCell.cellTextField.text = design.deletingPathExtension().lastPathComponent
            editCell.cellTextField.delegate = self
            editCell.cellTextField.becomeFirstResponder()
            editCell.cellPic.tintColor = UIColor.black
            editCell.backgroundColor = UIColor.init(white: 0.89, alpha: 1)
        } else {
            cell.textLabel?.text = design.deletingPathExtension().lastPathComponent
            cell.imageView?.tintColor = UIColor.black
            cell.backgroundColor = indexPath.row == selectedItem ? UIColor.init(white: 0.89, alpha: 1) : UIColor.white
        }
        return cell
    }
    
    // MARK: - Table editing actions
    
    @IBAction func addNewDesign(_ sender: UIBarButtonItem) {
        let selectedPath = IndexPath(row: selectedItem, section: 0)
        editingItem = consts.None
        selectedItem = consts.None
        tableView.reloadRows(at: [selectedPath], with: .automatic)
        
        _ = Designs.addNewDesign()
        selectedItem = 0
        let path = IndexPath(row: selectedItem, section: 0)
        editingItem = tableView.isEditing ? consts.None : selectedItem
        tableView.insertRows(at: [path], with: .automatic)
        editButtonItem.isEnabled = Designs.list.count > 1
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        openBarButton.isEnabled = !editing
        if editing && editingItem != consts.None {
            editingItem = consts.None
            tableView.reloadRows(at: [IndexPath(row: selectedItem, section: 0)], with: .automatic)
        }
        super.setEditing(editing, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prevPath = IndexPath(row: selectedItem, section: 0)
        editingItem = consts.None
        if selectedItem == indexPath.row { editingItem = indexPath.row } // 2nd click we edit text field
        selectedItem = indexPath.row
        tableView.reloadRows(at: [indexPath, prevPath], with: .automatic)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return Designs.list.count > 1  // don't delete the last design so we have something to view
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let url = Designs.list.remove(at: indexPath.row)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Couldn't delete \(url.lastPathComponent)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if indexPath.row == selectedItem {
                selectedItem = 0
                tableView.reloadRows(at: [IndexPath(row: selectedItem, section: 0)], with: .none)
            }
            editButtonItem.isEnabled = Designs.list.count > 1
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let design = Designs.list.remove(at: fromIndexPath.row)
        Designs.list.insert(design, at: to.row)
        tableView.moveRow(at: fromIndexPath, to: to)
        if selectedItem == fromIndexPath.row {
            // keep track of selected item when moved
            selectedItem = to.row
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return Designs.list.count > 1
    }

}

extension LBDesignTableViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingText = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        if newText == editingText { return true }       // allow the original name to be restored
        return !Designs.prefixExistsInObjects(newText)  // only allow unique design names
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingItem = consts.None
        let newText = textField.text!
        if newText != editingText {
            Designs.renameDesign(editingText, to: newText)   
        }
        let path = IndexPath(row: selectedItem, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
    
}
