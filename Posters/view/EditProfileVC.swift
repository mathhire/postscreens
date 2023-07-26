//
//  EditProfileVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import CountryPickerView
import SVProgressHUD

class EditProfileVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    var myUniversityInfo : University!
    
    @IBOutlet weak var txt_bio: UITextView!
    @IBOutlet weak var countryPickerView: CountryPickerView!

    @IBOutlet weak var edt_age: UITextField!
    
    @IBOutlet weak var edt_grade: UITextField!
    @IBOutlet weak var edt_phone: UITextField!
    @IBOutlet weak var edt_username: UITextField!
    @IBOutlet weak var edt_lastname: UITextField!
    @IBOutlet weak var edt_firstname: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!

    @IBOutlet weak var edt_university: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        countryPickerView.showCountryNameInView = false
        countryPickerView.showCountryCodeInView = false
        countryPickerView.delegate = self
        countryPickerView.isUserInteractionEnabled = true
        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)
        countryPickerView.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14)

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_phone.attributedPlaceholder = NSAttributedString(string: edt_phone.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])

        self.showBasicData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadOtherInfo()
        self.showBasicData()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txt_bio.delegate = self
    }
    func loadOtherInfo()
    {
                SVProgressHUD.show()
        DataManager.shared.getUniversityFromID(university_id: DataManager.shared.loggedInUser().university_id){ success,universities, message in
                    SVProgressHUD.dismiss()
                    if success{
                        if universities.count > 0{
                            self.myUniversityInfo = universities[0]
                            self.edt_university.text = self.myUniversityInfo.university_name
                        }
                        print("---Success")
                    }else{
                        self.view.makeToast(message)
                    }
                }
    }
    func showBasicData(){
        let user = DataManager.shared.loggedInUser()
        edt_firstname.text = user.firstname
        edt_lastname.text = user.lastname
        edt_username.text = user.username
        edt_phone.text = user.phone
//        edt_university.text = user.uni
        edt_grade.text = "Class of \(user.grade)"
        txt_bio.text = user.bio
        edt_age.text = user.age
        profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (user.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))

    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gotoEditUniversity(_ sender: Any) {
        
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Are you sure you want to update your university?", message: "You will be removed from any groups that you are currently affiliated with at your school.", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes, I am sure.", style: .default) { (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPUniveresityVC") as! CPUniveresityVC
            vc.hidesBottomBarWhenPushed = true
            vc.isOpeningFromEditProfile = true
            vc.selectedUniversity = self.myUniversityInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)

    }
    
    @IBAction func gotoEditGrade(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPGradeVC") as! CPGradeVC
        vc.hidesBottomBarWhenPushed = true
        vc.isOpeningFromEditProfile = true
        vc.selectedGrade = DataManager.shared.loggedInUser().grade
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func nextBtnTapped(_ sender: Any) {
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
        if edt_username.text == ""{
            self.view.makeToast("Please enter your username.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        if edt_phone.text == ""{
            self.view.makeToast("Please enter your phone number.", duration: 3.0, position: .center, title: nil, image: nil, style: .init()) { didTap in
            }
            return
        }
        let country_code = countryPickerView.selectedCountry.phoneCode.replacingOccurrences(of: "+", with: "")

        SVProgressHUD.show()
        DataManager.shared.edit_profile(firstname: edt_firstname.text ?? "", lastname: edt_lastname.text ?? "", phone: edt_phone.text ?? "", country_code: country_code, username: edt_username.text ?? "", age: edt_age.text!, bio:txt_bio.text){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.view.makeToast("Updated successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.view.makeToast(message)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
   
                // get the current text, or use an empty string if that failed
           let currentText = textView.text ?? ""

           // attempt to read the range they are trying to change, or exit if we can't
           guard let stringRange = Range(range, in: currentText) else { return false }

           // add their new text to the existing text
           let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

           // make sure the result is under 16 characters
           return updatedText.count <= 100
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
        if let image = info[.editedImage] as? UIImage {
            profilePhotoImageView.image = image
            }
        else{
            profilePhotoImageView.image = info[.originalImage] as? UIImage
        }
        self.editProfilePhotoAPI()
    }
    func editProfilePhotoAPI(){
        var profilePhotoImage = profilePhotoImageView.image
        profilePhotoImage = resizeImage(image: profilePhotoImage!, targetSize: CGSize(width: 800, height: 800))
        
        SVProgressHUD.show()
        DataManager.shared.updateProfilePhoto(image: profilePhotoImage!){ success in
            SVProgressHUD.dismiss()
            if success{
                self.view.makeToast("Updated successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }
            }else{
                self.view.makeToast("Sorry. Something went wrong.")
            }
        }
    }
}
extension EditProfileVC : CountryPickerViewDelegate{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.navigationController?.isNavigationBarHidden = true
        countryPickerView.countryDetailsLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: 14.0)

    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didShow viewController: CountryPickerViewController) {
        //viewController.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
}
