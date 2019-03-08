//
//  CheckOutViewController.swift
//  BraintreeMySample
//
//  Created by JaonMicle on 6/4/18.
//  Copyright © 2018 customeruber. All rights reserved.
//

import UIKit
import Braintree

class PaypalViewController: UIViewController {
    
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    public var clientTokenOrTokenizationKey: String!
    var braintreeClient: BTAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator.isHidden = true;
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
    
    @IBAction func vaultAction(_ sender: UIButton) {
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        self.startIndicator();
        payPalDriver.authorizeAccount() { (tokenizedPayPalAccount, error) -> Void in
            self.stopIndicator();
            print(tokenizedPayPalAccount?.billingAddress ?? "");
            print(tokenizedPayPalAccount?.clientMetadataId ?? "");
            print(tokenizedPayPalAccount.debugDescription);
            print(tokenizedPayPalAccount?.email ?? "");
            print(tokenizedPayPalAccount?.firstName ?? "");
            print(tokenizedPayPalAccount?.lastName ?? "");
            print(tokenizedPayPalAccount?.phone ?? "");
            print(tokenizedPayPalAccount?.shippingAddress ?? "");
            print(tokenizedPayPalAccount?.nonce ?? "")
            self.resultText.text = "nonce: \(tokenizedPayPalAccount?.nonce ?? "")";
        }
    }
    
    @IBAction func checkOutAction(_ sender: UIButton) {
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        let payPalRequest = BTPayPalRequest(amount: "1.00")
        self.startIndicator();
        payPalDriver.requestOneTimePayment(payPalRequest) { (tokenizedPayPalAccount, error) -> Void in
            self.stopIndicator();
            print(tokenizedPayPalAccount?.billingAddress ?? "");
            print(tokenizedPayPalAccount?.clientMetadataId ?? "");
            print(tokenizedPayPalAccount.debugDescription);
            print(tokenizedPayPalAccount?.email ?? "");
            print(tokenizedPayPalAccount?.firstName ?? "");
            print(tokenizedPayPalAccount?.lastName ?? "");
            print(tokenizedPayPalAccount?.phone ?? "");
            print(tokenizedPayPalAccount?.shippingAddress ?? "");
            print(tokenizedPayPalAccount?.nonce ?? "")
            self.resultText.text = "nonce: \(tokenizedPayPalAccount?.nonce ?? "")";
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

extension PaypalViewController: BTViewControllerPresentingDelegate, BTAppSwitchDelegate{
    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - BTAppSwitchDelegate
    
    
    // Optional - display and hide loading indicator UI
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    // MARK: - Private methods
    
    func showLoadingUI() {
        self.startIndicator();
    }
    
    @objc func hideLoadingUI() {
        NotificationCenter
            .default
            .removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.stopIndicator();
    }
}
