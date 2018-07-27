//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        // Auth->class, auth()->object, createUser()->method, completion kısmında enter yapıp farklı bir şey yaptık. Araştır bu kısmı.
        // Firebase tarafından geri dönülen Alt kısmın ilk parametresi Authentication sonucunudur, ikincisi ise Error dur.
        // "in" keyword ünü gördüğümüzde muhtemelen bir closure başlatıyoruzdur.
        // Dikkat edilirse giriş parametresi olarak createUser() metodunu almış bir clouser bu.
        // Dikkat: user işlemleri arka planda zaman alıyor ve tamamlandığında closure kısmı devreye giriyor. bunun sonucuna göre segue işlemi gerçekleşiyor veya hata veriyor. 
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil{
                print(error!)
            }else{
                // success
                print("kayıt başarılı oldu.")
                
                SVProgressHUD.dismiss()
                
                // başarılı olursa chat ekranına gönderiyoruz.
                // çok önemli: Self yani bu RegisterViewController ı gönderiyoruz
                // performSegue methodunun başına self yazmadan hata alıyoruz. Bunun nedeni closure içine yazdığımız bir methodun nerde gerçekleşeceğini belirtmediğimizdir. Bu yüzden methodun başına "self" komutunu ekliyoruz(yani RegistrationViewController sınıfında)
                // çıkarım: bir closure içinde bir method kullanılacaksa mutlaka "self" komutu başa getirilmelidir.
                self.performSegue(withIdentifier: "goToChat", sender: self)
                
            }
        }
        
        //TODO: Set up a new user on our Firbase database
        
        

        
        
    } 
    
    
}
