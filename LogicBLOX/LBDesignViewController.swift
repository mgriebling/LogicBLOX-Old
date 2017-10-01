//
//  LBDesignViewController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 1 Oct 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBDesignViewController: UICollectionViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    struct consts {
        static let None = -1
        static let reuseIdentifier1 = "EditCell"
        static let reuseIdentifier2 = "Cell"
    }

    var selectedItem : Int = 0
    var editingItem : Int = consts.None
    var editingText : String = ""   // design name being edited
    var callback : (_ selected: Int) -> () = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        navigationItem.rightBarButtonItems = [editButtonItem, shareButton]
//        editButtonItem.isEnabled = Designs.list.count > 1
        collectionView?.selectItem(at: IndexPath(item: selectedItem, section: 0), animated: false, scrollPosition: .centeredVertically)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callback(selectedItem)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Designs.list.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = indexPath.item == editingItem ? consts.reuseIdentifier1 : consts.reuseIdentifier2
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell...
        let design = Designs.list[indexPath.item]
        let editCell = cell as! EditDesignCell
        if indexPath.item == editingItem {
            editCell.cellTextField.text = design.deletingPathExtension().lastPathComponent
            editCell.cellTextField.delegate = self
            editCell.backgroundColor = UIColor.init(white: 0.89, alpha: 1)
        } else {
            editCell.cellText.text = design.deletingPathExtension().lastPathComponent
            editCell.backgroundColor = indexPath.item == selectedItem ? UIColor.init(white: 0.89, alpha: 1) : UIColor.white
        }
        return cell
    }
    
    // MARK: - Table editing actions
    @IBAction func shareDesigns(_ sender: Any) {
        var imageArray = [UIImage]()
        if selectedItem != consts.None {
            imageArray.append(UIImage(named: "Nand Gate")!)
            
            let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
            //shareScreen.completionWithItemsHandler = { _ in /* self.sharing = false */ }
            let popoverPresentationController = shareScreen.popoverPresentationController
            popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            popoverPresentationController?.permittedArrowDirections = .any
            present(shareScreen, animated: true, completion: nil)
        }
    }
    
    func deleteDesign(at index: Int) {
        // Delete the row from the data source
        let url = Designs.list.remove(at: index)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Couldn't delete \(url.lastPathComponent)")
        }
        collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { (done) in
            if index == self.selectedItem {
                self.selectedItem = 0
                self.collectionView?.reloadItems(at: [IndexPath(row: 0, section: 0)])
            }
            self.selectedItem = min(self.selectedItem, max(Designs.list.count-1, 0))
        })
    }
    
    @IBAction func deleteDesign(_ sender: UIBarButtonItem) {
        if selectedItem != consts.None {
            let design = Designs.list[selectedItem].deletingPathExtension().lastPathComponent
            let prompt = UIAlertController(title: "Confirm Deletion", message: "Delete \(design)?", preferredStyle: .alert)
            prompt.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                // Delete the row from the data source
                self.deleteDesign(at: self.selectedItem)
            }))
            prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(prompt, animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewDesign(_ sender: UIBarButtonItem) {
        let selectedPath = IndexPath(item: selectedItem, section: 0)
        editingItem = consts.None
        selectedItem = consts.None
        collectionView?.performBatchUpdates({
            self.collectionView?.reloadItems(at: [selectedPath])
        }, completion: { (finish) in
            _ = Designs.addNewDesign()
            self.selectedItem = 0
            let path = IndexPath(item: self.selectedItem, section: 0)
            self.editingItem = self.isEditing ? consts.None : self.selectedItem
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: [path])
            }, completion: { (finish) in
                // enable cell for editing
                let cell = self.collectionView?.cellForItem(at: IndexPath(item: self.editingItem, section: 0))
                if let cell = cell as? EditDesignCell {
                    cell.cellTextField.delegate = self
                    cell.cellTextField.becomeFirstResponder()
                }
            })
            self.editButtonItem.isEnabled = Designs.list.count > 1
        })
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing && editingItem != consts.None {
            editingItem = consts.None
            collectionView?.reloadItems(at: [IndexPath(item: selectedItem, section: 0)])
        }
        super.setEditing(editing, animated: animated)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let prevPath = IndexPath(item: selectedItem, section: 0)
        editingItem = consts.None
        if selectedItem == indexPath.item { editingItem = indexPath.item } // 2nd click we edit text field
        selectedItem = indexPath.item
        print("Reloading \(indexPath) & \(prevPath)")
        self.collectionView?.performBatchUpdates({
            if prevPath == indexPath {
                // crashes with two identical index paths
                self.collectionView?.reloadItems(at: [indexPath])
            } else {
                self.collectionView?.reloadItems(at: [indexPath, prevPath])
            }
        }, completion: { (completed) in
            if self.editingItem != consts.None {
                // Set first responder to edited text field once the table update is complete
                let cell = self.collectionView?.cellForItem(at: IndexPath(item: self.editingItem, section: 0))
                if let cell = cell as? EditDesignCell {
                    cell.cellTextField.delegate = self
                    cell.cellTextField.becomeFirstResponder()
                }
            }
        })
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let design = Designs.list.remove(at: sourceIndexPath.item)
        Designs.list.insert(design, at: destinationIndexPath.item)
        if selectedItem == sourceIndexPath.row {
            // keep track of selected item when moved
            selectedItem = destinationIndexPath.item
        }
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension LBDesignViewController : UITextFieldDelegate {
    
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
        let path = IndexPath(item: selectedItem, section: 0)
        collectionView?.reloadItems(at: [path])
    }
    
}
