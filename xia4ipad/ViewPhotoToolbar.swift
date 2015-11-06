//
//  VeiwPhotoToolbar.swift
//  xia4ipad
//
//  Created by Guillaume on 05/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewPhotoToolbar: UIToolbar {
    
    func addButtonCustom(toolbar: UIToolbar, customAction: Selector, image: String, size: CGSize) {
        //create the button
        let button = UIButton(type : UIButtonType.Custom)
        //set image for button
        if (image != "") {
            button.setImage(UIImage(named: "\(image)"), forState: UIControlState.Normal)
        }
        //add function for button
        button.addTarget(self, action: customAction, forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        button.frame = CGRectMake(0, 0, size.width, size.height)
        
        let nextPosition = toolbar.items?.count
        let barButton = UIBarButtonItem(customView: button)
        toolbar.items?.insert(barButton, atIndex: nextPosition!)
    }
    
    func addButtonSystem(toolbar: UIToolbar, action: Selector, systemItem: UIBarButtonSystemItem) {
        /* 
            systemItem cases : Done Cancel Edit Save Add FlexibleSpace FixedSpace Compose Reply Action Organize
                    Bookmarks Search Refresh Stop Camera Trash Play Pause Rewind FastForward Undo Redo PageCurl
            https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIBarButtonItem_Class/#//apple_ref/c/tdef/UIBarButtonSystemItem
        */
        
        let nextPosition = toolbar.items?.count
        let barButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: action)
        toolbar.items?.insert(barButton, atIndex: nextPosition!)
    }
    
}
