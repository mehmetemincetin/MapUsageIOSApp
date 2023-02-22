//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by EMİN ÇETİN on 12.12.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class mapsViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var secilenLongitude = Double()
    var secilenLatitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle=""
    var annotaitonSubTitle=""
    var annotationLatitude = Double()
    var annotationLongitude = Double()

    
    
    
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate=self
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
       let gestureRecognizer=UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration=1
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim !=  "" {
            if let uuidString = secilenId?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0{
                    
                        for sonuc in sonuclar as! [NSManagedObject] {
                       if let isim = sonuc.value(forKey: "isim") as? String {
                                 annotationTitle = isim
                       if let not = sonuc.value(forKey: "not") as? String {
                                    annotaitonSubTitle = not
                       if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                       if let longitude = sonuc.value(forKey: "longitude") as? Double  {
                                         annotationLongitude = longitude
                           
                           
                           let annotation = MKPointAnnotation()
                           annotation.title = annotationTitle
                           annotation.subtitle = annotaitonSubTitle
                           let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                           annotation.coordinate = coordinate
                           
                           mapView.addAnnotation(annotation)
                           isimTextField.text = annotationTitle
                           notTextField.text = annotaitonSubTitle
                           
                           locationManager.stopUpdatingLocation()
                           let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                           let region = MKCoordinateRegion(center: coordinate, span: span)
                           
                           mapView.setRegion(region, animated: true)
                           
                                            
                                            
                            }
                           
                            }
                            
                            }
                            
                            }
                            
                            
                            
                        }
                    }
                } catch{
                    print("Hata Var")
                }
                
                
                
                
                
                
                
            }
        }
        else {
            //yeni veri ekleme
        }
        


    }
    
    func mapView( _ mapView:MKMapView,viewFor annotation:MKAnnotation) ->MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "benimAnnotation"
        var pienView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pienView == nil{
            
            pienView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pienView?.canShowCallout = true
            pienView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pienView?.rightCalloutAccessoryView = button
            
            
            
        } else{
            pienView?.annotation = annotation
        }
        return pienView
    }
    @objc func konumSec(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
             
            
            
            let dokunulanNokta=gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat=mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude=dokunulanKoordinat.latitude
            secilenLongitude=dokunulanKoordinat.longitude
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
            
        }
    }
    

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if secilenIsim == "" {
            let location=CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    


    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let yeniYer=NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        
        do{
            try context.save()
            print("Kayıt Edildi")
        }catch{
            print("Hata Var")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true)
    
        
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkDizisi,hata) in
                
                if let placemarks = placemarkDizisi{
                    if placemarks.count > 0 {
                        
                        let yeniPlacemark = MKPlacemark(placemark:  placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions:launchOptions)
                        
                    }
                    
                    
                    
                }
                
                
                
                
                
                
                
                
            }
        }
    }
    
    
    
    
    
    
    
}

