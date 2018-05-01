//
//  LoginPopupViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/16/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class LoginPopupViewController: DelegatedViewController
{
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewWillAppear(_ animated: Bool)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"override func viewWillAppear(")
        delegate.validateSocket(rebuildSocket: false)
        if self.navigationController != nil
        {
            self.navigationController!.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        print("\n", self.classForCoder, Thread.current, "\n\n"+"override func viewWillDisappear(")
        if self.navigationController != nil
        {
            self.navigationController!.isNavigationBarHidden = false
        }
    }
    
    @IBAction func unwindToLoginPopupView(sender:UIStoryboardSegue)
    {
        
    }
    
    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"IBAction func passwordTextFieldPrimaryActionTriggered(")
        self.loginButtonTapped(sender)
    }
    @IBAction func loginButtonTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"@IBAction func loginButtonTapped")
        let user = self.usernameTextField.text!
        let pass = self.passwordTextField.text!
        self.delegate.username = user
        self.delegate.password = pass
        self.getUserToken(user: user, pass: PairedPhrase.encodePass(pass: pass) )
    }
    
    @IBAction func newUserButtonTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"@IBAction func newUserButtonTapped(")
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        nextViewController.emitAsNewUser = true
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
    func getUserToken(user:String, pass:String)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func getUserToken)")
        guard let uploadData = try? JSONEncoder().encode(UserPassRequest(user:user, pass:pass)) else
        {
            return
        }
        //print(self.delegate.socket)
        //print([uploadData])
        self.delegate.socket.emit("user_pass_req", with: [uploadData])
        //print("event emitted")
        
//        //print("***Entered token get")
//        struct UserPass:Codable
//        {
//            let username:String
//            let password:String
//        }
//        let userPass = UserPass(username:user, password:pass)
//        guard let uploadData = try? JSONEncoder().encode(userPass) else
//        {
//            //print("***token data GET failed***")
//            return
//        }
//        let url = URL(string: "http://localhost:3000/user")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let task = URLSession.shared.uploadTask(with: request, from: uploadData)
//        {
//            data, response, error in
//
//            self.clientLock.lock()
//            //print("user token got lock")
//            defer
//            {
//                //print("user token releasing lock")
//                self.clientLock.unlock()
//                DispatchQueue.main.async {
//                    mainThreadCompletionHandler()
//                    //print("CHECK TRIGGERED")
//                }
//            }
//            //print(response ?? "Empty Response!")
//            //print("***Response above")
//            //print(data ?? "Empty Data!")
//            //print("***Data above")
//
//            guard let data = data else { return }//if data can't be assigned, exit.
//
//
//            do
//            {
//                let token = try JSONDecoder().decode(Token.self, from: data)//grab data from server
//                self.token = token.token
//                //print("Token is:"+self.token!)
//
//            }
//            catch let jsonErr
//            {
//                print ("error: ", jsonErr)
//            }
//
//            if let error = error
//            {
//                print ("error: \(error)")
//                return
//            }
//            guard let response = response as? HTTPURLResponse,
//                (200...299).contains(response.statusCode)
//                else
//            {
//                print ("server error")
//                return
//            }
//            if let mimeType = response.mimeType,
//            mimeType == "application/json",
//            let dataString = String(data: data, encoding: .utf8)
//            {
//                print ("got data: \(dataString)")
//            }
//        }
//        task.resume()
//        //print("***Exited token get")
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
