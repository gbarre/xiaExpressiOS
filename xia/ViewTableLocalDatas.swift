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
    
    let reuseIdentifier: String = "fileID"
    let fm: FileManager = FileManager.default
    
    var filesAudios: [String] = [String]()
    var filesImages: [String] = [String]()
    var filesVideos: [String] = [String]()
    var sections: [Int: String] = [Int: String]()
    var selectedElements: [String] = [String]()
    
    var ViewDetailInfosController: ViewDetailInfos?
    var cursorPosition: UITextRange?
    
    var txtBegin: Substring = ""
    var txtEnd: Substring = ""
    
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
        performSegue(withIdentifier: "showPicker", sender: sender)
    }
    
    @IBOutlet weak var btnTrash: UIBarButtonItem!
    @IBAction func btnTrashAction(_ sender: Any) {
        // Show confirm alert
        let controller = UIAlertController()
        let title = (selectedElements.count == 1) ? NSLocalizedString("DELETE_FILE", comment: "") : String(format: NSLocalizedString("DELETE_N_FILES", comment: ""), selectedElements.count)
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
        var txt = "\(txtBegin)"
        for media in selectedElements {
            txt = txt + "./" + media + ((selectedElements.count > 1) ? "\n" : "")
        }
        ViewDetailInfosController?.txtDesc.text = String(describing: txt) + "\(txtEnd)"
        self.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var i = 0
        filesAudios = getFiles(localDatasDirectory + "/audios")
        if filesAudios.count > 0 {
            sections[i] = "audios"
            i = i + 1
        }
        filesImages = getFiles(localDatasDirectory + "/images")
        if filesImages.count > 0 {
            sections[i] = "images"
            i = i + 1
        }
        filesVideos = getFiles(localDatasDirectory + "/videos")
        if filesVideos.count > 0 {
            sections[i] = "videos"
            i = i + 1
        }
        
        let height = (filesAudios.count + filesImages.count + filesVideos.count + sections.count) * 45
        self.preferredContentSize = CGSize(width: 300, height: height)
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.count > 0 {
            switch (sections[section])! {
            case "audios":
                return filesAudios.count
            case "images":
                return filesImages.count
            case "videos":
                return filesVideos.count
            default:
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        switch (sections[indexPath.section])! {
        case "audios":
            cell.textLabel?.text = filesAudios[indexPath.row]
        case "images":
            cell.textLabel?.text = filesImages[indexPath.row]
        case "videos":
            cell.textLabel?.text = filesVideos[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var touched = ""
        switch (sections[indexPath.section])! {
        case "audios":
            touched = "audios/" + filesAudios[indexPath.row]
        case "images":
            touched = "images/" + filesImages[indexPath.row]
        case "videos":
            touched = "videos/" + filesVideos[indexPath.row]
        default:
            break
        }
        if !selectedElements.contains(touched) {
            selectedElements.append(touched)
        }
        
        btnTrash.isEnabled = (selectedElements.count > 0)
        btnInsert.isEnabled = (selectedElements.count > 0)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var touched = ""
        switch (sections[indexPath.section])! {
        case "audios":
            touched = "audios/" + filesAudios[indexPath.row]
        case "images":
            touched = "images/" + filesImages[indexPath.row]
        case "videos":
            touched = "videos/" + filesVideos[indexPath.row]
        default:
            break
        }
        if selectedElements.contains(touched) {
            selectedElements.remove(at: selectedElements.index(of: touched)!)
        }
        
        btnTrash.isEnabled = (selectedElements.count > 0)
        btnInsert.isEnabled = (selectedElements.count > 0)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sections[section]
        return title?.firstUppercased
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPicker" {
            if let controller: ViewPicker = segue.destination as? ViewPicker {
                controller.tableLocalDatas = self
            }
        }
    }
    
    func deleteFiles() {
        for file in selectedElements {
            do {
                try fm.removeItem(atPath: localDatasDirectory + "/" + file)
            } catch {
                dbg.pt(error.localizedDescription)
            }
        }
        selectedElements = [String]()
    }
    
    func getFiles(_ dir: String) -> [String] {
        do {
            return try fm.contentsOfDirectory(atPath: dir)
        } catch {
            dbg.pt(error.localizedDescription)
            return [String]()
        }
        
    }

}
