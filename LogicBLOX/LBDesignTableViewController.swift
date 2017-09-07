//
//  LBDesignTableViewController.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 6Sep2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBDesignTableViewController: UITableViewController {
  
    var selectedItem : Int = 0
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
    
    // MARK: - Table editing actions
    
    @IBAction func addNewDesign(_ sender: UIBarButtonItem) {
        _ = Designs.addNewDesign()
        let path = IndexPath(row: Designs.list.count-1, section: 0)
        tableView.insertRows(at: [path], with: .automatic)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Designs.list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Design ID", for: indexPath)

        // Configure the cell...
        let design = Designs.list[indexPath.row]
        cell.textLabel?.text = design.deletingPathExtension().lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = indexPath.row
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
        }    
    }

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
