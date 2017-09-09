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

    var selectedItem : Int = 0
    var editingItem : Int = -1
    var callback : (_ selected: Int) -> () = { _ in }
    
    // MARK: - Table view life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem
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
            editCell.backgroundColor = UIColor.lightGray
        } else {
            cell.textLabel?.text = design.deletingPathExtension().lastPathComponent
            cell.imageView?.tintColor = UIColor.black
            cell.backgroundColor = indexPath.row == selectedItem ? UIColor.lightGray : UIColor.white
        }
        return cell
    }
    
    // MARK: - Table editing actions
    
    @IBAction func addNewDesign(_ sender: UIBarButtonItem) {
        _ = Designs.addNewDesign()
        let path = IndexPath(row: 0, section: 0)
        selectedItem = 0
        tableView.insertRows(at: [path], with: .automatic)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("Edit mode changed to \(editing)")
        openBarButton.isEnabled = !editing
        super.setEditing(editing, animated: animated)
//        if !editing {
//            // restore selected item
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//                self.tableView.selectRow(at: IndexPath(row: self.selectedItem, section: 0), animated: true, scrollPosition: .middle)
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prevPath = IndexPath(row: selectedItem, section: 0)
        selectedItem = indexPath.row
        editingItem = selectedItem
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
            try? FileManager.default.removeItem(at: url)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if indexPath.row == selectedItem {
                selectedItem = 0
            }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingItem = -1
        let path = IndexPath(row: selectedItem, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
        let original = Designs.list[selectedItem].deletingPathExtension().lastPathComponent
        if textField.text != original {
            print("Text changed from \"\(original)\" to \"\(textField.text!)\"")
        }
    }
    
}
