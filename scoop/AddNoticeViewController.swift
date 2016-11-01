//
//  AddNoticeViewController.swift
//  scoop
//
//  Created by Juan Luis Garcia on 29/10/16.
//  Copyright © 2016 styleapps. All rights reserved.
//

import UIKit
import CoreLocation

class AddNoticeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
CLLocationManagerDelegate {
    
    //Datos para API
    var client : MSClient?
    var model : [Data]? = []
    //Para blobs
    var blobClient: AZSCloudClient?
    var container: AZSCloudBlobContainer?
    var blobModel: [AZSCloudBlockBlob] = []
    //Gestion de imagenes
    let imagePicker = UIImagePickerController()
    //String para identificar la imagen en BBDD
    var imageID : String? = ""
    //Para la localizacion
    var locationManager: CLLocationManager = CLLocationManager()
    var latitude : Double?
    var longitude: Double?
    //Estado de favoritos
    var publicState: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        //Para guardar la localizacion
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Datos y Botones
    
    @IBAction func publicNowButton(_ sender: AnyObject) {
        
        if labelOptionPublic.text == "No" {
            
            publicState = true
            labelOptionPublic.text = "Si"
            
        } else {
            
            publicState = false
            labelOptionPublic.text = "No"
            
        }
        
    }
    @IBOutlet weak var titleTxtField: UITextField!
    
    @IBOutlet weak var noticeTxtField: UITextView!
    
    @IBOutlet weak var labelOptionPublic: UILabel!
    
    /*----Referente a la imagen-----------------*/
    @IBAction func selectImage(_ sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        DispatchQueue.main.async{
            
             self.present(self.imagePicker , animated: true, completion: nil)
        }
    }
    
    /*----Referente a la imagen-----------------*/
    
    @IBOutlet weak var authorTxtField: UITextField!
    @IBOutlet weak var imageSelectedView: UIImageView!
    
    @IBAction func addNoticeButton(_ sender: AnyObject) {
        //Controlamos que todos los campos de texto se hayan rellenado
        if (titleTxtField.text == "" || noticeTxtField.text == "" || authorTxtField.text == "") {
         
            let alert = UIAlertController(title: "Faltan Campos",
                                          message: "Todos los campos de texto son obligatorios",
                                          preferredStyle: .alert)
            
            let actionOk = UIAlertAction(title: "OK", style: .default)
            alert.addAction(actionOk)
            present(alert, animated: true, completion: nil)
            return
        
        } else {
        
        uploadBlobWithImage(imageSelectedView.image!)
        let titleText = titleTxtField.text! as String
        let noticeText = noticeTxtField.text! as String
        //Almacenamos el ID para realmente identificar al author o al administrador de la app
        let authorID = (client?.currentUser?.userId)! as String
        let authorName = authorTxtField.text! as String
    

        
        addNotice(titleText, noticeText: noticeText, photoName: imageID!,
                  authorID: authorID, authorName: authorName,
                  latitudeObtained: latitude!, longitudeObtained: longitude!,
                  publicNotice: publicState!)
            
        let alert = UIAlertController(title: "Noticia Subida",
                                          message: "Noticia guardada correctamente",
                                          preferredStyle: .alert)
            
        let actionOk = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOk)
        
        present(alert, animated: true, completion: nil)
       
            
        }
    }

    func addNotice(_ title: String,
                   noticeText: String,
                   photoName: String,
                   authorID: String, authorName: String, latitudeObtained: Double, longitudeObtained: Double, publicNotice: Bool) {
        
        //Conexion a la tabla
        let tableMS = client?.table(withName: "Notices")
       
        tableMS?.insert(["title": title,
                        "noticeText": noticeText,
                        "photoNameMin": photoName + "min",
                        "photoNameMax" : photoName + "max",
                        "authorID": authorID, "authors": authorName,
                        "latitude": latitudeObtained,
                        "longitude": longitudeObtained, "ispublic": publicNotice, "markPublic": publicNotice]) { (result, error) in
                            
                            if let _ = error {
                                
                                print(error)
                                return
                            }
                            
                            
                _ = self.navigationController?.popViewController(animated: true)
                           
        }
    }
    
    //MARK: - AuxFunctions
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
         let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            imageSelectedView.contentMode = .scaleAspectFit
            imageSelectedView.image = pickedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Funciones de Blob
   func uploadBlobWithImage(_ image: UIImage){
        
        do {
            
            let sas = "?sv=2015-04-05&ss=bfqt&srt=sco&sp=rwdlacup&se=2016-11-30T18:36:30Z&st=2016-10-30T10:36:30Z&spr=https,http&sig=J69W2cXLEiqISWNyfpLMsWOCz6uxo0EI2HLThHlem1U%3D"
            
            let credentials = AZSStorageCredentials(sasToken: sas, accountName: "styleappsstorage")
            
            let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            let client = account.getBlobClient()
            
            let container = client?.containerReference(fromName: "noticesblob")
            
            imageID = UUID().uuidString
            
            var theBlob = container?.blockBlobReference(fromName: imageID!+"max")
            //subir
            
            theBlob?.upload(from: UIImageJPEGRepresentation(image, 0.5)!, completionHandler: { (error) in
                
                if error != nil {
                    
                    print(error)
                    return
                }
            })
            
            theBlob = container?.blockBlobReference(fromName: imageID!+"min")

            
            theBlob?.upload(from: UIImageJPEGRepresentation(image, 0.1)!, completionHandler: { (error) in
                
                if error != nil {
                    
                    print(error)
                    return
                }
            })
        } catch let ex {
            
            print(ex)
        }
    }
    
    //MARK: - Funciones de localizacion
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       latitude = locations[0].coordinate.latitude
       longitude = locations[0].coordinate.longitude
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
