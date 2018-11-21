//
//  EditNameViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 11/6/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if nameField.text != "" {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                if let entityUsername = try? context.fetch(UsernameEntity.fetchRequest()) as? [UsernameEntity] {
                    
                    if let coreDataUsername = entityUsername {
                        if coreDataUsername.count > 0 {
                            context.delete(coreDataUsername[0])
                        }
                    }
                }
                
                let myName = UsernameEntity(context: context)
                if let unwrappedName = nameField.text {
                    myName.username = unwrappedName
                }
                
                try? context.save()
                navigationController?.popViewController(animated: true)
            }
            
        }
    
    }

}
