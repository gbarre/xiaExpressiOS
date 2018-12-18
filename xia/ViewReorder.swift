//
//  ViewReorder.swift
//  xia
//
//  Created by Guillaume on 17/01/2018.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit

class ViewReorder: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var ViewCollection: ViewCollectionController?
    var currentDirs = rootDirs
    var childDirs = [String]()
    var toMove = [String]()
    var selectedDir = emptyString
    var originalDir = documentsDirectory
    var salt = defaultSalt
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var currentDirectory: UINavigationItem!
    
    @IBOutlet weak var btnOpen: UIBarButtonItem!
    @IBAction func btnOpenAction(_ sender: Any) {
        if selectedDir == String(repeating: dotString, count: 2) {
            let parentDir = getParentDir(currentDir: currentDirs[rootString]!)
            currentDirs = getDirs(root: parentDir)
        }
        else if selectedDir != emptyString {
            currentDirs = getDirs(root: currentDirs[rootString]! + separatorString + selectedDir)
        }
        childDirs = getchildsDirs(root: currentDirs[rootString]!)
        selectedDir = emptyString
        currentDirectory.title = getDirName(path: currentDirs[rootString]!)
        tableView.reloadData()
    }
    
    @IBOutlet weak var btnSelect: UIBarButtonItem!
    @IBAction func btnSelectAction(_ sender: Any) {
        do {
            let fileManager = FileManager.default
            for file in toMove {
                var fileName = file
                if fileName.prefix(salt.count) == salt { // moving a directory
                    fileName = String(fileName.suffix(fileName.count - salt.count))
                    try fileManager.moveItem(atPath: originalDir + separatorString + fileName,
                                             toPath: currentDirs[rootString]! + separatorString + selectedDir + separatorString + fileName
                    )
                }
                else { // moving resource
                    try fileManager.moveItem(atPath: originalDir + separatorString
                                                    + imagesString + separatorString
                                                    + fileName + jpgExtension,
                                             toPath: currentDirs[rootString]! + separatorString
                                                    + selectedDir + separatorString
                                                    + imagesString + separatorString
                                                    + fileName + jpgExtension
                    )
                    try fileManager.moveItem(atPath: originalDir + separatorString
                                                    + xmlString + separatorString
                                                    + fileName + xmlExtension,
                                             toPath: currentDirs[rootString]! + separatorString
                                                    + selectedDir + separatorString
                                                    + xmlString + separatorString
                                                    + fileName + xmlExtension
                    )
                }
            }
        } catch let error as NSError {
                debugPrint(error.localizedDescription)
        }
        ViewCollection?.buildLeftNavbarItems()
        ViewCollection?.endEdit()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        originalDir = currentDirs[rootString]!
        childDirs = getchildsDirs(root: currentDirs[rootString]!)
        currentDirectory.title = getDirName(path: currentDirs[rootString]!)
        btnOpen.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        btnSelect.isEnabled = (currentDirs[rootString]! != originalDir)
        let height = (childDirs.count + 1) * 45
        self.preferredContentSize = CGSize(width: 300, height: height)
        return childDirs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!

        cell.textLabel?.text = childDirs[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = self.tableView.cellForRow(at: indexPath)
        if selectedDir == emptyString { // nothing selected, highlight this one
            selectedDir = childDirs[indexPath.row]
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            btnOpen.isEnabled = true
            btnSelect.isEnabled = (selectedDir == String(repeating: dotString, count: 2)) ? false : true
        }
        else if selectedDir == childDirs[indexPath.row] { // unhighlight this one
            selectedDir = emptyString
            cell?.accessoryType = UITableViewCellAccessoryType.none
            btnOpen.isEnabled = false
            btnSelect.isEnabled = false
        }
        else { // another cell is highlighted, let's switch !
            for i in 0...childDirs.count {
                if i == indexPath.row {
                    cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                    selectedDir = childDirs[indexPath.row]
                }
                else {
                    self.tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = UITableViewCellAccessoryType.none
                }
                btnOpen.isEnabled = true
                btnSelect.isEnabled = (selectedDir == String(repeating: dotString, count: 2)) ? false : true
            }
        }
        return false
    }
    
    func getchildsDirs(root: String) -> [String] {
        var returnDirs = (root == documentsDirectory) ? [String]() : [String(repeating: dotString, count: 2)]
        let fileManager = FileManager.default
        do {
            let dirs = try fileManager.contentsOfDirectory(atPath: root)
            for dir in dirs {
                if reservedDirs.contains(dir) || dir == oembedKey + dotString + plistKey {
                    continue
                }
                else {
                    if !toMove.contains(salt+dir) {
                        returnDirs.append(dir)
                    }
                }
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return returnDirs
    }
}
