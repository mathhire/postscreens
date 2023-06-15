//
//  SearchVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD
import AlamofireImage

class SearchVC: UIViewController, UITextFieldDelegate {
    var isMyUniversity = true
    @IBOutlet weak var tblResult: UITableView!
    @IBOutlet weak var lbl_selected_university: UILabel!
    @IBOutlet weak var edt_search: UITextField!
    
    @IBOutlet weak var tblStudent: UITableView!
    var resultArray = [Group]()
    var usersArray = [User]()
    var firstLoadingNow = true
    var currentUniversity : University!
    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_search.attributedPlaceholder = NSAttributedString(string: edt_search.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])
        tblStudent.isHidden = true
        if myUniversity != nil{
            currentUniversity = myUniversity
            lbl_selected_university.text = myUniversity.university_name
            self.getGroups(universityDict: myUniversity)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentUniversity != nil && !firstLoadingNow{
            if edt_search.text == ""{
                self.getGroups(universityDict: currentUniversity)
            }
        }
        firstLoadingNow = false
    }
    func getGroups(universityDict: University)
    {
        SVProgressHUD.show()
        DataManager.shared.getGroupsForUniversity(university_id: universityDict.id){ success,data, message in
                    SVProgressHUD.dismiss()
                    if success{
                        self.resultArray = data
                        print("---Success")
                    }else{
//                        self.view.makeToast(message)
                    }
            self.tblResult.reloadData()
        }

    }
    @IBAction func chooseUniversityBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChooseUniversityVC") as! ChooseUniversityVC

        vc.onDoneBlock = {result in
//            if result != nil{
            self.currentUniversity = result
                self.lbl_selected_university.text = result.university_name
            if(result.id == myUniversity.id)
            {
                self.isMyUniversity = true
            }
            else{
                self.isMyUniversity = false
            }
            self.getGroups(universityDict: result)
//                self.tblResult.reloadData()
                
//            }
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func cellJoinBtnTapped(_ sender: Any) {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Are you sure you want to join this group?", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes", style: .default) { (action) in
//            self.deleteAccount()
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func textFieldEditingDidEnd(_ sender: Any) {
        self.filter()
    }
    func filter()
    {
        if(edt_search.text == "")
        {
//            self.resultArray = universitiesArray
            tblStudent.isHidden = true
            tblResult.isHidden = false
            tblResult.reloadData()

        }
        else{
            tblStudent.isHidden = false
            tblResult.isHidden = true

            SVProgressHUD.show()
            DataManager.shared.searchUser(university_id: currentUniversity.id, search_key: edt_search.text ?? ""){ success,data, message in
                        SVProgressHUD.dismiss()
                        if success{
                            self.usersArray = data

                        }else{
                            self.usersArray = [User]()
    //                        self.view.makeToast(message)
                        }
                    self.tblStudent.reloadData()

                self.tblResult.reloadData()
            }

        }
        
    }

}

//MARK: TableView Delegate
extension SearchVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblResult{
            return resultArray.isEmpty ? 0:resultArray.count
        }
        else
        {
            return usersArray.count
        }
//        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblResult
        {
            return 100.0
        }
        return 62.0
//        return UITableView.automaticDimension

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblResult{
            if resultArray.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
            if indexPath.row < resultArray.count
            {
                let prediction = resultArray[indexPath.row]
                cell.lbl_name.text = prediction.group_name
                cell.lbl_num_members.text = "\(prediction.num_members) members"
                cell.groupPhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (prediction.group_photo ))!,placeholderImage: UIImage(named: "img_group_placeholder"))
                
                let strNumTotalFollower = getSimpliedCountString(prediction.num_total_follower ?? "0")
                cell.lbl_num_all_following.text = "Collective Following: \(strNumTotalFollower)"
            }
            return cell
        }
        else if tableView == tblStudent{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
            if indexPath.row < usersArray.count{
                let user = usersArray[indexPath.row]
                cell.lbl_username.text = "@\(user.username)"
                cell.lbl_name.text = "\(user.firstname) \(user.lastname)"
                cell.profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (user.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))
                
            }
            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblResult{
            
            if indexPath.row < resultArray.count{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsVC") as! GroupDetailsVC
                vc.groupDict = resultArray[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
        else{
            let user = usersArray[indexPath.row]
            if user.id != DataManager.shared.loggedInUser().id
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.isOpeningOtherProfile = true
                vc.profileBasicInfo = user
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
        
    }
}

class GroupCell : UITableViewCell{
    @IBOutlet weak var lbl_name: UILabel!
    
    @IBOutlet weak var groupPhotoImageView: UIImageView!
    @IBOutlet weak var lbl_num_all_following: UILabel!
    @IBOutlet weak var lbl_num_members: UILabel!
    @IBOutlet weak var btn_join: UIButton!
    @IBOutlet weak var joinContainerView: UIView!
    
    @IBOutlet weak var joinedSubView: UIView!
}
class StudentCell : UITableViewCell{
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
}
