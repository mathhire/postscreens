//
//  CommentTableViewCell.swift
//  Posters
//
//  Created by Administrator on 3/6/23.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btn_status_liked_by_me: UIButton!
    @IBOutlet weak var btn_reply: UIButton!
    @IBOutlet weak var commentHeight: NSLayoutConstraint!
    @IBOutlet weak var listHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_num_like: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_comment: UILabel!
    @IBOutlet weak var lbl_posetername: UILabel!
    @IBOutlet weak var cv1: UITableView!
    var replyArray = [Reply]()
    override func awakeFromNib() {
        super.awakeFromNib()
        cv1.register(UINib.init(nibName: "ReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "ReplyTableViewCell")
        cv1.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        // Initialization code
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView, obj == self.cv1 && keyPath == "contentSize"{
            listHeight.constant = cv1.contentSize.height
//            if let zeChange = change as? [NSString:NSValue] {
//                let newSize = zeChange[NSKeyValueChangeKey.newKey as NSString]?.cgSizeValue
//                self.listHeight.constant = newSize?.height ?? 0
//            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
       let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text
       label.sizeToFit()
       return label.frame.height
   }

    func reloadData(){
        cv1.reloadData()
        let font = UIFont(name: "Montserrat-Medium", size: 12.0)!
        var height = self.heightForView(text: lbl_comment.text ?? "", font: font, width: self.frame.size.width  - 50 - 55)
        if height < 18{
            height = 18
        }
        commentHeight.constant = height
        self.layoutIfNeeded()

        
    }
    @objc private func didPressCellLikeButton(_ sender: UIButton) {
        let button = sender
        let buttonPosition = button.convert(button.bounds.origin, to: cv1)
        if let indexPath = cv1.indexPathForRow(at: buttonPosition){
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
            let comment = replyArray[rowIndex];
//            SVProgressHUD.show()
            DataManager.shared.updateCommentLike(comment_id: comment.id, creator_id: comment.commenter_id, like_action: likeAction){ success, message in
//                SVProgressHUD.dismiss()
                if success{
                    if likeAction == "like"
                    {
                        self.replyArray[rowIndex].like_count = "\(Int(self.replyArray[rowIndex].like_count)! + 1)"
                        self.replyArray[rowIndex].like_status = "1"
                    }
                    else{
                        self.replyArray[rowIndex].like_count = "\(Int(self.replyArray[rowIndex].like_count)! - 1)"
                        self.replyArray[rowIndex].like_status = "0"


                    }
                    self.cv1.reloadData()
                    print("----")
//                    self.loadComments()
//                    self.view.makeToast("Updated successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
//                    }
                }else{
//                    self.view.makeToast(message)
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cv1{
            return replyArray.count
        }
        return 0
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 61.0
////        return UITableView.automaticDimension
//
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cv1{
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyTableViewCell", for: indexPath) as! ReplyTableViewCell
            let prediction = replyArray[indexPath.row]
            cell.replyLabel.text = prediction.comment
            cell.nameLabel.text = prediction.username
            cell.lbl_num_like.text = prediction.like_count
            if prediction.like_status == "1"{
                cell.btn_like.isSelected = true
            }
            else{
                cell.btn_like.isSelected = false
            }
            cell.btn_like.addTarget(self, action: #selector(didPressCellLikeButton(_:)), for: .touchUpInside)

            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < replyArray.count{
        }
    }

}
