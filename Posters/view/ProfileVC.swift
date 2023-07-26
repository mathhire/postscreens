//
//  ProfileVC.swift
//  Posters
//
//  Created by Administrator on 3/2/23.
//

import UIKit
import SVProgressHUD
import FSCalendar

class ProfileVC: UIViewController {
    var isOpeningOtherProfile = false
    var profileBasicInfo : User!
    var groupsArray = [Group]()
    var instagramPostsArray = [BasicPost]()
    var tiktokPostsArray = [BasicPost]()
    var topPostsArray = [BasicPost]()
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_expand_calendar: UIButton!
    @IBOutlet weak var posterCalendarView: FSCalendar!
    @IBOutlet weak var instagramContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var instagramPostCollectionView: UICollectionView!
    @IBOutlet weak var instagramContainerView: UIView!
    @IBOutlet weak var btn_expand_instagram: UIButton!
    @IBOutlet weak var lbl_instagram_username: UILabel!
    @IBOutlet weak var tiktokPostCollectionView: UICollectionView!
    @IBOutlet weak var btn_expand_tiktok: UIButton!
    @IBOutlet weak var tiktokContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_tiktok_username: UILabel!
    @IBOutlet weak var groupListHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_tiktok_num_follower: UILabel!
    @IBOutlet weak var lbl_instagram_num_follower: UILabel!
    @IBOutlet weak var btn_setting: UIButton!
    @IBOutlet weak var btn_more: UIButton!
    
    @IBOutlet weak var lbl_bio: UILabel!
    @IBOutlet weak var tiktokContainerView: UIView!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var btn_view_all_group_joined: UIButton!
    @IBOutlet weak var tblGroup: UITableView!
    @IBOutlet weak var lbl_refresh_time: UILabel!
    
