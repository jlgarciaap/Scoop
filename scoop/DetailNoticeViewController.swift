//
//  DetailNoticeViewController.swift
//  scoop
//
//  Created by Juan Luis Garcia on 29/10/16.
//  Copyright © 2016 styleapps. All rights reserved.
//

import UIKit

//typealias Data = Dictionary<String, AnyObject>


class DetailNoticeViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
     var client : MSClient?
     var model : Data? 

    //Nos bajamos la imagen de grande
    @IBOutlet weak var detailImgView: UIImageView! {
        
        didSet{
            
            let sas = "?sv=2015-04-05&ss=bfqt&srt=sco&sp=rwdlacup&se=2016-11-30T18:36:30Z&st=2016-10-30T10:36:30Z&spr=https,http&sig=J69W2cXLEiqISWNyfpLMsWOCz6uxo0EI2HLThHlem1U%3D"
            
            let credentials = AZSStorageCredentials(sasToken: sas, accountName: "styleappsstorage")
            do {
                let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
                let client = account.getBlobClient()
                let container = client?.containerReference(fromName: "noticesblob")
                
              
                guard let imageBlobName = model?["photoNameMax"] as? String else {
                    
                    return
                    
                }
                
            let blobSelected = container?.blockBlobReference(fromName: imageBlobName)
            
           blobSelected?.downloadToData(completionHandler: { (error, data) in
            
        
            if let _ = data{
        
                DispatchQueue.main.async {
                     self.detailImgView.image = UIImage(data: data!)
                }
            }})
            
            }catch let ex {
                
                print(ex)
            }
        }
    }
    
    /* ----Botones y datos necesarios para el rating-----*/
    @IBOutlet weak var actualRate: UILabel!{
        didSet{
            
            if ((model?["rating"]) != nil){
            guard let detailRate = model?["rating"] as? String else {
                return
            }
            
            self.actualRate.text = detailRate + "/5"
            } else{
        
                self.actualRate.text = "Sin Valorar"
            }
        }
    }
    
    @IBOutlet weak var pickerRating: UIPickerView!
    
    let pickerData = ["1","2","3","4","5"]
    
    var noticeRated = false
    var rateSelected : String?
    
    /* ----------------------------------------*/
    
    @IBOutlet weak var detailTitleLbl: UILabel!{
        
        didSet{
            
            guard let detailTitle = model?["title"] as? String else {
                return
            }
            
            self.detailTitleLbl.text = detailTitle
            
        }
        
    }
    
    @IBOutlet weak var detailNoticeTxtView: UITextView!{
        
        didSet{
            
            guard let detailNotice = model?["noticeText"] as? String else {
                return
            }
            
            self.detailNoticeTxtView.text = detailNotice
            
        }
        
    }

    
    @IBOutlet weak var detailAuthorLbl: UILabel!{
        
        didSet{
            
            guard let detailAuthor = model?["authors"] as? String else {
                return
            }
            
            self.detailAuthorLbl.text = detailAuthor
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerRating.dataSource = self
        pickerRating.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //Si has modificado el rating actualizamos si no no
        if noticeRated == true{
            updateNotice()
        }
        super.viewDidDisappear(true)
        
    }

    @IBAction func loginButton(_ sender: AnyObject) {
        
        //Si quieres modificar, logarte tu debes
        client?.login(withProvider: "google", parameters: nil, controller: self, animated: true) { (user, error) in
            
            if let _ = error{
                print(error)
                return
            }
            
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        //Mismo concepto, si no estas identificado no puedes tocar
        if segue.identifier == "editNoticeSegue" && client?.currentUser == nil{
            
            let alert = UIAlertController(title: "Falta Login", message: "Para avanzar en tu dominio de la fuerza debes identificarte", preferredStyle: .alert)
            
            let actionOk = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(actionOk)
            
            
            present(alert, animated: true, completion: nil)
            //return
            
        } else if segue.identifier == "editNoticeSegue" && client?.currentUser != nil {
            
            let vc = segue.destination as? EditNoticeViewController
            vc?.client = client
            vc?.model = model
        }

        
        
    }
    
    //MARK: - AUX Functions
    
    func updateNotice() {
        
        //Conexion a la tabla
        let tableMS = client?.table(withName: "Notices")
        
        var result = 0
        
        if noticeRated == true && self.actualRate.text != "Sin Valorar" && self.actualRate.text != "result"{
            
            let originNumber = Int(model?["rating"]! as! String)
            let newNumber = Int(rateSelected!)
            result = (originNumber! + newNumber!)/2
        
        } else{
            
            result = Int(rateSelected!)!
        }
        
        if var finalState = model {
            
            finalState["rating"] = result as AnyObject?
          
            tableMS?.update(finalState, completion: {(result, error) in
                
                if let _ = error {
                    
                    print(error)
                    return
                }
            })
        }
    
    }
    // MARK: - Delegates y data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        noticeRated = true
        rateSelected = pickerData[row]
    }
    
    
}
