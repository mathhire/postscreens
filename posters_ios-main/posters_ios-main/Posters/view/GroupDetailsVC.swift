//
//  GroupDetailsVC.swift
//  Posters
//
//  Created by Administrator on 3/2/23.
//

import UIKit
import SVProgressHUD
class GroupDetailsVC: UIViewController {

    @IBOutlet weak var lbl_num_total_follower: UILabel!
    @IBOutlet weak var groupPhotoImageView: UIImageView!
    @IBOutlet weak var lbl_num_members: UILabel!
    @IBOutlet weak var lbl_group_title: UILabel!
    @IBOutlet weak var btn_leave_group: UIButton!
    @IBOutlet weak var btn_join: UIButton!
    @IBOutlet weak var tblGroupMember: UITableView!
    @IBOutlet weak var listHeight: NSLayoutConstraint!
    var membersArray = [User]()
    var joinedToThisGroup = false
    var groupDict : Group!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(groupDict != nil)
        {
            lbl_group_title.text = groupDict.group_name
            lbl_num_members.text = "\(groupDict.num_members) members"
            groupPhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (groupDict.group_photo ))!,placeholderImage: UIImage(named: "img_group_placeholder"))
            self.loadData()
            
        }
//        listHeight.constant = 10 * 62.0
    }
    func loadData()
    {
        SVProgressHUD.show()
        DataManager.shared.getGroupDetails(group_id: groupDict.id){ success,data,num_total_follower, message in
                    SVProgressHUD.dismiss()
                    if success{
                        self.membersArray = data

                    }else{
                        self.membersArray = [User]()
//                        self.view.makeToast(message)
                    }
//            self.lbl
            self.lbl_num_total_follower.text = "Collective Following: \(getSimpliedCountString(num_total_follower))"
            self.listHeight.constant = CGFloat(self.membersArray.count) * 62.0
            self.tblGroupMember.reloadData()
            self.updateJoinBtnUI()
        }
    }
    func updateJoinBtnUI(){
        if self.groupDict.university_id == myUniversity.id
        {
            self.joinedToThisGroup = false
            for index in 0 ..< self.membersArray.count{
                let oneMember = self.membersArray[index]
                if oneMember.id == DataManager.shared.loggedInUser().id{
                    self.joinedToThisGroup = true
                    break
                }
            }
            if self.joinedToThisGroup
            {
                self.btn_join.isHidden = true
                self.btn_leave_group.isHidden = false
            }
            else{
                self.btn_join.isHidden = false
                self.btn_leave_group.isHidden = true

            }
        }
        else{
            self.btn_join.isHidden = true
            self.btn_leave_group.isHidden = true

        }
    }
    @IBAction func joinBtnTapped(_ sender: Any) {
        SVProgressHUD.show()
        DataManager.shared.joinGroup(group_id: groupDict.id){ success, message in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                self.lbl_num_members.text = "\((Int(self.groupDict.num_members) ?? 0) + 1) members"

                self.view.makeToast("Joined Successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }

                self.loadData()

            }else{
                self.view.makeToast(message)
            }
        }


    }
    @IBAction func leaveGroupBtnTapped(_ sender: Any) {
        SVProgressHUD.show()
        DataManager.shared.leaveGroup(group_id: groupDict.id){ success, message in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                self.lbl_num_members.text = "\((Int(self.groupDict.num_members) ?? 0) - 1) members"

                self.view.makeToast("You have successfully left the group.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }

                self.loadData()

            }else{
                self.view.makeToast(message)
            }
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cellReportBtnTapped(_ sender: Any) {
        let button = sender as! UIButton
        let buttonPosition = button.convert(button.bounds.origin, to: tblGroupMember)
        if let indexPath = tblGroupMember.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            let user = membersArray[rowIndex]
            let opp_id = user.id
            let group_id = self.groupDict.id
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
            vc.oppID = opp_id
            vc.relatedGroupID = group_id
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    

}

//MARK: TableView Delegate
extension GroupDetailsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        return membersArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 62.0
//        return UITableView.automaticDimension

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblGroupMember{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
            if indexPath.row < self.membersArray.count{
                let user = membersArray[indexPath.row]
                cell.lbl_username.text = "@\(user.username)"
                cell.lbl_name.text = "\(user.firstname) \(user.lastname)"
                cell.profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (user.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))

                if joinedToThisGroup && user.id != DataManager.shared.loggedInUser().id{
                    cell.btn_report.isHidden = false
                }
                else{
                    cell.btn_report.isHidden = true
                }
            }
            return cell
        }
        return UITableViewCell.init()

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if indexPath.row < membersArray.count{
            let user = membersArray[indexPath.row]
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

class GroupMemberCell : UITableViewCell{
    
    @IBOutlet weak var btn_report: UIButton!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
}
