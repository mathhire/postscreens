//
//  CPAddProfileVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD
class CPAddProfileVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var edt_username: UITextField!
    @IBOutlet weak var edt_lastname: UITextField!
    @IBOutlet weak var edt_firstname: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    var photoSelected = "no"
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
        if edt_firstname.text == ""{
            self.view.makeToast("Please enter your first name.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        if edt_lastname.text == ""{
            self.view.makeToast("Please enter your last name.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        edt_username.text = edt_username.text?.replacingOccurrences(of: " ", with: "")
        if edt_username.text == ""{
            self.view.makeToast("Please enter your username.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
       
        SVProgressHUD.show()
        DataManager.shared.checkExistUserName(username: edt_username.text!){ success, message in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                self.registerAPI()

            }else{
                self.view.makeToast(message)
            }
        }


    }
    func registerAPI(){
        var profilePhotoImage = UIImage.init(named: "icon_empty")
        if photoSelected == "yes"
        {
            profilePhotoImage = profilePhotoImageView.image
            profilePhotoImage = resizeImage(image: profilePhotoImage!, targetSize: CGSize(width: 800, height: 800))
        }
        SVProgressHUD.show()
        DataManager.shared.register_user(firstname: edt_firstname.text ?? "", lastname: edt_lastname.text ?? "", phone: regPhone, country_code: regCountryCode, username: edt_username.text ?? "", age: regAge, grade: regGrade, university_id: regUniversity.id, lat: "\(regLat)", lng: "\(regLng)", image: profilePhotoImage!, photo_uploaded: photoSelected){ success, message in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPSocialVC") as! CPSocialVC
                    self.navigationController?.pushViewController(vc, animated: true)


            }else{
                self.view.makeToast(message)
            }
        }
    }
    @IBAction func addProfilePhotoBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select Photo", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { action in
            self.selectLibrary()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { action in
            self.selectCamera()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    func selectCamera() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .camera
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    func selectLibrary(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        photoSelected = "yes"
        if let image = info[.editedImage] as? UIImage {
            profilePhotoImageView.image = image
            }
        else{
            profilePhotoImageView.image = info[.originalImage] as? UIImage

        }
        }
}
