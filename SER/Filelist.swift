//
//  Filelist.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 9..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import UIKit

class FilelistViewController: UITableViewController{
    var wavFileNames : [String]!
    var wavFiles : [URL]!
    var file_count : Int = 0
    var Items: [FilelistItem]!
    var directoryContents : [URL]!
    var documentsUrl : URL!
    
    required init?(coder aDecoder: NSCoder) {
        Items = [FilelistItem]()
        documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //print("dd: ",directoryContents)
            // if you want to filter the directory contents you can do like this:
            wavFiles = directoryContents.filter{ $0.pathExtension == "wav" }
            //print("wav urls:",wavFiles)
            wavFileNames = wavFiles.map{ $0.deletingPathExtension().lastPathComponent }
            //print("wav list:", wavFileNames)
            for i in wavFileNames{
                let a = FilelistItem()
                a.text = i
                a.checked = false
                Items.append(a)
                file_count += 1
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    //let audioFilename = getDocumentsDirectory()
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return file_count
    }
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilelistItem", for: indexPath)
        let item = Items[indexPath.row]
        
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //print(indexPath.row)
            deletefile(index: indexPath.row)
            Items.remove(at: indexPath.row)
            file_count -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            if Items != []{
                if #available(iOS 11.0, *) {
                    ViewController.shared.result = wavFileNames[indexPath.row] + ".wav"
                } else {
                    // Fallback on earlier versions
                }
            }
            else{
                if #available(iOS 11.0, *) {
                    ViewController.shared.result = ""
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = Items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)
            //print(indexPath.row,file_count)
            for i in 0 ..< file_count{
                if i != indexPath.row{
                    let item = Items[i]
                    if let cell1 = tableView.cellForRow(at: IndexPath(row: i, section: 0)){
                        item.checked = false
                        configureCheckmark(for: cell1, with: item)
                    }
                }
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func configureText(for cell: UITableViewCell,
                       with item: FilelistItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }
    func configureCheckmark(for cell: UITableViewCell,
                            with item: FilelistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    func deletefile(index: Int){
        let documentsPath = documentsUrl.path
        do {
            //print(index)
            let filePathName = "\(documentsPath)/\(Items[index].text).wav"
            //print(filePathName)
            try FileManager.default.removeItem(atPath: filePathName)
        } catch {
            print("Could not delete file: \(error)")
        }
    }
    @IBAction func choose( ) {
        var flag=0
        for i in 0 ..< file_count {
            if Items[i].checked == true{
                flag=1
                if #available(iOS 11.0, *) {
                    ViewController.shared.result = wavFileNames[i] + ".wav"
                } else {
                    // Fallback on earlier versions
                }
                break
            }
        }
        if flag == 1 {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
