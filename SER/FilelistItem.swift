//
//  FilelistItem.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 9..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import Foundation

class FilelistItem : NSObject {
    var text=""
    var checked = false
    
    /* For toggling */
    func toggleChecked() {
        checked = !checked
    }
    
}
