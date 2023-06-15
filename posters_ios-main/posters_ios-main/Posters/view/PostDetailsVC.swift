//
//  PostDetailsVC.swift
//  Posters
//
//  Created by Administrator on 3/6/23.
//

import UIKit
import SVProgressHUD
class PostDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var lbl_noDataComments: UILabel!
    
    @IBOutlet weak var postPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var seeMoreBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_see_more_caption: UIButton!
    @IBOutlet weak var btn_open_social: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var listHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_num_comments: UILabel!
    @IBOutlet weak var lbl_num_watched: UILabel!
    @IBOutlet weak var icon_eye: UIImageView!
    @IBOutlet weak var lbl_num_likes: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var edt_comment: UITextField!
    var parent_id = "0"
    var parent_commenter_name = ""
    var postDetails : Post!
    var commentsArray = [Comment]()
    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor.init(named: "customTextPlaceholder")
        edt_comment.attributedPlaceholder = NSAttributedString(string: edt_comment.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color!])
        listTableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        self.showBasicData()
        self.loadComments(scrollToBottom: false)
        self.listTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView, obj == self.listTableView && keyPath == "contentSize"{
            listHeight.constant = listTableView.contentSize.height
//            if let zeChange = change as? [NSString:NSValue] {
//                let newSize = zeChange[NSKeyValueChangeKey.newKey as NSString]?.cgSizeValue
//                self.listHeight.constant = newSize?.height ?? 0
//            }
        }
    }

    func showBasicData()
    {
        profilePhotoImageView.af.setImage(withURL: URL(string: PHOTO_URL + (postDetails.photo_url ))!,placeholderImage: UIImage(named: "img_profile_placeholder"))
        lbl_username.text = postDetails.username
        lbl_description.text = postDetails.caption
        let lines = self.countLines(font: lbl_description.font, text: lbl_description.text ?? "", width: lbl_description.frame.size.width)
        if (lines > 1)
        {
            btn_see_more_caption.isHidden = false
        }
        else{
            btn_see_more_caption.isHidden = true
            seeMoreBtnHeight.constant = 0
        }
        let countStr = getSimpliedCountString(postDetails.num_likes)
        lbl_num_likes.text = "\(countStr) likes"
        if(postDetails.thumb_url != "" && postDetails.post_type == "1")
        {
            postPhotoImageView.af.setImage(withURL: URL(string: postDetails.thumb_url)!,placeholderImage: UIImage(named: "img_group_placeholder"))
        }
        else if(postDetails.post_type == "0") //instagram
        {
            postPhotoImageView.af.setImage(withURL: URL(string: "https://www.instagram.com/p/\(postDetails.post_url)/media/?size=l")!,placeholderImage: UIImage(named: "img_group_placeholder"))

        }
//"https://scontent-hel3-1.cdninstagram.com/v/t51.2885-15/329043998_2954670088009916_3973572030892504495_n.jpg?stp=c0.180.1440.1440a_dst-jpg_e35_s640x640_sh0.08&_nc_ht=scontent-hel3-1.cdninstagram.com&_nc_cat=1&_nc_ohc=95IES1dyLboAX-0xraK&edm=AJfeSrwBAAAA&ccb=7-5&oh=00_AfCISNO7NkTghXTG1OAP2nrXd5q9yk9-BiTzp5nX_tEW4w&oe=6439F77D&_nc_sid=588073"
//"https://scontent-hel3-1.cdninstagram.com/v/t51.2885-15/329043998_2954670088009916_3973572030892504495_n.jpg?stp=c0.180.1440.1440a_dst-jpg_e35_s640x640_sh0.08&_nc_ht=scontent-hel3-1.cdninstagram.com&_nc_cat=1&_nc_ohc=QRT9UOXIEF4AX9yLfA9&edm=AJfeSrwBAAAA&ccb=7-5&oh=00_AfBzGytbp6id-yyVb8ctzh7nN8cJ9nXB0AVPlPk0O5p70g&oe=643408BD&_nc_sid=588073"
        postPhotoHeight.constant = self.view.frame.size.width - 30.0

        if(postDetails.social_type == "0")
        {
            btn_open_social.setBackgroundImage(UIImage.init(named: "icon_social2"), for: .normal)
//            lbl_num_watched.isHidden = true
//            icon_eye.isHidden = true
        }
        else{
//            postPhotoHeight.constant = (self.view.frame.size.width - 30.0) / 9.0 * 16.0

        }
        
    }
    @IBAction func seeMoreBtnTapped(_ sender: Any) {
        lbl_description.numberOfLines = 0
        btn_see_more_caption.isHidden = true
    }
    func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
    func loadComments(scrollToBottom: Bool = true){
      
        SVProgressHUD.show()
        DataManager.shared.getComments(post_id: postDetails.post_id, social_type: postDetails.social_type){ success,data, message in
            SVProgressHUD.dismiss()
            if success{
                self.commentsArray = data
                print("---Success")
            }else{
                self.commentsArray.removeAll()
                //                        self.view.makeToast(message)
            }
//            self.lbl_num_comments.text = "\(self.commentsArray.count)"
            self.listTableView.reloadData()
            if self.commentsArray.count == 0{
                self.lbl_noDataComments.isHidden = false
                self.listTableView.isHidden = true
            }
            else{
                self.lbl_noDataComments.isHidden = true
                self.listTableView.isHidden = false
            }
            if scrollToBottom
            {
//                self.listTableView.scrollToRow(at: IndexPath(row: self.commentsArray.count - 1, section: 0), at: .bottom, animated: false)
                let bottomOffset = CGPoint(x:0, y: self.mainScrollView.contentSize.height - self.mainScrollView.bounds.height + self.mainScrollView.contentInset.bottom + 100)
                self.mainScrollView.setContentOffset(bottomOffset, animated: true)
            }

        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openProfileBtnTapped(_ sender: Any) {
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
    @IBAction func openPostBtnTapped(_ sender: Any) {
        if postDetails.social_type == "0"
        {
            if postDetails.post_url != ""{
                let urlStr = "https://instagram.com/p/\(postDetails.post_url)"
                UIApplication.shared.open(URL(string: urlStr)!)

            }
        }
        else if postDetails.social_type == "1"
        {
            if postDetails.post_url != ""{
                let urlStr = "https://tiktok.com/@\(postDetails.social_name)/video/\(postDetails.post_id)"
                UIApplication.shared.open(URL(string: urlStr)!)

            }
        }

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
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportUserVC") as! ReportUserVC
//        vc.oppID = profileBasicInfo.id
//        vc.relatedGroupID = "-1"
//        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func sendBtnTapped(_ sender: Any) {
        if(edt_comment.text == "")
        {
            return
        }
        SVProgressHUD.show()
        DataManager.shared.addComment(post_id: postDetails.post_id, comment: edt_comment.text ?? "", parent_id: parent_id, social_type: postDetails.social_type){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.edt_comment.text = ""
                self.parent_id = "0"
                self.view.endEditing(true)
                self.loadComments()
                

            }else{
                self.view.makeToast(message)
            }
        }
    }
    @objc private func didPressCellLikeButton(_ sender: UIButton) {
        let button = sender
        let buttonPosition = button.convert(button.bounds.origin, to: listTableView)
        if let indexPath = listTableView.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            var likeAction = "like"
            if button.isSelected{
                likeAction = "dislike"
            }
            if likeAction == "like"
            {
                button.isSelected = true
            }
            else{
                button.isSelected = false
            }
            let comment = commentsArray[rowIndex];
//            SVProgressHUD.show()
            DataManager.shared.updateCommentLike(comment_id: comment.id, creator_id: comment.commenter_id, like_action: likeAction){ success, message in
//                SVProgressHUD.dismiss()
                if success{
                    self.loadComments()
//                    self.view.makeToast("Updated successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
//                    }
                }else{
//                    self.view.makeToast(message)
                }
            }
        }
    }
    @objc private func didPressCellReplyButton(_ sender: UIButton) {
        let button = sender
        let buttonPosition = button.convert(button.bounds.origin, to: listTableView)
        if let indexPath = listTableView.indexPathForRow(at: buttonPosition){
            let rowIndex = indexPath.row
            let oneComment = commentsArray[rowIndex]
            parent_id = oneComment.id
            parent_commenter_name = oneComment.username
            self.updateCommentBoxUI()
            edt_comment.becomeFirstResponder()
        }

        
    }
    func updateCommentBoxUI(){
        if(parent_id == "0" )
        {
            edt_comment.placeholder = "Write a comment";
        }
        else
        {
            edt_comment.placeholder = "Reply to @\(parent_commenter_name)";
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listTableView{
            return commentsArray.count
        }
        return 0
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 61.0
////        return UITableView.automaticDimension
//
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == listTableView{
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
            let prediction = commentsArray[indexPath.row]
            cell.lbl_comment.text = prediction.comment
            cell.lbl_posetername.text = prediction.username
            cell.lbl_date.text = getTimeString(time: prediction.date_created)
            cell.lbl_num_like.text = prediction.like_count
            cell.replyArray = prediction.replies ?? [Reply]()
            cell.lbl_num_like.text = prediction.like_count
            if prediction.like_status == "1"{
                cell.btn_status_liked_by_me.isSelected = true
            }
            else{
                cell.btn_status_liked_by_me.isSelected = false
            }
            
            cell.reloadData()
            cell.btn_status_liked_by_me.addTarget(self, action: #selector(didPressCellLikeButton(_:)), for: .touchUpInside)
            cell.btn_reply.addTarget(self, action: #selector(didPressCellReplyButton(_:)), for: .touchUpInside)

            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < commentsArray.count{
        }
    }
}
