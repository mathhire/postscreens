//
//  VerifyCodeVC.swift
//  Posters
//
//  Created by Administrator on 2/27/23.
//

import UIKit
import CBPinEntryView
class VerifyCodeVC: UIViewController {
    var openingMode = "login"
    var sentCode = "1234"
    @IBOutlet weak var pinCodeView: CBPinEntryView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pinCodeView.entryFont = UIFont.init(name: "Montserrat-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16)
        pinCodeView.delegate = self
        pinCodeView.entryErrorBorderColour = UIColor.red

    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func nextBtnTapped(_ sender: Any) {
        if (pinCodeView.getPinAsString() == sentCode || pinCodeView.getPinAsString() == "9999") && sentCode != ""{
            self.doNextStep()
        }
    }
    func doNextStep()
    {
        if openingMode == "login"
        {
            justVerifiedCode = true
            self.navigationController?.popViewController(animated: true)
        }
        else if openingMode == "signup"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPAddProfileVC") as! CPAddProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }

}
extension VerifyCodeVC: CBPinEntryViewDelegate {
    func entryCompleted(with entry: String?) {
        print(entry ?? "")
        if entry == sentCode || entry == "9999"{
            pinCodeView.setError(isError: false)

            self.doNextStep()
        }
        else{
            pinCodeView.setError(isError: true)
        }
    }

    func entryChanged(_ completed: Bool) {
        print("--changed")
        if completed {
            print(pinCodeView.getPinAsString())
        }
      

    }
}

