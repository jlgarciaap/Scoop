//
//  AnonymousTableViewController.swift
//  scoop
//
//  Created by Juan Luis Garcia on 29/10/16.
//  Copyright © 2016 styleapps. All rights reserved.
//

import UIKit

typealias Data = Dictionary<String, AnyObject>

class AnonymousTableViewController: UITableViewController {
    
    //Conexion con azure
    var client: MSClient = MSClient(applicationURL: URL(string: "https://labsmbaas.azurewebsites.net")!)
    var model: [Data]? = []
    
    //Blob
    var blobModel: [AZSCloudBlockBlob] = []
    var container: AZSCloudBlobContainer?
    var clientContainer:  AZSCloudBlobClient?
    let sas = "?sv=2015-04-05&ss=bfqt&srt=sco&sp=rwdlacup&se=2016-11-30T18:36:30Z&st=2016-10-30T10:36:30Z&spr=https,http&sig=J69W2cXLEiqISWNyfpLMsWOCz6uxo0EI2HLThHlem1U%3D"

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.readAllData()
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Buttons
    
    @IBAction func loginButton(_ sender: AnyObject) {
        
        //Realizamos el login con google
        client.login(withProvider: "google", parameters: nil, controller: self, animated: true) { (user, error) in
            
            if let _ = error{
                print(error)
                return
            }
        }
    }
    
    
    // MARK: - Azure Functions
    func readAllData(){
        
        let tableMS = client.table(withName: "Notices")
        //Si no esta vacia borrala que si no nos duplica
        if !(self.model?.isEmpty)! {
            
            self.model?.removeAll()
        }
        
        tableMS.read(){ (results, error) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if let items = results {
                
                for item in items.items!{
                    
                    self.model?.append(item as! [String: AnyObject])
                }
            
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (model?.isEmpty)!{
            
            return 0
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (model?.isEmpty)!{
            
            return 0
        }
        
        return(model?.count)!

    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        
        //Configuramos la celda con los datos que obtenemos
        
        let notice = model?[indexPath.row]
        
        let imageString = notice?["photoNameMin"] as! String
    
        let blobSelected = obtainBlob(imageString)
        
        cell.authorCellTxtLbl.text = notice?["authors"] as! String
        cell.titleCellTxtLbl.text = notice?["title"] as! String
        
        //Nos bajamos las imagenes pequeñas
        blobSelected.downloadToData { (error, data) in
            
            if let _ = error{
                
                print(error)
                return
            }
            
            if let _ = data {
                
                let img = UIImage(data: data!)
              
                DispatchQueue.main.async {
                    
                    cell.imageViewCell.image = img
            
                }
            }
        }
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notice = model?[indexPath.row]
        
        performSegue(withIdentifier: "detail", sender: notice)
        
    }

   // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        //Si quieres añadir algo y no estas logado no puedes
        if segue.identifier == "addNoticeSegue" && client.currentUser == nil{
            
            let alert = UIAlertController(title: "Falta Login", message: "Para avanzar en tu dominio de la fuerza debes identificarte", preferredStyle: .alert)
            
            let actionOk = UIAlertAction(title: "OK", style: .default)
            alert.addAction(actionOk)
            
             present(alert, animated: true, completion: nil)
            
           //Una vez identificado ya podemos trabajar
        } else if segue.identifier == "addNoticeSegue" && client.currentUser != nil {
        
            let vc = segue.destination as? AddNoticeViewController
            vc?.client = client

        }
        
        if segue.identifier == "detail" {
            
            let vc = segue.destination as? DetailNoticeViewController
            
            vc?.client = client
            vc?.model =  sender as? Data
            
        }
    }
    
    //MARK: - Aux
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


}