    @IBOutlet weak var lbl_university: UILabel!
    @IBOutlet weak var lbl_fullname: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var lbl_grade: UILabel!
    var isLoadingFirstTime = true
    var resultArray = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        if(!isOpeningOtherProfile)
        {
            profileBasicInfo = DataManager.shared.loggedInUser()
        }
        self.showBasicData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!isOpeningOtherProfile && shouldReloadProfile)
        {
            shouldReloadProfile = false
            DataManager.shared.getMyProfile(){ success,data, message in
                SVProgressHUD.dismiss()
                if success{
                    self.profileBasicInfo = DataManager.shared.loggedInUser()
                    self.showBasicData()
                    
                }else{
                    
                }
            }
        }
        if(!isOpeningOtherProfile && !isLoadingFirstTime)
        {
            profileBasicInfo = DataManager.shared.loggedInUser()

            self.showBasicData()
        }
        self.loadDetails()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoadingFirstTime
        {
            calendarHeight.constant = 0.0
            posterCalendarView.isHidden = true
            isLoadingFirstTime = false
        }
        

    }
    func loadDetails(){
        SVProgressHUD.show()
        DataManager.shared.getProfileDetails(opp_id: profileBasicInfo.id){ success,data,instagram,tiktok, university_name, message in
            SVProgressHUD.dismiss()
            if success{
                self.groupsArray = data
                self.tiktokPostsArray = tiktok
                self.instagramPostsArray = instagram
                self.lbl_university.text = university_name
                print("---Success")
            }else{
                self.groupsArray = [Group]()
                //                        self.view.makeToast(message)
            }
            self.tblGroup.reloadData()
            self.groupListHeight.constant = CGFloat(self.groupsArray.count) * 26.0
            self.tiktokPostCollectionView.reloadData()
            self.instagramPostCollectionView.reloadData()
        }
    }
    func loadTopPosts(){
        SVProgressHUD.show()
        DataManager.shared.getProfileTopPosts(opp_id: profileBasicInfo.id){ success,data, message in
            SVProgressHUD.dismiss()
            if success{
                print("---Success")
                self.topPostsArray = data
            }else{
                self.topPostsArray = [BasicPost]()
                //                        self.view.makeToast(message)
            }
            self.posterCalendarView.reloadData()
        }
    }
    func initUI()
    {
        if isOpeningOtherProfile{
            btn_more.isHidden = false
            btn_setting.isHidden = true
            btn_back.isHidden = false
            lbl_title.text = "Profile"
        }
        else{
            btn_more.isHidden = true
            btn_setting.isHidden = false
            btn_back.isHidden = true
            lbl_title.text = "My Profile"
        }
        
        let cellHeight = 65.0
        let cellWidth = 65.0
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.itemSize = CGSizeMake(cellWidth, cellHeight)
        
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 20
        tiktokPostCollectionView!.collectionViewLayout = layout2
        
//        posterCalendarView.scrollDirection = .vertical
//        posterCalendarView.appearance.borderRadius = 0
        posterCalendarView.today = nil
        posterCalendarView.placeholderType = .none
        posterCalendarView.calendarWeekdayView.isHidden = true
        
    }
   
    func showBasicData(){
        if(profileBasicInfo != nil)
        {
            
            lbl_username.text = "@\(profileBasicInfo.username)"
            lbl_fullname.text = "\(profileBasicInfo.firstname) \(profileBasicInfo.lastname)"
            lbl_bio.text = profileBasicInfo.bio
            lbl_grade.text = "Class of \(profileBasicInfo.grade)"
            profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (profileBasicInfo.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))
            if profileBasicInfo.instagram != ""
            {
                lbl_instagram_num_follower.text =  getSimpliedCountString(profileBasicInfo.instagram_num_follower)
                lbl_instagram_username.text = "@\(profileBasicInfo.instagram)"
                instagramContainerView.isHidden = false
                instagramContainerHeight.constant = 110.0

            }
            else{
                instagramContainerView.isHidden = true
                instagramContainerHeight.constant = 0.0

            }
            if profileBasicInfo.tiktok != ""
            {
                lbl_tiktok_num_follower.text =  getSimpliedCountString(profileBasicInfo.tiktok_num_follower)
                lbl_tiktok_username.text = "@\(profileBasicInfo.tiktok)"
                tiktokContainerView.isHidden = false
                tiktokContainerHeight.constant = 110.0

            }
            else{
                tiktokContainerView.isHidden = true
                tiktokContainerHeight.constant = 0.0
            }
        }
        
        
    }
    @IBAction func openViewAllGroupJoined(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserJoinedGroupsVC") as! UserJoinedGroupsVC
        vc.hidesBottomBarWhenPushed = true
        vc.resultArray = groupsArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func expandCollapseTiktokBtnTapped(_ sender: Any) {
        btn_expand_tiktok.isSelected = !btn_expand_tiktok.isSelected
        if btn_expand_tiktok.isSelected
        {
            tiktokContainerHeight.constant = 35.0
            tiktokPostCollectionView.isHidden = true
        }
        else{
            tiktokContainerHeight.constant = 110.0
            tiktokPostCollectionView.isHidden = false
        }
    }
    @IBAction func expandCollapseInstagramBtnTapped(_ sender: Any) {
        btn_expand_instagram.isSelected = !btn_expand_instagram.isSelected
        if btn_expand_instagram.isSelected
        {
            instagramContainerHeight.constant = 35.0
            instagramPostCollectionView.isHidden = true
        }
        else{
            instagramContainerHeight.constant = 110.0
            instagramPostCollectionView.isHidden = false
        }
    }
    @IBAction func expandCollapseTopPostsTapped(_ sender: Any) {
        btn_expand_calendar.isSelected = !btn_expand_calendar.isSelected
        if btn_expand_calendar.isSelected
        {
            calendarHeight.constant = 0.0
            posterCalendarView.isHidden = true
        }
        else{
            calendarHeight.constant = 250.0
            posterCalendarView.isHidden = false
            self.loadTopPosts()
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action = UIAlertAction(title: "Report User", style: .destructive) { (action) in
            self.reportUser()
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)

    }
    func reportUser()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
        vc.oppID = profileBasicInfo.id
        vc.relatedGroupID = "-1"
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func settingBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func openInstagramProfileBtnTapped(_ sender: Any) {
        if profileBasicInfo.instagram != ""{
            let urlStr = "https://instagram.com/\(profileBasicInfo.instagram)"
            UIApplication.shared.open(URL(string: urlStr)!)

        }
    }
    @IBAction func openTiktokProfileBtnTapped(_ sender: Any) {
        if profileBasicInfo.tiktok != ""{
            let urlStr = "https://tiktok.com/@\(profileBasicInfo.tiktok)"
            UIApplication.shared.open(URL(string: urlStr)!)

        }

    }
    //    func imageFromURL(urlString:String) -> UIImage{
//        if let url = NSURL(string: urlString)
//        {
//            let request = NSURLRequest(url: url)
////            NSURLConnection.sendAsynchronousRequest(request, queue: <#T##OperationQueue#>, completionHandler: <#T##(URLResponse?, Data?, Error?) -> Void#>)
//        }
//    }
}

//MARK: TableView Delegate
extension ProfileVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblGroup{
            if groupsArray.count > 4{
                return 4
            }
            return groupsArray.count
        }
        else
        {
            return 3
        }
//        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblGroup
        {
            return 26
        }
//        return 62.0
        return UITableView.automaticDimension

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblGroup{
            if indexPath.row < groupsArray.count
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
                let group = groupsArray[indexPath.row]
                cell.lbl_name.text = group.group_name
                cell.groupPhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (group.group_photo ))!,placeholderImage: UIImage(named: "img_group_placeholder"))
                /*
                cell.groupPhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (group.group_photo ))!,placeholderImage: UIImage(named: "img_group_placeholder"), completion:  { result in
//                    let imageData = result.data
//                    let image = UIImage(data: imageData!)
                    switch result.result{
                    case .success(let image):
                        let templateImage = image.withRenderingMode(.alwaysTemplate)
                        cell.groupPhotoImageView.image = templateImage
                        cell.groupPhotoImageView.tintColor = UIColor.white

                    case .failure(let error):
                        print("\(error.localizedDescription)")
                        break
                    }
                })
*/

                return cell
            }
            else{
                return UITableViewCell.init()
            }
        }
 

     return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblGroup{
            
            if indexPath.row < groupsArray.count{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsVC") as! GroupDetailsVC
            vc.groupDict = groupsArray[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)

            }
        }
        else{
            
        }
        
    }
}

