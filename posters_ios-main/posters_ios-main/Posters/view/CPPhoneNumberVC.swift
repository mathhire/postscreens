//
//  CPPhoneNumberVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import CountryPickerView
import SVProgressHUD

class CPPhoneNumberVC: UIViewController {
    @IBOutlet weak var countryPickerView: CountryPickerView!

    @IBOutlet weak var edt_phone: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerView.isUserInteractionEnabled = true

        countryPickerView.showCountryNameInView = false
        countryPickerView.showCountryCodeInView = false
        countryPickerView.delegate = self
        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)
        countryPickerView.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14)

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_phone.attributedPlaceholder = NSAttributedString(string: edt_phone.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if(justVerifiedCode)
//        {
//            justVerifiedCode = false
//
//        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if edt_phone.text == ""{
            self.view.makeToast("Please enter your phone number.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        var country_code = countryPickerView.selectedCountry.phoneCode
        country_code = country_code.replacingOccurrences(of: "+", with: "")
        regCountryCode = country_code
        regPhone = edt_phone.text ?? ""
        SVProgressHUD.show()
        DataManager.shared.sendVerifySMS(phone: edt_phone.text ?? "", country_code: country_code){ success, message, code in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
                vc.openingMode = "signup"
                vc.sentCode = code ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
                print("---Sent Code: \(code ?? "")")

            }else{
                self.view.makeToast(message)
            }
        }

    }
    
}
extension CPPhoneNumberVC : CountryPickerViewDelegate{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.navigationController?.isNavigationBarHidden = true
        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)

    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didShow viewController: CountryPickerViewController) {
        //viewController.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
}
