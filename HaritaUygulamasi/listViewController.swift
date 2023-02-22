//
//  listViewController.swift
//  HaritaUygulamasi
//
//  Created by EMİN ÇETİN on 13.12.2022.
//

import UIKit
import CoreData



class listViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   @IBOutlet weak var listTableView: UITableView!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerIsmi = ""
    var secilenYerId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

   listTableView.delegate = self
   listTableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artibuttonTiklandi))
        
        
        veriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
    
    
     @objc func veriAl(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        
        
        do{
            
            let sonuclar = try context.fetch(request)
            if sonuclar.count>0  {
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                    
                    
                    
                }
                
                
                listTableView.reloadData()
                
                
            }
            
        }catch{
            
            print("Hata var")
            
        }

    }
    
    

    @objc func artibuttonTiklandi(){
        secilenYerIsmi = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
    } 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC"{
            let destinationVC = segue.destination as! mapsViewController
            destinationVC.secilenIsim=secilenYerIsmi
            destinationVC.secilenId=secilenYerId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            
            fetchRequest.predicate = NSPredicate(format: "id = %@",uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count>0 {
                    for sonuc in sonuclar as! [NSManagedObject]{
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("Hata Varr")
                                }
                                
                                break
                                
                            }
                        }
                    }
                }
            } catch{
                
            }
            
            
        }
        
        
        
    }
    
    
    
}
