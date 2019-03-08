//
//  ViewController.swift
//  BraintreeMySample
//
//  Created by JaonMicle on 6/4/18.
//  Copyright © 2018 customeruber. All rights reserved.
//



import UIKit
import BraintreeDropIn
import Braintree

class DropInUIViewController: UIViewController {
    
    @IBOutlet weak var resultText: UITextView!
    
    public var clientTokenOrTokenizationKey: String!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tokenization key (Braintree account from braintree account (setting/api keys))
        self.clientTokenOrTokenizationKey = "sandbox_j8fjy3y6_pq75z4rjvbfqq7dk";
        // get Client token from server.
        self.fetchClientToken();
    }

    
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        
        // this url is sample url of backend that braintree provide.
        // this url must change to your server url.
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            self.clientTokenOrTokenizationKey = String(data: data!, encoding: String.Encoding.utf8)
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }

    @IBAction func dropInAction(_ sender: UIButton) {
        self.showDropIn(clientTokenOrTokenizationKey: "sandbox_j8fjy3y6_pq75z4rjvbfqq7dk");
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print(error?.localizedDescription ?? "");
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                print(result.paymentOptionType.rawValue);
                print(result.paymentMethod?.nonce ?? "");
                print(result.paymentIcon);
                print(result.paymentDescription);
                self.resultText.text = "You get nonce. You must send it to your server \r\n \(result.paymentMethod?.nonce ?? "")"
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
}

