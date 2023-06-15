//
//  ViewController.swift
//  Posters
//
//  Created by Administrator on 2/26/23.
//

import UIKit
import CountryPickerView
import SVProgressHUD
import BranchSDK

class ViewController: UIViewController {
    @IBOutlet weak var countryPickerView: CountryPickerView!

    @IBOutlet weak var firstLoadingView: UIView!
    @IBOutlet weak var edt_phone: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.firstLoadingView.isHidden = false
        self.view.bringSubviewToFront(self.firstLoadingView)
        if !DataManager.shared.getEmailAndPassword().email.isEmpty {
            SVProgressHUD.show()
            DataManager.shared.login(phone: DataManager.shared.getEmailAndPassword().email, country_code: DataManager.shared.getEmailAndPassword().password){ success, message in
                SVProgressHUD.dismiss()
                if success{
                    self.showMainView()
                }else{
                    self.view.makeToast(message)
                    self.firstLoadingView.isHidden = true

                }
            }

        }
        else{
            firstLoadingView.isHidden = true
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(justVerifiedCode)
        {
            justVerifiedCode = false
            self.callLoginAPI()
            
        }
        if(justRegistered)
        {
            justRegistered = false
            self.showMainView()
        }
    }
    func initUI()
    {
        countryPickerView.showCountryNameInView = false
        countryPickerView.showCountryCodeInView = false
        countryPickerView.delegate = self
        countryPickerView.isUserInteractionEnabled = true

        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)
        countryPickerView.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14)

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_phone.attributedPlaceholder = NSAttributedString(string: edt_phone.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])
       
    }
    @IBAction func signInBtnTapped(_ sender: Any) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
//        self.navigationController?.pushViewController(vc, animated: true)
//        self.showMainView()
        if(edt_phone.text == "")
        {
            self.view.makeToast("Please enter your phone number.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return;
        }
        let country_code = countryPickerView.selectedCountry.phoneCode.replacingOccurrences(of: "+", with: "")

        SVProgressHUD.show()
        DataManager.shared.sendSMSForLogin(phone: edt_phone.text ?? "", country_code: country_code){ success, message, code in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
                vc.openingMode = "login"
                vc.sentCode = code ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
                print("---Sent Code: \(code ?? "")")
            }else{
                self.view.makeToast(message)
            }
        }
    }
    func callLoginAPI()
    {
        let country_code = countryPickerView.selectedCountry.phoneCode.replacingOccurrences(of: "+", with: "")

        SVProgressHUD.show()
        DataManager.shared.login(phone: edt_phone.text!, country_code: country_code) { success, message in
            SVProgressHUD.dismiss()
            if success{
                self.showMainView()
            }else{
                self.view.makeToast(message, duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }
                self.firstLoadingView.isHidden = true

            }
        }
    }
    @IBAction func signupBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPAgeVC") as! CPAgeVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func showMainView()
    {
        Branch.getInstance().setIdentity(DataManager.shared.loggedInUser().id)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "mainControllerSid")
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.firstLoadingView.isHidden = true
        }

    }
}

extension ViewController : CountryPickerViewDelegate{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.navigationController?.isNavigationBarHidden = true
        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)

    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didShow viewController: CountryPickerViewController) {
        //viewController.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
}
