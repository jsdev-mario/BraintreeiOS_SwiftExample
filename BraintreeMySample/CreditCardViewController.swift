//
//  CardViewController.swift
//  BraintreeMySample
//
//  Created by JaonMicle on 6/4/18.
//  Copyright © 2018 customeruber. All rights reserved.
//

import UIKit
import Braintree

class CreditCardViewController: UIViewController {
    
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var monthText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    public var clientTokenOrTokenizationKey: String!
    var braintreeClient: BTAPIClient!

    
    override func viewDidLoad() {
        self.indicator.isHidden = true;
        super.viewDidLoad()
        /**
         method one
         tokenization key (tokenization key form braintree account (setting/API keys)
         ***/
        //        self.clientTokenOrTokenizationKey = "sandbox_j8fjy3y6_pq75z4rjvbfqq7dk";
        //        self.braintreeClient = BTAPIClient(authorization: self.clientTokenOrTokenizationKey)
        
        
        /**
         method two
         get Client token from server.
         **/
        self.fetchClientToken();
    }
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        
        // this url is sample url of backend that braintree provide.
        // this url must change to your server url.
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        self.startIndicator();
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            self.stopIndicator();
            self.clientTokenOrTokenizationKey = String(data: data!, encoding: String.Encoding.utf8)
            self.braintreeClient = BTAPIClient(authorization: self.clientTokenOrTokenizationKey)
            }.resume()
    }

    @IBAction func paymentAction(_ sender: UIButton) {
        let braintreeClient = BTAPIClient(authorization: self.clientTokenOrTokenizationKey)!
        let cardClient = BTCardClient(apiClient: braintreeClient)
        let card = BTCard(number: self.numberText.text!, expirationMonth: self.monthText.text!, expirationYear: self.yearText.text!, cvv: nil)
        cardClient.tokenizeCard(card) { (tokenizedCard, error) in
            print(tokenizedCard?.nonce ?? "");
            self.resultText.text = "nonce: \(tokenizedCard?.nonce ?? "")";
            
        }
    }
    
    public func startIndicator(){
        DispatchQueue.main.async {
            self.indicator.isHidden = false;
            self.indicator.startAnimating();
        }
    }
    
    public func stopIndicator(){
        DispatchQueue.main.async {
            self.indicator.isHidden = true;
            self.indicator.stopAnimating();
        }
    }
}
