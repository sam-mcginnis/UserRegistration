//
//  ViewController.swift
//  UserRegistration
//
//  Created by Sam Mcginnis on 8/14/20.
//  Copyright © 2020 Gozy Mobile Solutions. All rights reserved.
//
import UIKit
import GoogleSignIn
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class ViewController: UIViewController {

   
    
    @IBOutlet weak var UsernameTF: UITextField!
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var RegisterBtn: UIButton!
    @IBOutlet weak var FacebookBtn: UIButton!
    @IBOutlet weak var GoogleBtn: GIDSignInButton!
    override func viewDidLoad() {
super.viewDidLoad()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.UsernameTF.frame.height))
UsernameTF.leftView = paddingView
        UsernameTF.leftViewMode = UITextField.ViewMode.always

        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.EmailTF.frame.height))
        EmailTF.leftView = paddingView1
                EmailTF.leftViewMode =
                    UITextField.ViewMode.always

        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.PasswordTF.frame.height))
        PasswordTF.leftView = paddingView2
                PasswordTF.leftViewMode = UITextField.ViewMode.always

          errorLabel.alpha = 0

        GIDSignIn.sharedInstance()?.presentingViewController = self
}
    func showError(_ message:String) {
           
           errorLabel.text = message
           errorLabel.alpha = 1
       }
       
    func isPasswordValid(_ password : String) -> Bool {
           
           let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
           return passwordTest.evaluate(with: password)
       }
       
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if UsernameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            EmailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            PasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = PasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    @IBAction func RigesterTapped(_ sender: Any) {
               // Validate the fields
     let error = validateFields()
     
     if error != nil {
         
         // There's something wrong with the fields, show error message
         showError(error!)
     }
     else {
         
         // Create cleaned versions of the data
         let firstName = UsernameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         let email = EmailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         let password = PasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         
         // Create the user
         Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
             
             // Check for errors
             if err != nil {
                 
                 // There was an error creating the user
                 self.showError("Error creating user")
             }
             else {
                 
                 // User was created successfully, now store the first name and last name
                let db = Firestore.firestore()
                 
                 db.collection("users").addDocument(data: ["Username":firstName, "uid": result!.user.uid ]) { (error) in
                     
                     if error != nil {
                         // Show error message
                         self.showError("Error saving user data")
                       
                     }
                    self.errorLabel.textColor = UIColor(red: 0, green: 1.00, blue: 0, alpha: 1.00)
                                           self.showError("You have succesfully created your profile!")
                    
                 }
                 
             }
             
         }
         
         
         
     }
    }
    
    @IBAction func FBtapped(_ sender: Any) {
        fbLogin()
    }
    
    func fbLogin() {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions:[ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            
            switch loginResult {
            
            case .failed(let error):
                //HUD.hide()
                print(error)
            
            case .cancelled:
                //HUD.hide()
                print("User cancelled login process.")
            
            case .success( _, _, _):
                print("Logged in!")
                self.getFBUserData()
            }
        }
    }
    
    func getFBUserData() {
        //which if my function to get facebook user details
        
        if((AccessToken.current) != nil){
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    let dict = result as! [String : AnyObject]
                    print(result!)
                    print(dict)
                    let picutreDic = dict as NSDictionary
                    let tmpURL1 = picutreDic.object(forKey: "picture") as! NSDictionary
                    let tmpURL2 = tmpURL1.object(forKey: "data") as! NSDictionary
                    _ = tmpURL2.object(forKey: "url") as! String
                    
                    let nameOfUser = picutreDic.object(forKey: "name") as! String
                    self.UsernameTF.text = nameOfUser
                    
                    var tmpEmailAdd = ""
                    if let emailAddress = picutreDic.object(forKey: "email") {
                        tmpEmailAdd = emailAddress as! String
                        self.EmailTF.text = tmpEmailAdd
                    }
                    else {
                        var usrName = nameOfUser
                        usrName = usrName.replacingOccurrences(of: " ", with: "")
                        tmpEmailAdd = usrName+"@facebook.com"
                    }
                    
                   
                }
                
                print(error?.localizedDescription as Any)
            })
        }
    }
}
