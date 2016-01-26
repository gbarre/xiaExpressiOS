//
//  ViewDetailMenu.swift
//  xia4ipad
//
//  Created by Guillaume on 20/01/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewDetailMenu: UITableView {

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
}