//MARK: CollectionView Delegate
extension ProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       if (collectionView == tiktokPostCollectionView)
        {
           return tiktokPostsArray.count
       }
        else if (collectionView == instagramPostCollectionView)
         {
            return instagramPostsArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialPostCell", for: indexPath) as! SocialPostCell
        if (collectionView == tiktokPostCollectionView)
        {
            if indexPath.item < tiktokPostsArray.count{
                let post = tiktokPostsArray[indexPath.item]
                if(post.thumb_url != "")
                {
                    cell.thumbPhotoImageView.af.setImage(withURL: URL(string: post.thumb_url)!,placeholderImage: UIImage(named: "img_group_placeholder"))
                }
            }
        }
        else if (collectionView == instagramPostCollectionView)
        {
            if indexPath.item < instagramPostsArray.count{
                let post = instagramPostsArray[indexPath.item]
                if(post.thumb_url != "")
                {
                    cell.thumbPhotoImageView.af.setImage(withURL: URL(string: post.thumb_url)!,placeholderImage: UIImage(named: "img_group_placeholder"))
                }
            }
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == tiktokPostCollectionView)
        {
            if indexPath.item < tiktokPostsArray.count{
                let post = tiktokPostsArray[indexPath.item]
                if post.post_url != ""{
                    let urlStr = "https://tiktok.com/@\(post.social_name)/video/\(post.post_id)"
                    UIApplication.shared.open(URL(string: urlStr)!)

                }
            }
        }
        else if (collectionView == instagramPostCollectionView)
        {
            if indexPath.item < instagramPostsArray.count{
                let post = instagramPostsArray[indexPath.item]
                if post.post_url != ""{
                    let urlStr = "https://instagram.com/p/\(post.post_url)"
                    UIApplication.shared.open(URL(string: urlStr)!)

                }
            }
        }
    }
}
class SocialPostCell : UICollectionViewCell{
    
    @IBOutlet weak var thumbPhotoImageView: UIImageView!
}
extension ProfileVC : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let index = self.getIndexOfTopPostFromDate(date: date)
        if index >= 0{
            let post = self.topPostsArray[index]
            if post.post_url != ""
            {
                if post.social_type == "1"
                {
                    let urlStr = "https://tiktok.com/@\(post.social_name)/video/\(post.post_id)"
                    UIApplication.shared.open(URL(string: urlStr)!)
                }
                else{
                    
                    let urlStr = "https://instagram.com/p/\(post.post_url)"
                    UIApplication.shared.open(URL(string: urlStr)!)
                }
            }
        }
    }
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let index = self.getIndexOfTopPostFromDate(date: date)
        if index >= 0{
            return UIImage.init(named: "star2")
        }
        return nil
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let member_since_timestamp_str = profileBasicInfo.member_since
        let member_since_timestamp = Double(member_since_timestamp_str) ?? 0
        let member_since_date = Date(timeIntervalSince1970: Double(member_since_timestamp_str) ?? 0)
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if(dateFormatter.string(from: member_since_date) == dateFormatter.string(from: date))
        {
            return UIColor.green
        }
        else{
            let timestamp = date.timeIntervalSince1970
            if timestamp < member_since_timestamp
            {
                return UIColor.lightGray
            }
            else{
                let index = self.getIndexOfTopPostFromDate(date: date)
                if index >= 0{
                    return UIColor.init(named: "customLightBlue")
                }
                else{
                    return UIColor.init(named: "customBlue")
                }
            }
        }
//        return UIColor.black
    }
    func getIndexOfTopPostFromDate(date: Date) -> Int{
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        for index in 0 ..< self.topPostsArray.count{
            let post = self.topPostsArray[index]
            if post.ranked_date == dateStr{
                return index
            }
        }
        return -1
        
    }
}
