//
//  UserJoinedGroupsVC.swift
//  Posters
//
//  Created by Administrator on 3/3/23.
//

import UIKit

class UserJoinedGroupsVC: UIViewController {
    @IBOutlet weak var tblResult: UITableView!
    var resultArray = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
}

//MARK: TableView Delegate
extension UserJoinedGroupsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblResult{
            return resultArray.isEmpty ? 0:resultArray.count
        }
        else
        {
            return 10
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
            let group = resultArray[indexPath.row]
            cell.lbl_name.text = group.group_name
            cell.groupPhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (group.group_photo ))!,placeholderImage: UIImage(named: "img_group_placeholder"))

//                cell.joinContainerView.isHidden = false
//                if indexPath.row % 2 == 1{
//                    cell.joinedSubView.isHidden = false
//                    cell.btn_join.isHidden = true
//                }
//                else{
//                    cell.joinedSubView.isHidden = true
//                    cell.btn_join.isHidden = false
//                }
          
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
            
        }
        
    }
}
