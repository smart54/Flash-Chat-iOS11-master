//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func logInPressed(_ sender: AnyObject) {
        //TODO: Log in the user
        // login e basıldığı an SVProgressHUD loading indicator u gösterir.
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil{
                print(error!)
            }else
            {
                // giriş başarılı olduğunda indicator u bırak
                SVProgressHUD.dismiss()
                
                // Clouser içinde olduğumuz için başa "self" komutu yerleştiriyoruz.
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        
    }
  
}  
