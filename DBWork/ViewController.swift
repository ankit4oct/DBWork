//
//  ViewController.swift
//  DBWork
//
//  Created by ANKIT SHARMA on 09/05/17.
//  Copyright © 2017 ANKIT SHARMA. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var name: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dbCreate(_ sender: UIButton) {
        print("create")
        let person = Person()
        person.id = ct()
        person.name = "name \(ct())"
        do
        {
        let realm = try Realm()
         
            try realm.write {
                
                realm.add(person)
                
            }

        }
        catch{
            print("Failed to create")
        }
        
    }

    @IBAction func dbUpdate(_ sender: UIButton) {
    
        print("update")
        let person = Person()
        person.id = (Int64(id.text!))!
        person.name = "\(String(describing: name.text!))"
        do
        {
            let realm = try Realm()
            
            try realm.write {
                
                realm.add(person , update:true)
                
            }
            
        }
        catch{
            print("Failed to create")
        }

    
    
    }
    @IBAction func dbDelete(_ sender: UIButton) {
    
        do
        {
            let realm = try Realm()
          //  let person = realm.objects(Person.self).filter("id=1494274422584")
            let person = realm.objects(Person.self).filter(String("id=\(id.text!)"))
            try realm.write {
                
                realm.delete(person)
                
            }
            
        }
        catch{
            print("Failed to create")
        }

    
    }
    
  
    @IBAction func dbList(_ sender: UIButton) {
    
    let realm = try! Realm()
    //let personList = realm.objects(Person.self)
    let personList = realm.objects(Person.self).filter(String("id=\(id.text!)"))
        for person in personList
        {
            print(person)
        }
        
        
    }
}

class Person : Object
{
    
    dynamic var id:Int64 = 0
    dynamic var name:String = ""
    
    override class func primaryKey()-> String
    {
        return "id"
    }
    
}

func ct()->Int64
{
    return Int64(NSDate().timeIntervalSince1970 * 1000)
    
}




