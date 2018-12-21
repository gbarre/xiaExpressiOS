//
//  ViewCollectionController.swift
//  xia
//
//  Created by Guillaume on 26/09/2015.
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
import Foundation

class ViewCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var arrayNames = [String]()
    var arraySortedNames = [String: String]() // Label : FileName
    var segueIndex: Int = -1
    var editingMode: Bool = false
    var showHelp = false
    
    var b64IMG:String = emptyString
    var currentElement:String = emptyString
    var passData:Bool=false
    var passName:Bool=false
    var newMedia: Bool?
    var landscape: Bool = false
    var salt = defaultSalt
    var currentDirs = rootDirs
    var toMove = [String]()
    var dirsInSelection = 0
    
    var selectedPhotos = [IndexPath]()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBAction func btnBackAction(_ sender: Any) {
        let dir = getParentDir(currentDir: currentDirs[rootString]!)
        currentDirs = getDirs(root: dir)
        CollectionView.reloadData()
        buildLeftNavbarItems(0)
        navBarTitle.title = (currentDirs[rootString]! == documentsDirectory) ?
            XiaTitleString : String(format: XiaTitleSubDirString, getDirName(path: currentDirs[rootString]!))
    }
    
    @IBOutlet weak var btnTrash: UIBarButtonItem!
    @IBAction func btnTrashAction(_ sender: AnyObject) {
        // Show confirm alert
        let controller = UIAlertController()
        let title = (selectedPhotos.count == 1) ? NSLocalizedString(deleteFileKey, comment: emptyString) : String(format: NSLocalizedString(deleteNFilesKey, comment: emptyString), selectedPhotos.count)
        let confirmDelete = UIAlertAction(title: title, style: .destructive) { action in
            // Reorder paths to delete from the end
           
            var indexes = [IndexPath:Int]()
            for path in self.selectedPhotos {
                indexes[path] = (path as NSIndexPath).row
            }
            let sortedPath = (indexes as NSDictionary).keysSortedByValue(comparator: {
                ($1 as! NSNumber).compare($0 as! NSNumber)
            })
            
            // Delete files
            for path in sortedPath {
                self.deleteFiles(path as! IndexPath)
            }
            
            // Exit editing mode
            self.endEdit()
            // Rebuild the navbar
            self.buildLeftNavbarItems()
        }
        controller.addAction(confirmDelete)
        if let ppc = controller.popoverPresentationController {
            ppc.barButtonItem = btnTrash
            ppc.permittedArrowDirections = .up
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnExport: UIBarButtonItem!
    @IBAction func btnExportAction(_ sender: AnyObject) {
        segueIndex = (selectedPhotos[0] as NSIndexPath).row
        performSegue(withIdentifier: exportSegueKey, sender: self)
    }
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBAction func btnEditAction(_ sender: AnyObject) {
        segueIndex = (selectedPhotos[0] as NSIndexPath).row
        if arrayNames[segueIndex].prefix(salt.count) != salt {
            performSegue(withIdentifier: viewMetasSegueKey, sender: self)
        }
        else {
            let oldDirName = arrayNames[segueIndex].suffix(arrayNames[segueIndex].count - salt.count)
            // Ask for folder name in popup
            let controller = UIAlertController(title: NSLocalizedString(folderNameKey, comment: emptyString), message: NSLocalizedString(alphaNumKey, comment: emptyString), preferredStyle: UIAlertControllerStyle.alert)
            
            controller.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.alphabet
                textField.text = String(oldDirName)
            })
            controller.addAction(UIAlertAction(title: NSLocalizedString(cancelKey, comment: emptyString), style: UIAlertActionStyle.cancel, handler: { action in
                // do nothing
            }))
            controller.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: { action in
                let folder = controller.textFields!.first!.text
                if self.checkDirName(dirName: folder!) {
                    // Move folder
                    do {
                        try FileManager.default.moveItem(atPath: self.currentDirs[rootString]! + separatorString + oldDirName,
                                                         toPath: self.currentDirs[rootString]! + separatorString + folder!)
                        // Exit editing mode
                        self.endEdit()
                        // Rebuild the navbar
                        self.buildLeftNavbarItems()
                        self.CollectionView.reloadData()
                    } catch let error as NSError {
                        debugPrint(error.localizedDescription)
                    }
                }
            }))
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var btnCopy: UIBarButtonItem!
    @IBAction func btnCopyAction(_ sender: AnyObject) {
        if arrayNames[segueIndex].prefix(salt.count) != salt {
            // Show confirm alert
            let controller = UIAlertController()
            let confirmDuplicate = UIAlertAction(title: NSLocalizedString(duplicateKey, comment: emptyString), style: .default) { action in
                // copy file
                let now:Int = Int(Date().timeIntervalSince1970)
                let selectedPhoto = self.arrayNames[(self.selectedPhotos[0] as NSIndexPath).row]
                
                let fileManager = FileManager.default
                do {
                    try fileManager.copyItem(atPath: self.currentDirs[imagesString]! + separatorString + selectedPhoto + jpgExtension,
                        toPath: self.currentDirs[imagesString]! + separatorString + String(now) + jpgExtension)
                    try fileManager.copyItem(atPath: self.currentDirs[xmlString]! + separatorString + selectedPhoto + xmlExtension,
                        toPath: self.currentDirs[xmlString]! + separatorString + String(now) + xmlExtension)
                }
                catch let error as NSError {
                    debugPrint(error.localizedDescription)
                }
                
                // Exit editing mode
                self.endEdit()
                // Rebuild the navbar
                self.buildLeftNavbarItems()
                self.arrayNames.append(String(now))
                self.CollectionView.reloadData()
                
            }
            controller.addAction(confirmDuplicate)
            if let ppc = controller.popoverPresentationController {
                ppc.barButtonItem = btnCopy
                ppc.permittedArrowDirections = .up
            }
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var btnReorder: UIBarButtonItem!
    @IBAction func btnReorderAction(_ sender: Any) {
        toMove.removeAll()
        // Get indexes
        var indexes = [IndexPath:Int]()
        for path in self.selectedPhotos {
            indexes[path] = (path as NSIndexPath).row
        }
        let sortedPath = (indexes as NSDictionary).keysSortedByValue(comparator: {
            ($1 as! NSNumber).compare($0 as! NSNumber)
        })
        // Get filesName to move
        for path in sortedPath {
            let index = (path as! NSIndexPath).row
            toMove.append(arrayNames[index])
        }
        performSegue(withIdentifier: reorderSegueKey, sender: self)
        
    }
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    @IBOutlet weak var btnDirs: UIBarButtonItem!
    @IBAction func btnDirsAction(_ sender: Any) {
        let fileManager = FileManager.default
        
        // Ask for folder name in popup
        let controller = UIAlertController(title: NSLocalizedString(folderNameKey, comment: emptyString), message: NSLocalizedString(alphaNumKey, comment: emptyString), preferredStyle: UIAlertControllerStyle.alert)
        
        controller.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.alphabet
        })
        controller.addAction(UIAlertAction(title: NSLocalizedString(cancelKey, comment: emptyString), style: UIAlertActionStyle.cancel, handler: { action in
            // do nothing
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: { action in
            let folder = controller.textFields!.first!.text
            if self.checkDirName(dirName: folder!) {
                // Create folder + images & xml subfolders
                do {
                    try fileManager.createDirectory(atPath: self.currentDirs[rootString]! + separatorString + folder! + separatorString + imagesString,
                        withIntermediateDirectories: true, attributes: nil)
                    try fileManager.createDirectory(atPath: self.currentDirs[rootString]! + separatorString + folder! + xmlString,
                        withIntermediateDirectories: true, attributes: nil)
                    self.CollectionView.reloadData()
                } catch let error as NSError {
                    debugPrint(error.localizedDescription)
                }
            }
        }))
        present(controller, animated: true, completion: nil)
        
    }
    
    @objc weak var btnCreateState: UIBarButtonItem!
    
    @objc weak var editMode: UIBarButtonItem!
    @objc func btnEdit(_ sender: AnyObject) {
        selectedPhotos = []
        if editingMode {
            endEdit()
        }
        else {
            editingMode = true
            // Change button title
            self.editMode.title = NSLocalizedString(doneKey, comment: emptyString)
            // Start cell wobbling
            for cell in CollectionView.visibleCells {
                let customCell: PhotoThumbnail = cell as! PhotoThumbnail
                customCell.wobble(true)
            }
            CollectionView.allowsMultipleSelection = true
            CollectionView.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
            // Cosmetic...
            btnCreateState.isEnabled = false
            btnCreateState.tintColor = selectingColor.withAlphaComponent(0)
            btnDirs.isEnabled = false
            btnDirs.tintColor = selectingColor.withAlphaComponent(0)
            navBar.barTintColor = selectingColor
            self.view.backgroundColor = selectingColor
            navBar.tintColor = UIColor.white
            navBarTitle.title = String(selectedPhotos.count) + spaceString + ((selectedPhotos.count > 1) ? NSLocalizedString(filesSelectedKey, comment: emptyString) : NSLocalizedString(fileSelectedKey, comment: emptyString))
            navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        buildLeftNavbarItems(selectedPhotos.count)
    }
    
    @objc weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        migrateDatas()
        // Hide left navbar buttons
        buildLeftNavbarItems()
        
        // add observer to detect enter foreground and rebuild collection
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // purge tmp
        let fileManager = FileManager.default
        let files = fileManager.enumerator(atPath: NSHomeDirectory() + separatorString + tmpString)
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = NSHomeDirectory() + separatorString + tmpString + separatorString + file
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // Put the StatusBar in white
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationWillEnterForeground(_ notification: Notification) {
        startImport()
        self.CollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.hidesBarsOnTap = false
        salt = String(arc4random_uniform(100000)) + underscoreString
        startImport()
        editingMode = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.CollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIndex == -1 {
            segueIndex = 0
        }
        if (segue.identifier == addSegueKey) {
            if let controller:ViewMenuAddResource = segue.destination as? ViewMenuAddResource {
                controller.ViewCollection = self
                controller.currentDirs = currentDirs
            }
        }
        else if (segue.identifier == reorderSegueKey) {
            if let controller:ViewReorder = segue.destination as? ViewReorder {
                controller.toMove = toMove
                controller.ViewCollection = self
                controller.currentDirs = currentDirs
                controller.salt = salt
            }
        }
        else if arrayNames.count > 0 {
            let xmlToSegue = ( arrayNames[segueIndex].prefix(salt.count) != salt ) ?
                getXML(currentDirs[xmlString]! + separatorString + arrayNames[segueIndex] + xmlExtension) : AEXMLDocument()
            let nameToSegue = String(arrayNames[segueIndex])
            if (segue.identifier == viewLargePhotoSegueKey) {
                endEdit()
                if let controller:ViewCreateDetails = segue.destination as? ViewCreateDetails {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                    controller.currentDirs = currentDirs
                }
            }
            if (segue.identifier == viewMetasSegueKey) {
                if let controller:ViewMetas = segue.destination as? ViewMetas {
                    controller.xml = xmlToSegue
                    controller.fileName = nameToSegue
                    controller.ViewCollection = self
                    controller.currentDirs = currentDirs
                }
            }
            if (segue.identifier == playXiaSegueKey) {
                endEdit()
                if let controller:PlayXia = segue.destination as? PlayXia {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                    controller.landscape = landscape
                    controller.currentDirs = currentDirs
                }
            }
            if (segue.identifier == exportSegueKey) {
                if let controller:ViewExport = segue.destination as? ViewExport {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                    controller.ViewCollection = self
                    controller.currentDirs = currentDirs
                    controller.salt = salt
                }
            }
        }
    }
    
    func buildLeftNavbarItems(_ selectedItems: Int = 0) {
        let buttonColor = (isEditing) ? selectingColor : blueColor
        switch selectedItems {
        case 1:
            btnBack.isEnabled = false
            btnBack.tintColor = buttonColor.withAlphaComponent(0)
            btnBack.title = emptyString
            btnTrash.isEnabled = true
            btnTrash.tintColor = UIColor.white
            btnReorder.isEnabled = true
            btnReorder.tintColor = UIColor.white
            btnEdit.isEnabled = true
            btnEdit.tintColor = UIColor.white
            btnExport.isEnabled = true
            btnExport.tintColor = UIColor.white
            btnCopy.isEnabled = (dirsInSelection == 0) ? true : false
            btnCopy.tintColor = (dirsInSelection == 0) ? UIColor.white : buttonColor.withAlphaComponent(0)
            break
        case 2...9999:
            btnBack.isEnabled = false
            btnBack.tintColor = buttonColor.withAlphaComponent(0)
            btnBack.title = emptyString
            btnTrash.isEnabled = true
            btnTrash.tintColor = UIColor.white
            btnReorder.isEnabled = true
            btnReorder.tintColor = UIColor.white
            btnEdit.isEnabled = false
            btnEdit.tintColor = buttonColor.withAlphaComponent(0)
            btnExport.isEnabled = false
            btnExport.tintColor = buttonColor.withAlphaComponent(0)
            btnCopy.isEnabled = false
            btnCopy.tintColor = buttonColor.withAlphaComponent(0)
            break
        default:
            btnBack.isEnabled = (currentDirs[rootString] == documentsDirectory) ? false : true
            btnBack.tintColor = (currentDirs[rootString] == documentsDirectory) ? buttonColor.withAlphaComponent(0) : UIColor.white
            btnBack.title = backString
            btnTrash.isEnabled = false
            btnTrash.tintColor = buttonColor.withAlphaComponent(0)
            btnReorder.isEnabled = false
            btnReorder.tintColor = buttonColor.withAlphaComponent(0)
            btnEdit.isEnabled = false
            btnEdit.tintColor = buttonColor.withAlphaComponent(0)
            btnExport.isEnabled = false
            btnExport.tintColor = buttonColor.withAlphaComponent(0)
            btnCopy.isEnabled = false
            btnCopy.tintColor = buttonColor.withAlphaComponent(0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        self.arrayNames = []
        // Load all images / directories names
        let fileManager = FileManager.default
        do {
            let dirs = try fileManager.contentsOfDirectory(atPath: currentDirs[rootString]!)
            for dir in dirs {
                switch dir {
                case inboxKey, oembedKey + dotString + plistKey, xmlString, localDatasKey:
                    break
                case imagesString:
                    let files = fileManager.enumerator(atPath: currentDirs[imagesString]!)
                    while let fileObject = files?.nextObject() {
                        var file = fileObject as! String
                        file = String(file.prefix(file.count - 4)) // remove .xyz
                        if fileManager.fileExists(atPath: currentDirs[xmlString]! + separatorString + file + xmlExtension) {
                            self.arrayNames.append(file)
                        }
                        else {
                            do {
                                try fileManager.removeItem(atPath: currentDirs[imagesString]! + separatorString + file + jpgExtension)
                            }
                            catch let error as NSError {
                                debugPrint(error.localizedDescription)
                            }
                        }
                    }
                    break
                default:
                    if dir.contains(importingString) || dir.contains(importFileString) {
                        break
                    } else {
                        self.arrayNames.append(salt+dir)
                        break
                    }
                }
            }
            
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        // Add a 'create image' if the is no image in Documents directory
        if ( self.arrayNames.count == 0 ) {
            editMode.isEnabled = false
            return 1
        }
        else {
            editMode.isEnabled = true
        }
        
        // order thumb by title
        self.arraySortedNames = [:]
        for name in self.arrayNames {
            var title: String!
            if name.prefix(salt.count) == salt {
                let clean_name = String(name.suffix(name.count - salt.count))
                title = clean_name + dashString + name
            }
            else {
                let xml = getXML(currentDirs[xmlString]! + separatorString + name + xmlExtension)
                title = (xml[xmlXiaKey][xmlTitleKey].value == nil) ? name : xml[xmlXiaKey][xmlTitleKey].value
                title = title! + dashString + name
            }
            self.arraySortedNames[title!] = name
        }
        let orderedTitles = self.arraySortedNames.keys.sorted()
        self.arrayNames = []
        for title in orderedTitles {
            self.arrayNames.append(self.arraySortedNames[title]!)
        }
        self.CollectionView.reloadData()
        
        return arrayNames.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoThumbnail
        
        if arrayNames.count == 0 {
            cell.setLabel(NSLocalizedString(createDocumentKey, comment: emptyString))
            cell.setThumbnail(UIImage(named: plusImgKey)!)
            cell.showRoIcon(false)
        }
        else {
            let index = (indexPath as NSIndexPath).item
            
            // check for dir
            if String(arrayNames[index]).prefix(salt.count) == salt {
                let dirName = String(arrayNames[index].suffix(arrayNames[index].count - salt.count))
                cell.setLabel(dirName)
                cell.setThumbnail(UIImage(named: folderImgKey)!)
                cell.showRoIcon(false)
            }
            else {
                // Load image
                let filePath = currentDirs[imagesString]! + separatorString + arrayNames[index] + jpgExtension
                let img = UIImage(contentsOfFile: filePath)
                cell.setThumbnail(img!)
                
                // Load label
                let xml = getXML(currentDirs[xmlString]! + separatorString + arrayNames[index] + xmlExtension)
                let label = (xml[xmlXiaKey][xmlTitleKey].value == nil) ? arrayNames[index] : xml[xmlXiaKey][xmlTitleKey].value!
                cell.setLabel(label)
                
                // Show reaod Only Icon
                let roState = (xml[xmlXiaKey][xmlreadonlyKey].value! == trueString) ? true : false
                cell.showRoIcon(roState)
            }
            
            if editingMode {
                if selectedPhotos.contains(indexPath) {
                    cell.setLabelBkgColor(selectingColor)
                }
                else {
                    cell.setLabelBkgColor(UIColor.clear)
                }
                cell.wobble(true)
            }
        }
        let tap = UITapGestureRecognizer(target: self, action:#selector(ViewCollectionController.handleTap(_:)))
        tap.delegate = self
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    func changeCellLabelBkgColor(_ path: IndexPath) {
        var labelColor: UIColor
        if selectedPhotos.contains(path) {
            let indexOfPhoto = selectedPhotos.index(of: path)
            selectedPhotos.remove(at: indexOfPhoto!)
            labelColor = UIColor.clear
            if arrayNames[path.row].prefix(salt.count) == salt {
                dirsInSelection = dirsInSelection - 1
            }
        }
        else {
            selectedPhotos.append(path)
            labelColor = selectingColor
            if arrayNames[path.row].prefix(salt.count) == salt {
                dirsInSelection = dirsInSelection + 1
            }
        }
        if let cell = CollectionView.cellForItem(at: path) {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.setLabelBkgColor(labelColor)
            navBarTitle.title = String(selectedPhotos.count) + spaceString + ((selectedPhotos.count > 1) ? NSLocalizedString(fileSelectedKey, comment: emptyString) : NSLocalizedString(fileSelectedKey, comment: emptyString))
        }
    }
    
    func checkDirName(dirName: String) -> Bool {
        let fileManager = FileManager.default
        if !dirName.isAlphanumeric {
            let alert = UIAlertController(title: NSLocalizedString(warningKey, comment: emptyString), message: NSLocalizedString(alphaNumKey, comment: emptyString), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if reservedDirs.contains(dirName) {
            let alert = UIAlertController(title: NSLocalizedString(warningKey, comment: emptyString), message: NSLocalizedString(reservedKey, comment: emptyString), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if fileManager.fileExists(atPath: self.currentDirs[rootString]! + separatorString + dirName) {
            let alert = UIAlertController(title: NSLocalizedString(warningKey, comment: emptyString), message: NSLocalizedString(alreadyExistKey, comment: emptyString), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func endEdit() {
        editingMode = false
        editMode.title = NSLocalizedString(editKey, comment: emptyString)
        for cell in CollectionView.visibleCells {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.wobble(false)
            customCell.setLabelBkgColor(UIColor.clear)
        }
        CollectionView.reloadData()
        btnCreateState.isEnabled = true
        btnCreateState.tintColor = UIColor.white
        btnDirs.isEnabled = true
        btnDirs.tintColor = UIColor.white
        navBar.barTintColor = blueColor
        self.view.backgroundColor = blueColor
        navBar.tintColor = UIColor.white
        navBarTitle.title = (currentDirs[rootString]! == documentsDirectory) ?
            XiaTitleString : String(format: XiaTitleSubDirString, getDirName(path: currentDirs[rootString]!))
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func deleteFiles(_ path: IndexPath) {
        let deleteIndex = (path as NSIndexPath).row
        let fileName = arrayNames[deleteIndex]
        // Delete the file
        let fileManager = FileManager()
        do {
            if fileName.prefix(salt.count) == salt {
                try fileManager.removeItem(atPath: currentDirs[rootString]! + separatorString + fileName.suffix(fileName.count - salt.count))
            } else {
                var filePath = currentDirs[imagesString]! + separatorString + fileName + jpgExtension
                try fileManager.removeItem(atPath: filePath)
                filePath = currentDirs[xmlString]! + separatorString + fileName + xmlExtension
                try fileManager.removeItem(atPath: filePath)
            }
        }
        catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        // Update arrays
        self.arrayNames.remove(at: deleteIndex)
    }
    
    @objc func handleTap(_ gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: CollectionView)
        let indexPath = CollectionView.indexPathForItem(at: p)
        if let path = indexPath {
            segueIndex = (path as NSIndexPath).row
            if editingMode {
                if segueIndex != -1 {
                    changeCellLabelBkgColor(path)
                }
                buildLeftNavbarItems(selectedPhotos.count)
            }
            else if arrayNames.count == 0 {
                performSegue(withIdentifier: addSegueKey, sender: self)
            }
            else if String(arrayNames[segueIndex]).prefix(salt.count) == salt {
                let dirName = String(arrayNames[segueIndex].suffix(arrayNames[segueIndex].count - salt.count))
                let oldRoot = currentDirs[rootString]
                currentDirs = getDirs(root: oldRoot! + separatorString + dirName)
                CollectionView.reloadData()
                buildLeftNavbarItems(0)
                navBarTitle.title = (currentDirs[rootString]! == documentsDirectory) ? XiaTitleString : String(format: XiaTitleSubDirString, getDirName(path: currentDirs[rootString]!))
            }
            else {
                let xmlToSegue = getXML(currentDirs[xmlString]! + separatorString + arrayNames[segueIndex] + xmlExtension)
                if xmlToSegue[xmlXiaKey][xmlreadonlyKey].value! == trueString {
                    // look for orientation before segue
                    let filePath = currentDirs[imagesString]! + separatorString + arrayNames[segueIndex] + jpgExtension
                    let img = UIImage(contentsOfFile: filePath)!
                    
                    landscape = (img.size.width > img.size.height) ? true : false
                    performSegue(withIdentifier: playXiaSegueKey, sender: self)
                }
                else {
                    performSegue(withIdentifier: viewLargePhotoSegueKey, sender: self)
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString(okKey, comment: emptyString), style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func startImport() {
        // Wait 2 seconds before looking for import
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC * 2000)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime){
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: importPath) {
                var importingPath = emptyString
                // move file to avoid multiple imports of the same file on collection display
                var i = 0
                var fileNotExist = true
                while fileNotExist {
                    importingPath = documentsDirectory + separatorString + importingString + String(i) + xmlExtension
                    if fileManager.fileExists(atPath: importingPath) {
                        i = i + 1
                    } else {
                        do {
                            try fileManager.moveItem(atPath: importPath, toPath: importingPath)
                            fileNotExist = false
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
                // Start to import the file
                if fileManager.fileExists(atPath: importingPath) {
                    DispatchQueue.global(qos: .background).async {
                        let importResult = self.importXML(importFilePath: importingPath)
                        
                        DispatchQueue.main.async {
                            if importResult {
                                self.displayAlert(title: NSLocalizedString(importKey, comment: emptyString),
                                                  message: NSLocalizedString(importSuccessKey, comment: emptyString))
                                self.CollectionView.reloadData()
                            } else {
                                self.displayAlert(title: NSLocalizedString(importKey, comment: emptyString),
                                                  message: NSLocalizedString(importErrorKey, comment: emptyString))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func importXML(importFilePath: String) -> Bool {
        let fileManager = FileManager.default
        var errorAtXMLImport = true
        let now:Int = Int(Date().timeIntervalSince1970)
        
        // read file to extract image
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: importFilePath))
            let startXia = xmlStartXiaString.data(using: String.Encoding.utf8)!
            let closeXia = xmlEndXiaString.data(using: String.Encoding.utf8)!
            
            let rangeXiaStart = data.range(of: startXia)
            let rangeXiaClose = data.range(of: closeXia)
            guard let xiaStart = rangeXiaStart?.lowerBound,
                let xiaEnd = rangeXiaClose?.upperBound
            else {
                do {
                    try fileManager.removeItem(atPath: importFilePath)
                } catch let error as NSError {
                    debugPrint(error.localizedDescription)
                }
                return false
            }
            
            let xiaStop = xiaEnd - 1
            let xmlData = data.subdata(in: Range(xiaStart...xiaStop))
            let xmlAsString = xmlHeaderString + String(data: xmlData, encoding: String.Encoding.utf8)!
            
            let startImage = xmlImageString.data(using: String.Encoding.utf8)!
            let rangeImageStart = data.range(of: startImage)
            let imageStart = (rangeImageStart?.upperBound)!
            let imageStop = data.count - 19
            
            let imageDataB64String = String(data: data.subdata(in: Range(imageStart...imageStop)), encoding: String.Encoding.utf8)!
            let imageDataB64 = Data(base64Encoded: imageDataB64String, options : .ignoreUnknownCharacters)!
            let image = UIImage(data: imageDataB64)
            
            
            // store new image to document directory
            let imageData = UIImageJPEGRepresentation(image!, 85)
            do {
                try imageData?.write(to: URL(fileURLWithPath: imagesDirectory + separatorString + String(now) + jpgExtension), options: [.atomicWrite])
            }
            catch {
                debugPrint(error.localizedDescription)
            }
            
            // store the xia xml
            try xmlAsString.write(toFile: xmlDirectory + separatorString + String(now) + xmlExtension, atomically: false, encoding: String.Encoding.utf8)
            errorAtXMLImport = false
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        
        // something were wrong, clean it !
        if errorAtXMLImport {
            do {
                try fileManager.removeItem(atPath: imagesDirectory + separatorString + String(now) + jpgExtension)
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
            return false
        }
        else {
            do {
                try fileManager.removeItem(atPath: importFilePath)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
            return true
        }
    }
    
    func migrateDatas() {
        // check if directories images & xml
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        
        let imagesPath = url.appendingPathComponent(imagesString).path
        let xmlPath = url.appendingPathComponent(xmlString).path
        if (!fileManager.fileExists(atPath: imagesPath)) {
            do { // create directories if necessary
                try fileManager.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
                try fileManager.createDirectory(atPath: xmlPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        let localPath = url.appendingPathComponent(localDatasKey).path
        if (!fileManager.fileExists(atPath: localPath)) {
            do { // Add local dir & sub-dirs
                try fileManager.createDirectory(atPath: localPath + separatorString + imagesString, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        } else {
            if fileManager.fileExists(atPath: localPath + separatorString + imagesString + separatorString + DSStoreString) {
                try? fileManager.removeItem(atPath: localPath + separatorString + imagesString + separatorString + DSStoreString)
            }
        }
        // move files to their directory
        do {
            let files = try fileManager.contentsOfDirectory(atPath: currentDirs[rootString]!)
            for file in files {
                if file != oembedKey + dotString + plistKey && file.contains(dotString) {
                    let ext = String(file.suffix(3))
                    switch (ext) {
                    case xmlString:
                        try fileManager.moveItem(atPath: documentsDirectory + separatorString + file, toPath: xmlPath + separatorString + file)
                        break;
                    case jpgString:
                        try fileManager.moveItem(atPath: documentsDirectory + separatorString + file, toPath: imagesPath + separatorString + file)
                        break;
                    default:
                        break;
                    }
                }
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
    }
}

