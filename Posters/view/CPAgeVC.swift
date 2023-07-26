//
//  CPAgeViewController.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD

class CPAgeVC: UIViewController {

    @IBOutlet weak var edt_age: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_age.attributedPlaceholder = NSAttributedString(string: edt_age.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])
//        SVProgressHUD.show()
        DataManager.shared.getUniversity{ success, message in
//            SVProgressHUD.dismiss()
            if success{
                print("---Success")
            }else{
                self.view.makeToast(message)
            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if edt_age.text == ""{
            self.view.makeToast("Please enter your age.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        if Int(edt_age.text ?? "0") ?? 0 < 16{
            self.view.makeToast("Sorry. You must be older than 16 to use Posters app.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        regAge = edt_age.text ?? "22"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPLocationVC") as! CPLocationVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func openTerms(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://postersglobal.com/terms-of-service.html")!)

    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://postersglobal.com/privacy-policy.html")!)

    }
    
}
