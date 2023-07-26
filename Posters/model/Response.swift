
import Foundation

struct CodeResponse : Codable{
    let status : String
    let code : String?
}


struct LoginResponse : Codable{
    let status : String
    let data : [User]?
}
struct GroupDetailsResponse : Codable{
    let status : String
    let data : [User]?
    let num_total_follower : String?

}
struct UniversityResponse : Codable{
    let status : String
    let data : [University]?
}
struct StatusResponse : Codable{
    let status : String
}
struct GroupResonpose : Codable{
    let status : String
    let data : [Group]?
}
struct ProfileDetailsResonpose : Codable{
    let status : String
    let groups : [Group]?
    let instagram_posts: [BasicPost]?
    let tiktok_posts: [BasicPost]?
    let university_name: String
}
struct ProfileTopPostsResponse : Codable{
    let status : String
    let data: [BasicPost]?
}

struct PhotoResponse : Codable{
    let status : String
    let photo_url : String?
}
struct PostResponse : Codable{
    let status : String
    let data : [Post]?
}
struct CommentResponse : Codable{
    let status : String
    let data : [Comment]?
}
