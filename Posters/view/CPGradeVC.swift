//
//  CPGradeVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD
class CPGradeVC: UIViewController {
    var isOpeningFromEditProfile = false
    
    @IBOutlet weak var tblResult: UITableView!
    var selectedGrade = "2027"
    var resultArray = ["2028","2027","2026", "2025","2024"]
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        openingGradeScreen = false
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if(isOpeningFromEditProfile)
        {
            SVProgressHUD.show()
            DataManager.shared.edit_grade( grade: selectedGrade){ success, message in
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
        else{
            regGrade = selectedGrade
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPUniveresityVC") as! CPUniveresityVC
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}

//MARK: TableView Delegate
extension CPGradeVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblResult{
            return resultArray.isEmpty ? 0:resultArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.0
//        return UITableView.automaticDimension

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblResult{
            if resultArray.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
            let prediction = resultArray[indexPath.row]
            cell.lbl_name.text = "Class of \(prediction)"
            
            if prediction == selectedGrade{
                cell.btn_check.isSelected = true
            }
            else{
                cell.btn_check.isSelected = false
            }
            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < resultArray.count{
            selectedGrade = resultArray[indexPath.row]
            tblResult.reloadData()
        }
    }
}

class ModuleCell : UITableViewCell{
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    
    @IBOutlet weak var btn_check: UIButton!
}
