//
//  HomeVC.swift
//  Posters
//
//  Created by Administrator on 2/27/23.
//

import UIKit
import SVProgressHUD
import BranchSDK
class HomeVC: UIViewController {
    @IBOutlet weak var socialTypeCollectionView: UICollectionView!
    var selectedSocialIndex = 0
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var tblResult: UITableView!
    var resultArray = [Post]()
    var isOpeningOtherUniversity = false
    var curUnivID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        if(isOpeningOtherUniversity)
        {
            btn_back.isHidden = false
            self.loadData()
        }
        else{
            self.getUniversity()
        }
        let countstr = getSimpliedCountString("1100")
        print("\(countstr)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(openPostAction), name: Notification.Name("OPENPOST"), object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(shouldOpenPostDetails)
        {
            shouldOpenPostDetails = false
            self.openPostAction()
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func openPostAction(){
        if !UserDefaults.post_id.isEmpty && !UserDefaults.social_type.isEmpty{
            SVProgressHUD.show()
            DataManager.shared.getOnePost(post_id: UserDefaults.post_id, social_type: UserDefaults.social_type){ success,data, message in
                SVProgressHUD.dismiss()
                if let onePost = data.first{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
                    vc.hidesBottomBarWhenPushed = true
                    vc.postDetails = onePost
                    self.navigationController?.pushViewController(vc, animated: true)
                  
                    UserDefaults.post_id = ""
                    UserDefaults.social_type = ""

                }
            }
        }
    }
    func initUI(){
        let cellHeight = 34.0
        let cellWidth = 120.0
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.itemSize = CGSizeMake(cellWidth, cellHeight)
        
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 60
        socialTypeCollectionView!.collectionViewLayout = layout2
        
    }
    func loadData(){
        if curUnivID == ""
        {
            return
        }
        var social_type_str = "1"
        if selectedSocialIndex == 1{
            social_type_str = "0"
        }
        else if selectedSocialIndex == 2{
            social_type_str = "2"
        }
        SVProgressHUD.show()
        DataManager.shared.getTopPosts(university_id: curUnivID, social_type: social_type_str){ success,data, message in
            SVProgressHUD.dismiss()
            if success{
                self.resultArray = data
                print("---Success")
            }else{
                self.resultArray.removeAll()
                //                        self.view.makeToast(message)
            }
            self.tblResult.reloadData()
        }
    }
    func getUniversity()
    {
        //        SVProgressHUD.show()
        DataManager.shared.getUniversity{ success, message in
            //            SVProgressHUD.dismiss()
            if success{
                for index in 0 ..< universitiesArray.count{
                    let oneUniversity = universitiesArray[index]
                    if oneUniversity.id == DataManager.shared.loggedInUser().university_id{
                        myUniversity = oneUniversity
                        self.curUnivID = myUniversity.id
                        
                        self.loadData()
                        break
                    }
                }
                print("---Success")
            }else{
                //                        self.view.makeToast(message)
            }
        }
    }
    
    @IBAction func cellOpenProfileBtnTapped(_ sender: Any) {
        let button = sender as! UIButton
        let buttonPosition = button.convert(button.bounds.origin, to: tblResult)
        if let indexPath = tblResult.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            let postDetails = resultArray[rowIndex]
            SVProgressHUD.show()
            DataManager.shared.getUserFromID(opp_id: postDetails.user_id){ success,data, message in
                SVProgressHUD.dismiss()
                if success{
                    if data.count > 0{
                        let profileInfo = data[0]
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        vc.isOpeningOtherProfile = true
                        vc.profileBasicInfo = profileInfo
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    
                }else{
                    //                        self.view.makeToast(message)
                    
                }
            }
        }
    }
    
    @IBAction func cellOpenGroupBtnTapped(_ sender: Any) {
        let button = sender as! UIButton
        let tag = button.tag
        let buttonPosition = button.convert(button.bounds.origin, to: tblResult)
        if let indexPath = tblResult.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            let post = resultArray[rowIndex]
            if let groups = post.groups
            {
                let index = tag - 501
                if groups.count > index{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsVC") as! GroupDetailsVC
                    vc.groupDict = groups[index]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
                
        }
    }
    @IBAction func cellShareBtnTapped(_ sender: Any) {
      
        let button = sender as! UIButton
        let buttonPosition = button.convert(button.bounds.origin, to: tblResult)
        if let indexPath = tblResult.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            let post = resultArray[rowIndex]
            for index in 0 ..< universitiesArray.count{
                let oneUniversity = universitiesArray[index]
                if oneUniversity.id == post.university_id{
                   
                    createUserShareLink(user_id: DataManager.shared.loggedInUser().id, post_id: post.post_id, social_type: post.social_type) { link in
                        let shareController = UIActivityViewController(activityItems: ["Check out this featured post at \(oneUniversity.university_name) by \(post.firstname) \(post.lastname).\n\(link)"], applicationActivities: nil)
                        self.present(shareController, animated: true)
                    }

                    break
                }
            }

        }

    }

    func createUserShareLink(user_id:String, post_id:String, social_type:String,completion:@escaping (String)->Void){
    //        let buo = BranchUniversalObject(canonicalIdentifier: "content/12345")
        let buo = BranchUniversalObject.init(canonicalIdentifier: "content/12345")
        buo.title = "Check this top post"
        buo.contentDescription = "Posters helps you connect with your classmates and discover social media content!"
        buo.imageUrl = "https://postersappadmin.com/uploads/logoapp.png"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        
        let lp = BranchLinkProperties()
        lp.feature = "sharing"
        lp.addControlParam("$ios_url", withValue: "")
        lp.addControlParam("$match_duration", withValue: "2000")
        lp.addControlParam("custom_data", withValue: "yes")
        lp.addControlParam("user_id", withValue: user_id)
        lp.addControlParam("post_id", withValue: post_id)
        lp.addControlParam("social_type", withValue: social_type)

        DispatchQueue(label: "",qos: .background).async {
            let url = buo.getShortUrl(with: lp) ?? ""
            DispatchQueue.main.async {
                completion(url)
            }
        }
        //url = buo.getShortUrl(with: lp) ?? ""
    }

    
}
//MARK: TableView Delegate
extension HomeVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblResult{
            return resultArray.isEmpty ? 0:resultArray.count
        }
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 114.0
        return UITableView.automaticDimension

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblResult{
            if indexPath.row < resultArray.count
            {
                let post = resultArray[indexPath.row]
           
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTextCell", for: indexPath) as! PhotoTextCell
                if indexPath.row == 7{
                    print("---")
                }
                    if(post.thumb_url != "" && selectedSocialIndex == 0)
                    {
                        cell.postPhotoImageView.af.setImage(withURL: URL(string: post.thumb_url)!,placeholderImage: UIImage(named: "img_group_placeholder"))
                    }
                    else if(selectedSocialIndex == 1) //instagram
                    {
                        cell.postPhotoImageView.af.setImage(withURL: URL(string: "https://www.instagram.com/p/\(post.post_url)/media/?size=m")!,placeholderImage: UIImage(named: "img_group_placeholder"))

                    }
                    cell.profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (post.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))
                    cell.lbl_name.text = post.username
                    cell.lbl_number.text = "\(indexPath.row + 1)"
                    cell.lbl_num_likes_increase.text = getSimpliedCountString(post.likes_diff)
                    cell.btn_fullName.setTitle("\(post.firstname) \(post.lastname)", for: .normal)
                    cell.lbl_grade.text = "Class of \(post.grade)"
//                    cell.lbl_num_comments.text = "\(post.comment_count)"
                //                    cell.lbl_num_heart.text = getSimpliedCountString(post.num_likes)
                if let groups = post.groups{
                    if groups.count == 0{
                        cell.groupListHeight.constant = 0
                    }
                    else{
                        var count = groups.count
                        if count > 2{
                            count = 2
                        }
                        cell.groupListHeight.constant = CGFloat(count) * 28.0
                        cell.btn_group1.setTitle(post.groups![0].group_name, for: .normal)
                        cell.icon_group1.af.setImage(withURL: URL(string: PHOTO_URL + (post.groups![0].group_photo ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))
                        if count > 1{
                            cell.btn_group2.setTitle(post.groups![1].group_name, for: .normal)
                            cell.icon_group2.af.setImage(withURL: URL(string: PHOTO_URL + (post.groups![1].group_photo ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))

                        }
                    }
                }
                 
                    return cell
            }
            else{
                return UITableViewCell.init()
            }
        }
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row < resultArray.count)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
            vc.hidesBottomBarWhenPushed = true
            vc.postDetails = resultArray[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class PhotoTextCell : UITableViewCell{
    @IBOutlet weak var lbl_name: UILabel!
    
    @IBOutlet weak var icon_group2: UIImageView!
    @IBOutlet weak var icon_group1: UIImageView!
    @IBOutlet weak var btn_group2: UIButton!
    @IBOutlet weak var btn_group1: UIButton!
    @IBOutlet weak var groupListHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_grade: UILabel!
    @IBOutlet weak var btn_fullName: UIButton!
    @IBOutlet weak var lbl_num_likes_increase: UILabel!
    @IBOutlet weak var icon_eye: UIImageView!
    @IBOutlet weak var lbl_num_comments: UILabel!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
}
class TextCell : UITableViewCell{
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    
    @IBOutlet weak var icon_eye: UIImageView!
    @IBOutlet weak var lbl_num_comments: UILabel!
    @IBOutlet weak var lbl_num_heart: UILabel!
    @IBOutlet weak var lbl_num_watched: UILabel!
    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
}

//MARK: CollectionView Delegate
extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return 2
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyLessonCell", for: indexPath) as! DailyLessonCell

        if(indexPath.item == 0)
        {
            cell.lblTitle.text = "Tik Tok"
        }
        else if(indexPath.item == 1)
        {
            cell.lblTitle.text = "Instagram"
        }
   
        cell.icon_lock.image = UIImage.init(named: "icon_social\(indexPath.item + 1)")
        if(indexPath.item == selectedSocialIndex)
        {
            cell.icon_lock.tintColor = UIColor.white
            cell.lblTitle.textColor = UIColor.white
            cell.containerView.backgroundColor = UIColor.init(named: "customBlue")
        }
        else{
            cell.icon_lock.tintColor = UIColor.init(named: "customBlue")
            cell.lblTitle.textColor = UIColor.init(named: "custom1F0025")
            cell.containerView.backgroundColor = UIColor.white
        }
        
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
////        let nsText = fullProfileInfo.interests![indexPath.item]
////        let itemSize = nsText.size(withAttributes: [
////            NSAttributedString.Key.font : UIFont.init(name: "Poppins-Regular", size: 14.0)!])
//        let cellWidth = (self.view.frame.size.width - 21.0 * 2 - 4.0 * 2) / 3.0;
//
//        if(indexPath.item == 1)
//        {
//            return CGSize(width: cellWidth + 10, height: 34)
//        }
//        return CGSize(width: cellWidth - 5,  height: 34)
//
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSocialIndex = indexPath.item
        self.socialTypeCollectionView.reloadData()
//        self.tblResult.reloadData()
        self.loadData()
    }
}

class DailyLessonCell : UICollectionViewCell{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var icon_lock: UIImageView!
    @IBOutlet weak var containerView: UIView!
}
