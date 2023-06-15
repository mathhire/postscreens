

import Foundation
import UIKit

struct User : Codable{
    var id : String
    var phone : String
    var country_code : String
    var firstname : String
    var lastname : String
    var username: String
    var bio: String
    var photo_url : String
    var university_id : String
    var grade: String
    var age: String
    var lat : String
    var lng : String
    var push_enabled: String
    var utype : String
    var act : String
    var instagram : String
    var instagram_num_follower : String
    var tiktok : String
    var tiktok_num_follower : String
    var member_since : String
}

struct University : Codable{
    var id : String
    var university_name : String
    var ulat : String
    var ulng : String
}
struct Group : Codable{
    var id : String
    var university_id : String
    var group_name : String
    var group_photo : String
    var num_members : String
    var num_total_follower : String?
    var status : String
    var date_created: String
}
struct Post : Codable{
    var id : String
    var user_id : String
    var university_id : String
    var social_type : String
    var social_name : String
    var instagram : String?
    var tiktok : String
    var grade : String
    var post_id : String
    var post_type : String
    var caption: String
    var num_likes: String
    var num_views: String
    var likes_diff : String
    var firstname: String
    var lastname: String
    var username: String
    var photo_url : String
    var thumb_url: String
    var web_url: String
    var post_url: String
    var date_created: String
    var groups: [Group]?
//    var comment_count : String
}
struct Comment : Codable{
    var id : String
    var post_id : String
    var commenter_id : String
    var parent_id : String
    var comment : String
    var date_created : String
    var username: String
    var photo_url : String
    var like_status : String
    var like_count : String
    var social_type : String
    var replies : [Reply]?
}
struct Reply : Codable{
    var id : String
    var post_id : String
    var commenter_id : String
    var parent_id : String
    var comment : String
    var date_created : String
    var username: String
    var photo_url : String
    var like_status : String
    var like_count : String
    var social_type: String
}
struct BasicPost : Codable{
    var id : String
    var user_id : String
    var social_type : String
    var social_name : String
    var post_id : String
    var post_type : String
    var caption: String
    var num_likes: String
    var num_views: String
    var thumb_url: String
    var web_url: String
    var post_url: String
    var date_created: String
    var date_posted: String
    var ranked_date: String?
//    var comment_count : String
}
