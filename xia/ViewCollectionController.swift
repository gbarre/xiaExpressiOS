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

class ViewCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @objc var arrayNames = [String]()
    @objc var arraySortedNames = [String: String]() // Label : FileName
    @objc var segueIndex: Int = -1
    @objc var editingMode: Bool = false
    @objc var showHelp = false
    
    @objc var b64IMG:String = ""
    @objc var currentElement:String = ""
    @objc var passData:Bool=false
    @objc var passName:Bool=false
    @objc let reuseIdentifier = "PhotoCell"
    var newMedia: Bool?
    @objc var landscape: Bool = false
    
    @objc var selectedPhotos = [IndexPath]()
    
    @IBOutlet var navBar: UINavigationBar!
    
    @IBOutlet var btnTrash: UIBarButtonItem!
    @IBAction func btnTrashAction(_ sender: AnyObject) {
        // Show confirm alert
        let controller = UIAlertController()
        let title = (selectedPhotos.count == 1) ? NSLocalizedString("DELETE_FILE", comment: "") : String(format: NSLocalizedString("DELETE_N_FILES", comment: ""), selectedPhotos.count)
        let confirmDelete = UIAlertAction(title: title, style: .destructive) { action in
            // Reorder paths to delete from the end
            
            // Valid for swift 3, do not touch !!!
            /*var indexes = [Int:IndexPath]()
             for path in self.selectedPhotos {
             indexes[(path as NSIndexPath).row] =  path
             }
             let sortedIndexes = indexes.keys.sorted()
             var i = self.arrayNames.count - 1
             while i >= sortedIndexes.first {
             if sortedIndexes.contains(i) {
             self.deleteFiles(indexes[i]!)
             }
             i = i - 1
             }*/ // End swift 3
            
            // Valid for swift 2.2
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
            }// end swift 2.2
            
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
    
    @IBOutlet var btnExport: UIBarButtonItem!
    @IBAction func btnExportAction(_ sender: AnyObject) {
        segueIndex = (selectedPhotos[0] as NSIndexPath).row
        performSegue(withIdentifier: "export", sender: self)
    }
    
    @IBOutlet var btnEdit: UIBarButtonItem!
    @IBAction func btnEditAction(_ sender: AnyObject) {
        segueIndex = (selectedPhotos[0] as NSIndexPath).row
        performSegue(withIdentifier: "viewMetas", sender: self)
    }
    
    @IBOutlet var btnCopy: UIBarButtonItem!
    @IBAction func btnCopyAction(_ sender: AnyObject) {
        // Show confirm alert
        let controller = UIAlertController()
        let confirmDuplicate = UIAlertAction(title: NSLocalizedString("DUPLICATE", comment: ""), style: .default) { action in
            // copy file
            let now:Int = Int(Date().timeIntervalSince1970)
            let selectedPhoto = self.arrayNames[(self.selectedPhotos[0] as NSIndexPath).row]
            
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(atPath: "\(imagesDirectory)/\(selectedPhoto).jpg", toPath: "\(imagesDirectory)/\(now).jpg")
                try fileManager.copyItem(atPath: "\(xmlDirectory)/\(selectedPhoto).xml", toPath: "\(xmlDirectory)/\(now).xml")
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
            
            // Exit editing mode
            self.endEdit()
            // Rebuild the navbar
            self.buildLeftNavbarItems()
            self.arrayNames.append("\(now)")
            self.CollectionView.reloadData()
            
        }
        controller.addAction(confirmDuplicate)
        if let ppc = controller.popoverPresentationController {
            ppc.barButtonItem = btnCopy
            ppc.permittedArrowDirections = .up
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet var navBarTitle: UINavigationItem!
    
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
            self.editMode.title = NSLocalizedString("DONE", comment: "")
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
            navBar.barTintColor = selectingColor
            self.view.backgroundColor = selectingColor
            navBar.tintColor = UIColor.white
            navBarTitle.title = "\(selectedPhotos.count) " + ((selectedPhotos.count > 1) ? NSLocalizedString("FILES_SELECTED", comment: "") : NSLocalizedString("FILE_SELECTED", comment: ""))
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
        // Put the StatusBar in white
        UIApplication.shared.statusBarStyle = .lightContent
        
        // add observer to detect enter foreground and rebuild collection
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // purge tmp
        let fileManager = FileManager.default
        let files = fileManager.enumerator(atPath: "\(NSHomeDirectory())/tmp")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(NSHomeDirectory())/tmp/\(file)"
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        // Put the StatusBar in white
        UIApplication.shared.statusBarStyle = .lightContent
        startImport()
        self.CollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.hidesBarsOnTap = false
        startImport()
        editingMode = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.CollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIndex == -1 {
            segueIndex = 0
        }
        if (segue.identifier == "Add") {
            if let controller:ViewMenuAddResource = segue.destination as? ViewMenuAddResource {
                controller.ViewCollection = self
            }
        }
        else if arrayNames.count > 0 {
            let xmlToSegue = getXML("\(xmlDirectory)/\(arrayNames[segueIndex]).xml")
            let nameToSegue = "\(arrayNames[segueIndex])"
            if (segue.identifier == "viewLargePhoto") {
                endEdit()
                if let controller:ViewCreateDetails = segue.destination as? ViewCreateDetails {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                }
            }
            if (segue.identifier == "viewMetas") {
                if let controller:ViewMetas = segue.destination as? ViewMetas {
                    controller.xml = xmlToSegue
                    controller.fileName = nameToSegue
                    controller.ViewCollection = self
                }
            }
            if (segue.identifier == "playXia") {
                endEdit()
                if let controller:PlayXia = segue.destination as? PlayXia {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                    controller.landscape = landscape
                }
            }
            if (segue.identifier == "export") {
                if let controller:ViewExport = segue.destination as? ViewExport {
                    controller.fileName = nameToSegue
                    controller.xml = xmlToSegue
                    controller.ViewCollection = self
                }
            }
        }
    }
    
    @objc func buildLeftNavbarItems(_ selectedItems: Int = 0) {
        let buttonColor = (isEditing) ? selectingColor : blueColor
        switch selectedItems {
        case 1:
            btnTrash.isEnabled = true
            btnTrash.tintColor = UIColor.white
            btnExport.isEnabled = true
            btnExport.tintColor = UIColor.white
            btnEdit.isEnabled = true
            btnEdit.tintColor = UIColor.white
            btnCopy.isEnabled = true
            btnCopy.tintColor = UIColor.white
            break
        case 2...9999:
            btnTrash.isEnabled = true
            btnTrash.tintColor = UIColor.white
            btnExport.isEnabled = false
            btnExport.tintColor = buttonColor.withAlphaComponent(0)
            btnEdit.isEnabled = false
            btnEdit.tintColor = buttonColor.withAlphaComponent(0)
            btnCopy.isEnabled = false
            btnCopy.tintColor = buttonColor.withAlphaComponent(0)
            break
        default:
            btnTrash.isEnabled = false
            btnTrash.tintColor = buttonColor.withAlphaComponent(0)
            btnExport.isEnabled = false
            btnExport.tintColor = buttonColor.withAlphaComponent(0)
            btnEdit.isEnabled = false
            btnEdit.tintColor = buttonColor.withAlphaComponent(0)
            btnCopy.isEnabled = false
            btnCopy.tintColor = buttonColor.withAlphaComponent(0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        self.arrayNames = []
        // Load all images names
        let fileManager = FileManager.default
        let files = fileManager.enumerator(atPath: imagesDirectory)
        while let fileObject = files?.nextObject() {
            var file = fileObject as! String
            file = String(file.prefix(file.count - 4)) // remove .xyz
            if fileManager.fileExists(atPath: "\(xmlDirectory)/\(file).xml") {
                self.arrayNames.append(file)
            }
            else {
                do {
                    try fileManager.removeItem(atPath: "\(imagesDirectory)/\(file).jpg")
                }
                catch {
                    dbg.pt(error.localizedDescription)
                }
            }
        }
        // Add a "create image" if the is no image in Documents directory
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
            let xml = getXML("\(xmlDirectory)/\(name).xml")
            var title = (xml["xia"]["title"].value == nil) ? name : xml["xia"]["title"].value
            title = "\(String(describing: title))-\(name)"
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
        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnail
        
        if arrayNames.count == 0 {
            cell.setLabel(NSLocalizedString("CREATE_DOCUMENT", comment: ""))
            cell.setThumbnail(UIImage(named: "plus")!)
            cell.showRoIcon(false)
        }
        else {
            let index = (indexPath as NSIndexPath).item
            // Load image
            let filePath = "\(imagesDirectory)/\(arrayNames[index]).jpg"
            let img = UIImage(contentsOfFile: filePath)
            cell.setThumbnail(img!)
            
            // Load label
            let xml = getXML("\(xmlDirectory)/\(arrayNames[index]).xml")
            let label = (xml["xia"]["title"].value == nil) ? arrayNames[index] : xml["xia"]["title"].value!
            cell.setLabel(label)
            
            // Show reaod Only Icon
            let roState = (xml["xia"]["readonly"].value! == "true") ? true : false
            cell.showRoIcon(roState)
            
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
    
    @objc func changeCellLabelBkgColor(_ path: IndexPath) {
        var labelColor: UIColor
        if selectedPhotos.contains(path) {
            let indexOfPhoto = selectedPhotos.index(of: path)
            selectedPhotos.remove(at: indexOfPhoto!)
            labelColor = UIColor.clear
        }
        else {
            selectedPhotos.append(path)
            labelColor = selectingColor
        }
        if let cell = CollectionView.cellForItem(at: path) {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.setLabelBkgColor(labelColor)
            navBarTitle.title = "\(selectedPhotos.count) " + ((selectedPhotos.count > 1) ? NSLocalizedString("FILES_SELECTED", comment: "") : NSLocalizedString("FILE_SELECTED", comment: ""))
        }
    }
    
    @objc func endEdit() {
        editingMode = false
        editMode.title = NSLocalizedString("EDIT", comment: "")
        for cell in CollectionView.visibleCells {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.wobble(false)
            customCell.setLabelBkgColor(UIColor.clear)
        }
        CollectionView.reloadData()
        btnCreateState.isEnabled = true
        btnCreateState.tintColor = UIColor.white
        navBar.barTintColor = blueColor
        self.view.backgroundColor = blueColor
        navBar.tintColor = UIColor.white
        navBarTitle.title = "Xia"
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // Put the StatusBar in white
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @objc func deleteFiles(_ path: IndexPath) {
        let deleteIndex = (path as NSIndexPath).row
        let fileName = arrayNames[deleteIndex]
        // Delete the file
        let fileManager = FileManager()
        do {
            var filePath = "\(imagesDirectory)/\(fileName).jpg"
            try fileManager.removeItem(atPath: filePath)
            filePath = "\(xmlDirectory)/\(fileName).xml"
            try fileManager.removeItem(atPath: filePath)
        }
        catch let error as NSError {
            dbg.pt(error.localizedDescription)
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
                performSegue(withIdentifier: "Add", sender: self)
            }
            else {
                let xmlToSegue = getXML("\(xmlDirectory)/\(arrayNames[segueIndex]).xml")
                if xmlToSegue["xia"]["readonly"].value! == "true" {
                    // look for orientation before segue
                    let filePath = "\(imagesDirectory)/\(arrayNames[segueIndex]).jpg"
                    let img = UIImage(contentsOfFile: filePath)!
                    
                    landscape = (img.size.width > img.size.height) ? true : false
                    performSegue(withIdentifier: "playXia", sender: self)
                }
                else {
                    performSegue(withIdentifier: "viewLargePhoto", sender: self)
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func startImport() {
        // Wait 2 seconds before looking for import
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC * 2000)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime){
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: importPath) {
                var importingPath = ""
                // move file to avoid multiple imports of the same file on collection display
                var i = 0
                var fileNotExist = true
                while fileNotExist {
                    importingPath = "\(documentsDirectory)/importing\(i).xml"
                    if fileManager.fileExists(atPath: importingPath) {
                        i = i + 1
                    } else {
                        do {
                            try fileManager.moveItem(atPath: importPath, toPath: importingPath)
                            fileNotExist = false
                        } catch {
                            dbg.pt(error.localizedDescription)
                        }
                    }
                }
                // Start to import the file
                if fileManager.fileExists(atPath: importingPath) {
                    self.displayAlert(title: "Import", message: "Starting import... Continue to work")
                    DispatchQueue.global(qos: .background).async {
                        let importResult = self.importXML(importFilePath: importingPath)
                        
                        DispatchQueue.main.async {
                            if importResult {
                                self.displayAlert(title: "Import", message: "Import successfull")
                                self.CollectionView.reloadData()
                            } else {
                                self.displayAlert(title: "Import", message: "Error at import")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func importXML(importFilePath: String) -> Bool {
        let fileManager = FileManager.default
        var errorAtImageImport = true
        var errorAtXMLImport = true
        let now:Int = Int(Date().timeIntervalSince1970)
        
        dbg.pt("Try import file... from \(importFilePath)")
        // read file to extract image
        let xml = getXML(importFilePath, check: false)
        if (xml["XiaiPad"]["image"].value != "element <image> not found") {
            dbg.pt("Image founded")
            // convert base64 to image
            let imageDataB64 = Data(base64Encoded: xml["XiaiPad"]["image"].value!, options : .ignoreUnknownCharacters)
            let image = UIImage(data: imageDataB64!)
            // store new image to document directory
            let imageData = UIImageJPEGRepresentation(image!, 85)
            do {
                try imageData?.write(to: URL(fileURLWithPath: "\(imagesDirectory)/\(now).jpg"), options: [.atomicWrite])
                dbg.pt("Image imported")
                errorAtImageImport = false
            }
            catch {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // store the xia xml
        if (xml["XiaiPad"]["xia"].value != "element <xia> not found" && !errorAtImageImport) {
            dbg.pt("Try to import xia elements")
            let xmlXIA = AEXMLDocument()
            let _ = xmlXIA.addChild(xml["XiaiPad"]["xia"])
            let xmlString = xmlXIA.xml
            do {
                try xmlString.write(toFile: xmlDirectory + "/\(now).xml", atomically: false, encoding: String.Encoding.utf8)
                errorAtXMLImport = false
                dbg.pt("XML imported")
            }
            catch {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // something were wrong, clean it !
        if errorAtXMLImport {
            do {
                try fileManager.removeItem(atPath: "\(imagesDirectory)/\(now).jpg")
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
            return false
        }
        else {
            do {
                try fileManager.removeItem(atPath: importFilePath)
            } catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
            dbg.pt("import done")
            return true
        }
    }
    
    func migrateDatas() {
        // check if directories images & xml
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        
        let imagesPath = url.appendingPathComponent("images").path
        let xmlPath = url.appendingPathComponent("xml").path
        if (!fileManager.fileExists(atPath: imagesPath)) {
            do { // create directories if necessary
                try fileManager.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
                try fileManager.createDirectory(atPath: xmlPath, withIntermediateDirectories: false, attributes: nil)
                dbg.pt("create directories")
            } catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        // move files to their directory
        let files = fileManager.enumerator(atPath: documentsDirectory)
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            if (String(file.prefix(6)) != "images" && String(file.prefix(3)) != "xml" && String(file.prefix(6)) != "oembed" && String(file.prefix(6)) != "import") {
                let ext = String(file.suffix(3))
                do {
                    switch (ext) {
                    case "xml":
                        try fileManager.moveItem(atPath: documentsDirectory + "/" + file, toPath: xmlPath + "/" + file)
                        break;
                    case "jpg":
                        try fileManager.moveItem(atPath: documentsDirectory + "/" + file, toPath: imagesPath + "/" + file)
                        break;
                    default:
                        break;
                    }
                } catch let error as NSError {
                    dbg.pt(error.localizedDescription)
                }
            }
        }
    }
}

