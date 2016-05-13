//
//  ViewCollectionController.swift
//  xia4ipad
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
    
    var dbg = debug(enable: true)
    
    let documentsDirectory = NSHomeDirectory() + "/Documents"
    var arrayNames = [String]()
    var arraySortedNames = [String: String]() // Label : FileName
    let cache = NSCache()
    var segueIndex: Int = -1
    var editingMode: Bool = false
    var showHelp = false

    var b64IMG:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    let reuseIdentifier = "PhotoCell"
    var newMedia: Bool?
    let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
    var landscape: Bool = false
    
    var selectedPhotos = [NSIndexPath]()
    let selectingColor = UIColor(red: 255/255, green: 131/255, blue: 0/255, alpha: 1)
    
    @IBOutlet var navBar: UINavigationBar!
    
    @IBOutlet var btnTrash: UIBarButtonItem!
    @IBAction func btnTrashAction(sender: AnyObject) {
        // Show confirm alert
        let controller = UIAlertController()
        let title = (selectedPhotos.count == 1) ? NSLocalizedString("DELETE_FILE", comment: "") : String(format: NSLocalizedString("DELETE_N_FILES", comment: ""), selectedPhotos.count)
        let confirmDelete = UIAlertAction(title: title, style: .Destructive) { action in
            // Reorder paths to delete from the end
            var indexes = [NSIndexPath:Int]()
            for path in self.selectedPhotos {
                indexes[path] = path.row
            }
            let sortedPath = (indexes as NSDictionary).keysSortedByValueUsingComparator{
                ($1 as! NSNumber).compare($0 as! NSNumber)
                }
            
            // Delete files
            for path in sortedPath {
                self.deleteFiles(path as! NSIndexPath)
            }
            // Exit editing mode
            self.endEdit()
            // Rebuild the navbar
            self.buildLeftNavbarItems()
        }
        controller.addAction(confirmDelete)
        if let ppc = controller.popoverPresentationController {
            ppc.barButtonItem = btnTrash
            ppc.permittedArrowDirections = .Up
        }
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBOutlet var btnExport: UIBarButtonItem!
    @IBAction func btnExportAction(sender: AnyObject) {
        segueIndex = selectedPhotos[0].row
        performSegueWithIdentifier("export", sender: self)
    }
    
    @IBOutlet var btnEdit: UIBarButtonItem!
    @IBAction func btnEditAction(sender: AnyObject) {
        segueIndex = selectedPhotos[0].row
        performSegueWithIdentifier("viewMetas", sender: self)
    }
    
    @IBOutlet var navBarTitle: UINavigationItem!
    
    @IBOutlet weak var btnCreateState: UIBarButtonItem!
    
    @IBOutlet weak var editMode: UIBarButtonItem!
    @IBAction func btnEdit(sender: AnyObject) {
        selectedPhotos = []
        if editingMode {
            endEdit()
        }
        else {
            editingMode = true
            // Change button title
            self.editMode.title = NSLocalizedString("DONE", comment: "")
            // Start cell wobbling
            for cell in CollectionView.visibleCells() {
                let customCell: PhotoThumbnail = cell as! PhotoThumbnail
                customCell.wobble(true)
            }
            CollectionView.allowsMultipleSelection = true
            CollectionView.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
            // Cosmetic...
            btnCreateState.enabled = false
            btnCreateState.tintColor = selectingColor.colorWithAlphaComponent(0)
            navBar.barTintColor = selectingColor
            self.view.backgroundColor = selectingColor
            navBar.tintColor = UIColor.whiteColor()
            navBarTitle.title = "\(selectedPhotos.count) " + ((selectedPhotos.count > 1) ? NSLocalizedString("FILES_SELECTED", comment: "") : NSLocalizedString("FILE_SELECTED", comment: ""))
            navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        buildLeftNavbarItems(selectedPhotos.count)
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide left navbar buttons
        buildLeftNavbarItems()
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // add observer to detect enter foreground and rebuild collection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        // purge tmp
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath("\(NSHomeDirectory())/tmp")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(NSHomeDirectory())/tmp/\(file)"
                try fileManager.removeItemAtPath(filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.CollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.hidesBarsOnTap = false
        
        editingMode = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.CollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segueIndex == -1 {
            segueIndex = 0
        }
        let xmlToSegue = getXML("\(documentsDirectory)/\(arrayNames[segueIndex]).xml")
        let nameToSegue = "\(arrayNames[segueIndex])"
        let pathToSegue = "\(documentsDirectory)/\(nameToSegue)"
        if (segue.identifier == "viewLargePhoto") {
            endEdit()
            if let controller:ViewCreateDetails = segue.destinationViewController as? ViewCreateDetails {
                controller.fileName = nameToSegue
                controller.filePath = pathToSegue
                controller.xml = xmlToSegue
            }
        }
        if (segue.identifier == "viewMetas") {
            if let controller:ViewMetas = segue.destinationViewController as? ViewMetas {
                controller.xml = xmlToSegue
                controller.filePath = pathToSegue
                controller.fileName = nameToSegue
                controller.landscape = landscape
                controller.ViewCollection = self
            }
        }
        if (segue.identifier == "playXia") {
            endEdit()
            if let controller:PlayXia = segue.destinationViewController as? PlayXia {
                controller.fileName = nameToSegue
                controller.filePath = pathToSegue
                controller.xml = xmlToSegue
                controller.landscape = landscape
            }
        }
        if (segue.identifier == "export") {
            if let controller:ViewExport = segue.destinationViewController as? ViewExport {
                controller.filePath = pathToSegue
                controller.fileName = nameToSegue
                controller.xml = xmlToSegue
                controller.ViewCollection = self
            }
        }
        if (segue.identifier == "Add") {
            if let controller:ViewMenuAddResource = segue.destinationViewController as? ViewMenuAddResource {
                controller.ViewCollection = self
            }
        }
    }
    
    func buildLeftNavbarItems(selectedItems: Int = 0) {
        let buttonColor = (editing) ? selectingColor : blueColor
        switch selectedItems {
        case 1:
            btnTrash.enabled = true
            btnTrash.tintColor = UIColor.whiteColor()
            btnExport.enabled = true
            btnExport.tintColor = UIColor.whiteColor()
            btnEdit.enabled = true
            btnEdit.tintColor = UIColor.whiteColor()
            break
        case 2...9999:
            btnTrash.enabled = true
            btnTrash.tintColor = UIColor.whiteColor()
            btnExport.enabled = false
            btnExport.tintColor = buttonColor.colorWithAlphaComponent(0)
            btnEdit.enabled = false
            btnEdit.tintColor = buttonColor.colorWithAlphaComponent(0)
            break
        default:
            btnTrash.enabled = false
            btnTrash.tintColor = buttonColor.colorWithAlphaComponent(0)
            btnExport.enabled = false
            btnExport.tintColor = buttonColor.colorWithAlphaComponent(0)
            btnEdit.enabled = false
            btnEdit.tintColor = buttonColor.colorWithAlphaComponent(0)
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
       self.arrayNames = []
        // Load all images names
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath(self.documentsDirectory)
        while let fileObject = files?.nextObject() {
            var file = fileObject as! String
            let ext = file.substringWithRange(file.endIndex.advancedBy(-3)..<file.endIndex.advancedBy(0))
            if (ext != "xml" && file != "Inbox") {
                file = file.substringWithRange(file.startIndex.advancedBy(0)..<file.endIndex.advancedBy(-4)) // remove .xyz
                if fileManager.fileExistsAtPath("\(documentsDirectory)/\(file).xml") {
                    self.arrayNames.append(file)
                }
                else {
                    do {
                        try fileManager.removeItemAtPath("\(documentsDirectory)/\(file).jpg")
                    }
                    catch {
                        self.dbg.pt("\(error)")
                    }
                }
            }
        }
        // Create default image if the is no image in Documents directory
        if ( self.arrayNames.count == 0 ) {
            let now:Int = Int(NSDate().timeIntervalSince1970)
            let filePath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
            let img = UIImage(contentsOfFile: filePath!)
            let imageData = UIImageJPEGRepresentation(img!, 85)
            imageData?.writeToFile(self.documentsDirectory + "/\(now).jpg", atomically: true)
            
            // Create associated xml
            let xml = AEXMLDocument()
            let xmlString = xml.createXML("\(now)")
            do {
                try xmlString.writeToFile(self.documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                self.dbg.pt("\(error)")
            }
            
            self.arrayNames.append("\(now)")
        }
        
        // order thumb by title
        self.arraySortedNames = [:]
        for name in self.arrayNames {
            let xml = getXML("\(self.documentsDirectory)/\(name).xml")
            var title = (xml["xia"]["title"].value == nil) ? name : xml["xia"]["title"].value
            title = "\(title)-\(name)"
            self.arraySortedNames[title!] = name
        }
        
        let orderedTitles = self.arraySortedNames.keys.sort()
        self.arrayNames = []
        for title in orderedTitles {
            self.arrayNames.append(self.arraySortedNames[title]!)
        }
        self.CollectionView.reloadData()
        
        return arrayNames.count;
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        
        let index = indexPath.item
        // Load image
        let filePath = "\(documentsDirectory)/\(arrayNames[index]).jpg"
        let img = UIImage(contentsOfFile: filePath)
        cell.setThumbnail(img!)
        
        // Load label
        let xml = getXML("\(documentsDirectory)/\(arrayNames[index]).xml")
        let label = (xml["xia"]["title"].value == nil) ? arrayNames[index] : xml["xia"]["title"].value!
        cell.setLabel(label)
        
        // Show reaod Only Icon
        let roState = (xml["xia"]["readonly"].value! == "true") ? true : false
        cell.showRoIcon(roState)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(ViewCollectionController.handleTap(_:)))
        tap.delegate = self
        cell.addGestureRecognizer(tap)
        
        if editingMode {
            if selectedPhotos.contains(indexPath) {
                cell.setLabelBkgColor(selectingColor)
            }
            else {
                cell.setLabelBkgColor(UIColor.clearColor())
            }
            cell.wobble(true)
        }
        
        return cell
    }
    
    func changeCellLabelBkgColor(path: NSIndexPath) {
        var labelColor: UIColor
        if selectedPhotos.contains(path) {
            let indexOfPhoto = selectedPhotos.indexOf(path)
            selectedPhotos.removeAtIndex(indexOfPhoto!)
            labelColor = UIColor.clearColor()
        }
        else {
            selectedPhotos.append(path)
            labelColor = selectingColor
        }
        if let cell = CollectionView.cellForItemAtIndexPath(path) {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.setLabelBkgColor(labelColor)
            navBarTitle.title = "\(selectedPhotos.count) " + ((selectedPhotos.count > 1) ? NSLocalizedString("FILES_SELECTED", comment: "") : NSLocalizedString("FILE_SELECTED", comment: ""))
        }
    }
    
    func endEdit() {
        editingMode = false
        editMode.title = NSLocalizedString("EDIT", comment: "")
        for cell in CollectionView.visibleCells() {
            let customCell: PhotoThumbnail = cell as! PhotoThumbnail
            customCell.wobble(false)
            customCell.setLabelBkgColor(UIColor.clearColor())
        }
        CollectionView.reloadData()
        btnCreateState.enabled = true
        btnCreateState.tintColor = UIColor.whiteColor()
        navBar.barTintColor = blueColor
        self.view.backgroundColor = blueColor
        navBar.tintColor = UIColor.whiteColor()
        navBarTitle.title = "Xia"
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Put the StatusBar in white
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    func deleteFiles(path: NSIndexPath) {
        let deleteIndex = path.row
        let fileName = arrayNames[deleteIndex]
        // Delete the file
        let fileManager = NSFileManager()
        do {
            var filePath = "\(self.documentsDirectory)/\(fileName).jpg"
            try fileManager.removeItemAtPath(filePath)
            filePath = "\(self.documentsDirectory)/\(fileName).xml"
            try fileManager.removeItemAtPath(filePath)
        }
        catch let error as NSError {
            self.dbg.pt(error.localizedDescription)
        }
        
        // Update arrays
        self.arrayNames.removeAtIndex(deleteIndex)
    }
    
    func handleTap(gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(CollectionView)
        let indexPath = CollectionView.indexPathForItemAtPoint(p)
        if let path = indexPath {
            segueIndex = path.row
            if editingMode {
                if segueIndex != -1 {
                    changeCellLabelBkgColor(path)
                }
                buildLeftNavbarItems(selectedPhotos.count)
            }
            else {
                let xmlToSegue = getXML("\(documentsDirectory)/\(arrayNames[segueIndex]).xml")
                if xmlToSegue["xia"]["readonly"].value! == "true" {
                    // look for orientation before segue
                    let filePath = "\(documentsDirectory)/\(arrayNames[segueIndex]).jpg"
                    let img = UIImage(contentsOfFile: filePath)!
                    
                    var value: Int
                    if ( img.size.width > img.size.height ) { // turn device to landscape
                        if( !UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) )
                        {
                            value = (UIDevice.currentDevice().orientation.rawValue == 5) ? 5 : 3
                            UIDevice.currentDevice().setValue(value, forKey: "orientation")
                        }
                        landscape = true
                    }
                    else { // turn device to portrait
                        if( !UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) )
                        {
                            value = (UIDevice.currentDevice().orientation.rawValue == 2) ? 2 : 1
                            UIDevice.currentDevice().setValue(value, forKey: "orientation")
                        }
                        landscape = false
                    }
                    performSegueWithIdentifier("playXia", sender: self)
                }
                else {
                    performSegueWithIdentifier("viewLargePhoto", sender: self)
                }
            }
        }
    }
}