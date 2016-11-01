//
//  EditNoticeViewController.swift
//  scoop
//
//  Created by Juan Luis Garcia on 31/10/16.
//  Copyright © 2016 styleapps. All rights reserved.
//

import UIKit

class EditNoticeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var client : MSClient?
    var model : Data?
    
    //Variables de vista
    var markPublic : Bool? = false
    
    //Gestion de imagenes
    let imagePicker = UIImagePickerController()
    var imageChange = false
    //String para identificar la imagen en BBDD
    var imageID : String = ""
    
    let sas = "?sv=2015-04-05&ss=bfqt&srt=sco&sp=rwdlacup&se=2016-11-30T18:36:30Z&st=2016-10-30T10:36:30Z&spr=https,http&sig=J69W2cXLEiqISWNyfpLMsWOCz6uxo0EI2HLThHlem1U%3D"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Botones y datos de la vista
    
    @IBOutlet weak var titleTxtLbl: UITextField!{
        
        didSet{
            
            guard let titleNotice = model?["title"] as? String else {
                return
            }
            self.titleTxtLbl.text = titleNotice
        }
    }
    
    @IBOutlet weak var authorTxtLbl: UITextField!{
        
        didSet{
            
            guard let authorNotice = model?["authors"] as? String else {
                return
            }
            self.authorTxtLbl.text = authorNotice
        }
    }

    @IBOutlet weak var detailTxtLbl: UITextView!{
        didSet{
            
            guard let detailTxtNotice = model?["noticeText"] as? String else {
                return
            }
            
            self.detailTxtLbl.text = detailTxtNotice
        }
    }
    
    @IBOutlet weak var publicState: UILabel!{
        
        didSet{
            guard let publicStateNotice = model?["isPublic"] as? Bool else{
                return
            }
            
            if publicStateNotice == true {
                
                publicState.text = "Publicada"
            }
        }
    }
    
    @IBOutlet weak var publicMarkLbl: UILabel!
    
    @IBAction func changePublicState(_ sender: AnyObject) {
        
        if publicMarkLbl.text == "No" {
            
            markPublic = true
            publicMarkLbl.text = "Si"
        } else{
            
            markPublic = false
            publicMarkLbl.text = "No"
            
        }
        
    }
    @IBAction func imageButton(_ sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        DispatchQueue.main.async{
            
            self.present(self.imagePicker , animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var imageNotice: UIImageView!{
        
        didSet{
            guard let imageMinId = model?["photoNameMin"] as? String else{
                return
            }
            imageID = imageMinId
        
            let blobSelected = obtainBlob(imageMinId)
            blobSelected.downloadToData(completionHandler: { (error, data) in
        
            if let _ = data{
        
            DispatchQueue.main.async {
                self.imageNotice.image = UIImage(data: data!)
                }
            }
        })
      }
    }


    @IBAction func updateNotice(_ sender: AnyObject) {
        
        if (titleTxtLbl.text == "" || detailTxtLbl.text == "" || authorTxtLbl.text == "") {
            
            let alert = UIAlertController(title: "Faltan Campos",
                                          message: "Todos los campos de texto son obligatorios",
                                          preferredStyle: .alert)
            
            let actionOk = UIAlertAction(title: "OK", style: .default)
            alert.addAction(actionOk)
            
            present(alert, animated: true, completion: nil)
            return
            
        } else {
            if imageChange == true {
                uploadBlobWithImage(imageNotice.image!)
            }
            let titleText = titleTxtLbl.text! as String
            let noticeText = detailTxtLbl.text! as String
            let authorID = (client?.currentUser?.userId)! as String
            let authorName = authorTxtLbl.text! as String
            var photoNameFinal = imageID
            if imageChange == false{
                photoNameFinal = imageID.replacingOccurrences(of: "min", with: "")
            }
            
            updateNotice(titleText, noticeText: noticeText, photoName: photoNameFinal,
                         authorID: authorID, authorName: authorName, publicNotice: markPublic!)
            
        
        }
    }
    
    
    func updateNotice(_ title: String,
                   noticeText: String,
                   photoName: String,
                   authorID: String, authorName: String, publicNotice: Bool) {
        
        //Conexion a la tabla
        let tableMS = client?.table(withName: "Notices")
        
       
        if var finalState = model {
            finalState["title"] = title as AnyObject?
            finalState["noticeText"] = noticeText as AnyObject?
            if imageChange == true {
            finalState["photoNameMin"] = (photoName + "min") as AnyObject?
            finalState["photoNameMax"] = (photoName + "max") as AnyObject?
            }
            finalState["authorID"] = authorID as AnyObject?
            finalState["authors"] = authorName as AnyObject?
            finalState["markPublic"] = publicNotice as AnyObject?
        
            tableMS?.update(finalState, completion: {(result, error) in
                
                if let _ = error {
                    
                    print(error)
                    return
                }
            })
        }
        _ = self.navigationController?.popViewController(animated: true)
        }
    
    //MARK: - AuxFunctions
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageNotice.contentMode = .scaleAspectFit
        imageNotice.image = pickedImage
        imageChange = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Funciones de Blob
    func uploadBlobWithImage(_ image: UIImage){
        
       
          
            imageID = UUID().uuidString
            
            var theBlob = obtainBlob((imageID + "max"))
            
            theBlob.upload(from: UIImageJPEGRepresentation(image, 0.5)!, completionHandler: { (error) in
                
                if error != nil {
                    
                    print(error)
                    return
                }
            })
            
            //theBlob = container?.blockBlobReference(fromName: imageID + "min")
            theBlob = obtainBlob((imageID + "min"))

            theBlob.upload(from: UIImageJPEGRepresentation(image, 0.1)!, completionHandler: { (error) in
                
                if error != nil {
                    
                    print(error)
                    return
                }
            })
        }
    

    func obtainBlob(_ nameBlob : String) -> AZSCloudBlockBlob {
        
        var theBlob : AZSCloudBlockBlob?
        do{
            let credentials = AZSStorageCredentials(sasToken: sas, accountName: "styleappsstorage")
            let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            let client = account.getBlobClient()
            let container = client?.containerReference(fromName: "noticesblob")
            theBlob = container?.blockBlobReference(fromName: nameBlob)
            
        } catch let ex {
            
            print(ex)
        }
        
        return theBlob!
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
