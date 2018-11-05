//
//  NewClassViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/26/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class NewClassViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var teacher: UITextField!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var color: UITextField!
    let pickerView = UIPickerView()
    
    var fieldWasSelected = false
    var fieldDidBeginEditing = false
    var previousVC = ClassesTableViewController() 
    var selectedColor : String?
    let colors = ["Red",
                  "Light green",
                  "Dark green",
                  "Light blue",
                  "Dark blue",
                  "Purple",
                  "Yellow",
                  "Grey",
                  "Brown",
                  "Orange"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        name.text = ""
        teacher.text = ""
        textViewPlaceholder()
        color.text = "Pick a color"
        pickerView.delegate = self
        color.inputView = pickerView
        color.delegate = self
        notes.delegate = self
        createToolBar()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if name.text != "" && teacher.text != "" && color.text != "Pick a color" {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let newClass = ClassEntity(context: context)
                if let unwrappedName = name.text {
                    if let unwrappedNotes = notes.text {
                        if let unwrappedTeacher = teacher.text {
                            if let unwrappedColor = color.text {
                                newClass.name = unwrappedName
                                newClass.notes = unwrappedNotes
                                newClass.teacher = unwrappedTeacher
                                let myColors : [Int] = chooseColor(color: unwrappedColor)
                                newClass.red = Int16(myColors[0])
                                newClass.green = Int16(myColors[1])
                                newClass.blue = Int16(myColors[2])
                            }
                        }
                    }
                }
                
                try? context.save()
                previousVC.shouldReloadData = true
                navigationController?.popViewController(animated: true)
                
            }
            
        } else {
            
            displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
            
        }
        
    }
    
    func chooseColor(color: String) -> [Int] {
        var colorArray = [1, 1, 1]
        switch(color) {
        case "Red":
            colorArray = [1, 0, 0]
        case "Light green":
            colorArray = [128/255, 1, 0]
        case "Dark green":
            colorArray = [76/255, 153/255, 0]
        case "Light blue":
            colorArray = [0, 1, 1]
        case "Dark blue":
            colorArray = [51/255, 51/255, 1]
        case "Purple":
            colorArray = [102/255, 0, 204/255]
        case "Yellow":
            colorArray = [1, 1, 0]
        case "Grey":
            colorArray = [160/255, 160/255, 160/255]
        case "Brown":
            colorArray = [102/255, 51/255, 0]
        case "Orange":
            colorArray = [1, 128/255, 0]
        default:
            colorArray = [1, 1, 1]
        }
        return colorArray
    }
    
    // MARK: - PickerView
    
    @objc func dismissKeyboardForPickerView() {
        view.endEditing(true)
        
        if !fieldWasSelected && fieldDidBeginEditing {
            color.text = colors[0]
        }
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForPickerView))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        color.inputAccessoryView = toolBar
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        fieldDidBeginEditing = true
        return true
    }
    
    // MARK: - Textview Placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notes.textColor == UIColor.lightGray {
            notes.text = ""
            notes.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notes.text.isEmpty {
            textViewPlaceholder()
        }
    }
    
    func textViewPlaceholder() {
        notes.text = "Add some notes!"
        notes.textColor = UIColor.lightGray
    }

}

extension NewClassViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        color.text = colors[row]
        fieldWasSelected = true
    }
    
}
