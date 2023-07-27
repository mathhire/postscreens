//
//  SettingsVC.swift
//  Posters
//
//  Created by Administrator on 3/3/23.
//

import UIKit
import SVProgressHUD
import BranchSDK
class SettingsVC: UIViewController {

    @IBOutlet weak var switchPush: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        if DataManager.shared.loggedInUser().push_enabled == "1"{
            switchPush.isOn = true
        }
        else{
            switchPush.isOn = false
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchPushChanged(_ sender: Any) {
        var status = "0"
        if switchPush.isOn{
            status = "1"
        }
        SVProgressHUD.show()
        DataManager.shared.edit_push_setting(status: status){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.view.makeToast("Updated successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }
            }else{
                self.view.makeToast(message)
                self.switchPush.isOn = !self.switchPush.isOn
            }
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        DataManager.shared.clear()
        Branch.getInstance().logout()
        self.dismiss(animated: true)
    }
    
    @IBAction func editProfleBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func gotoSocial(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPSocialVC") as! CPSocialVC
        vc.isFromSetting = true
        vc.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func gotoContactUs(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func openTerms(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://postersglobal.com/terms-of-service.html")!)

    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://postersglobal.com/privacy-policy.html")!)

    }
    
    @IBAction func deleteAccountBtnTapped(_ sender: Any) {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Are you sure you want to delete your account?", message: "This action can not be undone.", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes, I am sure.", style: .destructive) { (action) in
            self.callDeleteAPI()
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)

    }
    func callDeleteAPI(){
        SVProgressHUD.show()
        DataManager.shared.delete_user(){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.view.makeToast("Deleted your account successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                    DataManager.shared.clear()
                    self.dismiss(animated: true)
                }
            }else{
                self.view.makeToast(message)
            }
        }
    }
}
