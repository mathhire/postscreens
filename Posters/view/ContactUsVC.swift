//
//  ContactUsVC.swift
//  Posters
//
//  Created by Administrator on 3/6/23.
//

import UIKit
import SVProgressHUD
class ContactUsVC: UIViewController {

    @IBOutlet weak var txt_desc: UITextView!
    @IBOutlet weak var edt_subject: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        if edt_subject.text == ""{
            self.view.makeToast("Please enter the subject.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        if txt_desc.text == ""{
            self.view.makeToast("Please enter your description.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        SVProgressHUD.show()
        DataManager.shared.contact_us(subject: edt_subject.text ?? "", message: txt_desc.text){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.view.makeToast("Submitted Successfully. Thank you for your cooperation.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.view.makeToast(message)
            }
        }    }
}
