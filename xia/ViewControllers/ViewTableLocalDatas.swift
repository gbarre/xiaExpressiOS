//
//  ViewTableLocalDatas
//  xia
//
//  Created by Guillaume on 25/01/2018.
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

class ViewTableLocalDatas: UITableViewController {
    
    let fm: FileManager = FileManager.default
    
    var filesImages: [String] = [String]()
    var selectedElements: [String] = [String]()
    
    var ViewDetailInfosController: ViewDetailInfos?
    var cursorPosition: UITextRange?
    
    var txtBegin: Substring = Substring(emptyString)
    var txtEnd: Substring = Substring(emptyString)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTrash.isEnabled = false
        btnInsert.isEnabled = false
        let txtDesc = ViewDetailInfosController?.txtDesc
        if let selectedRange = txtDesc?.selectedTextRange {
            let start = txtDesc?.offset(from:(txtDesc?.beginningOfDocument)! , to: selectedRange.start)
            let end = txtDesc?.offset(from:(txtDesc?.beginningOfDocument)! , to: selectedRange.end)
            txtBegin = (txtDesc?.text.prefix(start!))!
            txtEnd = (txtDesc?.text.suffix((txtDesc?.text.count)! - end!))!
        }
    }
    @IBAction func btnAdd(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: showPickerSegueKey, sender: sender)
    }
    
    @IBOutlet weak var btnTrash: UIBarButtonItem!
    @IBAction func btnTrashAction(_ sender: Any) {
        // Show confirm alert
        let controller = UIAlertController()
        let title = (selectedElements.count == 1) ? NSLocalizedString(deleteFileKey, comment: emptyString) : String(format: NSLocalizedString(deleteNFilesKey, comment: emptyString), selectedElements.count)
        let confirmDelete = UIAlertAction(title: title, style: .destructive) { action in
            self.deleteFiles()
            self.tableView.reloadData()
        }
        controller.addAction(confirmDelete)
        if let ppc = controller.popoverPresentationController {
            ppc.barButtonItem = btnTrash
            ppc.permittedArrowDirections = .up
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnInsert: UIBarButtonItem!
    @IBAction func btnInsertAction(_ sender: Any) {
        var txt = String(txtBegin)
        for media in selectedElements {
            txt = txt + spaceString + dotString + separatorString + media + ((selectedElements.count > 1) ? htmlBreakLineString : emptyString)
        }
        ViewDetailInfosController?.txtDesc.text = String(describing: txt) + String(txtEnd)
        self.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        filesImages = getFiles(localDatasDirectory + separatorString + imagesString)
        let height = 45 * (filesImages.count + 1)
        self.preferredContentSize = CGSize(width: 300, height: height)
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filesImages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fileIdentifier, for: indexPath)
        
        cell.textLabel?.text = filesImages[indexPath.row]
        
        // show thumbnail
        let filePath = localDatasDirectory + separatorString + imagesString + separatorString + filesImages[indexPath.row]
        if fm.fileExists(atPath: filePath) {
            let cover = UIImage(contentsOfFile: filePath)
            cell.imageView?.image = cover
            let itemSize = CGSize.init(width: 30, height: 30)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let touched = imagesString + separatorString + filesImages[indexPath.row]
        
        if !selectedElements.contains(touched) {
            selectedElements.append(touched)
        }
        
        btnTrash.isEnabled = (selectedElements.count > 0)
        btnInsert.isEnabled = (selectedElements.count > 0)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let touched = imagesString + separatorString + filesImages[indexPath.row]
        
        if selectedElements.contains(touched) {
            selectedElements.remove(at: selectedElements.firstIndex(of: touched)!)
        }
        
        btnTrash.isEnabled = (selectedElements.count > 0)
        btnInsert.isEnabled = (selectedElements.count > 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showPickerSegueKey {
            if let controller: ViewPicker = segue.destination as? ViewPicker {
                controller.tableLocalDatas = self
            }
        }
    }
    
    func deleteFiles() {
        for file in selectedElements {
            do {
                try fm.removeItem(atPath: localDatasDirectory + separatorString + file)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        selectedElements = [String]()
    }
    
    func getFiles(_ dir: String) -> [String] {
        do {
            return try fm.contentsOfDirectory(atPath: dir)
        } catch {
            debugPrint(error.localizedDescription)
            return [String]()
        }
        
    }

}
