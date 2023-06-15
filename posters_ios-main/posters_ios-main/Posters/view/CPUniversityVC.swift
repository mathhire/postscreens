//
//  CPUniveresityVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD
class CPUniveresityVC: UIViewController {

    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var tblResult: UITableView!
    
    var isOpeningFromEditProfile = false

    var selectedUniversity : University!
    var resultArray = [University]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let color = UIColor.init(named: "customTextPlaceholder")
        edt_search.attributedPlaceholder = NSAttributedString(string: edt_search.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])

        resultArray = universitiesArray

    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if selectedUniversity == nil{
            self.view.makeToast("Please select your university.")
            return
        }
        if(isOpeningFromEditProfile)
        {
            if DataManager.shared.loggedInUser().university_id != selectedUniversity.id
            {
                SVProgressHUD.show()
                DataManager.shared.edit_university( university_id: selectedUniversity.id){ success, message in
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
                self.navigationController?.popViewController(animated: true)

            }
        }
        else{
            regUniversity = selectedUniversity

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPPhoneNumberVC") as! CPPhoneNumberVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func textFieldChanged(_ sender: UITextField) {
        self.filter()
    }
    func filter()
    {
        if(edt_search.text == "")
        {
            self.resultArray = universitiesArray
        }
        else{
            self.resultArray = []
            for index in 0 ..< universitiesArray.count{
                let cardType = universitiesArray[index]
                if(cardType.university_name.lowercased().contains(edt_search.text!.lowercased()))
                {
                    self.resultArray.append(cardType)
                }
            }
        }
        tblResult.reloadData()
    }
}

//MARK: TableView Delegate
extension CPUniveresityVC : UITableViewDelegate, UITableViewDataSource{
    
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
            cell.lbl_name.text = prediction.university_name
            
            if selectedUniversity != nil && prediction.id == selectedUniversity.id{
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
            selectedUniversity = resultArray[indexPath.row]
            tblResult.reloadData()
        }
    }
}

