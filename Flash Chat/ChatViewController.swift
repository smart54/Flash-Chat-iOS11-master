//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import SVProgressHUD

// İki protokol conform ediyoruz.(UITableViewDelegate, UITableViewDataSource)
// Bu protokolleri belirtmek ile derleyiciye ChatViewController sınıfının TableView in delegata i olduğunu belirtiyoruz. Yani TableView de gerçekleşen her olayda ChatViewController yetkilendiriliyor(delegate ediliyor)
// diğer belirtilen protokolde(UITableViewDataSource) compiler a tableView deki datalardan da bu sınıf(ChatViewController) sorumludur ya da yetkilendirilmiştir diyoruz.

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    // model kısmında belirttiğimiz sender ve messageBody değişkenlerini tutması için "Message" objesi oluşturuyoruz. Array olarak aşağıdaki şekildeki gibi tanımlanır. eşitliğin sağ tarafı empty objedir.
    var messageArray : [Message] = [Message]()
   
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
 
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        //TODO: Set the tapGesture here:
        
        
        // tableViewTapped metodu aşağıda bu satır yazıldıktan sonra tanımlanacak.
        // tap gesture hafifçe dokunma anlamına geliyor.
        // herhangi bir tap gesture(hafif dokunma) yapıldığında bu selector içinde belirtilen "tableViewTapped" metodunu çağırır.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        // Message.xib file ı buraya kaydediyoruz. UINib ile xib dosyası kastediliyor. bu durumda xib dosyası MessageCell... identifier ise cell in kendi identifier i...
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
        
        // chat ekranındaki seperator çizgilerinden kurtulmak için aşağıdaki kodu yazıyoruz.
        messageTableView.separatorStyle = .none
        
    }

    //MARK: - TableView DataSource Methods
    //TODO: Declare cellForRowAtIndexPath here:
    // default cell formatı düz beyaz olduğu için tercih edilmeyecek. bunun yerine sol frame de "Custom Cell" klasöründe bir format belirliyoruz. bu cell in yapısında imageview ve
    // custom Cell deki messageCell e bir identifier veriliyor. bu çok önemli
    // bu MessabeCell.xib CustomMessageCell.swift ile bağlantılıdır.(sağ tarafta custom class kısmında)
    // CustomMessageCell.swift bu cell içindekiler ile ilgilenir.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // customMessageCell xib dosyasındaki cell in identifier ı ve indexPath ise ekrandaki her bir row u belirtir.
        // as! öncesinde oluşturduğumuz obje CustomMessageCell in objesidir diye belirtiyoruz compiler a.
        // ilk satırda cell i dizayn ettik. sonrasında messageBody ye bir kaç text ekledik
        // bu message tableView içindeki herbir satır için çağrılır.
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        // şu anki kullanıcı ise flatMint() ve flatSkyBlue() yap aksi takdirde else bloğunu icra et
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }else{
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //3 satıra sahip olduğumuz için 3 yazdık.
        return messageArray.count
    }
    
    @objc func tableViewTapped(){
        // true olduğunda aşağıdaki "textFieldDidEndEditing" metodunu çağırır.
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare tableViewTapped here:
    //TODO: Declare configureTableView here:
    func configureTableView(){
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //TODO: Send the message to Firebase and save it in our database
        // send butonuna basıldıktan sonra aşağıya doğru inecek
        messageTextfield.endEditing(true)
        
        // textfield ve send butonları da disable yapıyoruz.
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // yeni bir child database oluşturuyoruz ve ismini "Messages" koyuyoruz.
        let messageDB = Database.database().reference().child("Messages")
        // veri tipi dictionary tarzında oluyor.
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        
        // childByAutoId() messageDictionary için random id ataması yapıyor.
        // trailing closer a sahiptir bu satır.
        messageDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            
            if error != nil{
                print(error!)
            }else{
                print("Mesaj başarıyla kaydedildi.")
                // mesaj başarıyla kaydedildikten sonra metin alanı ve send butonunu tekrardan aktive ediyoruz. closure içinde kullandığımız için mutlaka self komutunu başa ekliyoruz.
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages(){
        // sender da oluşturduğumuz şekilde refere ediyoruz. "Messages" kısmının aynı olması önemli
        let messageDB = Database.database().reference().child("Messages")
        // observe komutu ile herhangi bir database e herhangi bir child eklendiğinde diğer parametre(snapshot) clouser şeklinde olur.
        // database e yeni bir child eklenir eklenmez bu metod bir snapshot dönüyor.(eklenen verinin fotosu gibi bir şey.yani bütün özelliklerini kapsıyor)
       
        messageDB.observe(.childAdded, with: { (snapshot) in
            
            // veriyi dictionary türünde(as! dictionary) çekiyoruz. Yukarıda zaten dictionary türünde tanımlamıştık.
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            // Model kısmında belirtilen Message objesi oluşturuluyor
            // bu objenin değişkenlerine snapshot ile alınan değerler atanıyor.
            let message = Message()
        
            message.messageBody = text
            message.sender = sender
            
            // değer alan message objesi messageArray a ekleniyor.
            // closure içinde kullanılan metodlar için self komutu kullanıyoruz.
            self.messageArray.append(message)
            // bu neden konuldu? Araştır.
            self.configureTableView()
            // database e her veri eklediğimizde "observe" ile belirtilen "event" i tetikliyoruz. bunun neticesinde closure çağrılıyor ve tableView e data yı reload yapıyoruz.
            
            self.messageTableView.reloadData()
        })
        
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        
        //TODO: Log out the user and send them back to WelcomeViewController
        // Log out yapabilmek için Firebase in signOut() metodunu kullanacağız
        // Dikkat: SignOut otomatik tamamlamada çıkarken throw kelimesini görüyoruz veya yazıldıktan sonra bir hata hata alıyoruz. Hata alabilme ihtimaline karşın  try/catch bloklarını kullanmamız gerekiyor.
        SVProgressHUD.show()

        do {
            try Auth.auth().signOut()
            // tekrardan login ekranına geri götürüyor
            navigationController?.popToRootViewController(animated: true)
            
            SVProgressHUD.dismiss()

        }
        catch{
            print("Bilinmeyen bir hata meydana geldi")
        }
        
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods

    
    //TODO: Declare textFieldDidBeginEditing here:
    // kullanıcı chat ekranındaki textfield kısmına bir şey gireceği zaman tetiklenir bu delegate methodu.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        // animate metodunda trailing closure kullanıyoruz. animate parametresi gidiyor.
        // closure içinde kullanıldığı için aşağıda kullanılan herbir metodun başına self komutu getirilmesi gerekiyor.
        // 0.5 saniyede animasyon tamamlanıyor.
        UIView.animate(withDuration: 0.5){
            // bu satırla anime ediyoruz textfield i
            // fakat aşağıdaki layout metodu bütün viewleri update eder.
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
        
    }
 
    
    //TODO: Declare textFieldDidEndEditing here:
   // metod çağrıldığına muhtemelen bir tap gesture yani hafif parmak vuruşuyla çağrıldığında text field animasyonla eski durumuna tekrardan gelir.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        
    }
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
   
}
