
import Foundation
import UIKit
import Alamofire
import Toast_Swift
import SVProgressHUD
import CoreLocation
import OneSignal

var screen_width = 320.0
let BASE_URL = "https://postersappadmin.com/api_mobile/api.php"
let PHOTO_URL = "https://postersappadmin.com/"

let verify_key = "8osh1se0yo2ng5"
let Google_Place_Key = "AIzaSyCvygeaHxhrqPugiq4u999Dkdlodh9wRlI" // Posters
let tiktokClientKey = "awpsjpawo6tunebg"// you will receive this once you register in the Developer Portal
let tiktokClientSecret = "c645518e84c62167f7636f7ff105c524"


var universitiesArray = [University]()
var myUniversity : University!

//For registration
var currentLocation : CLLocation?
var regAge = ""
var regGrade = ""
var regUniversity : University!
var regPhone = ""
var regCountryCode = ""
var regLat = 0.0
var regLng = 0.0
var justVerifiedCode = false
var justRegistered = false
var openingGradeScreen = false
var shouldOpenPostDetails = false
var shouldReloadProfile = false
class DataManager{
    
    static let shared = DataManager()
    private var currentUser : User? = nil
    var alamofireManager : Session!
    
    
    init(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 300
        alamofireManager = Alamofire.Session(configuration:configuration)
    }
    
    func loggedInUser()->User{
        return currentUser!
    }
    
    func clear(){
        //removeObserver()
       
        saveEmailAndPassword("", "")
        currentUser = nil
    }
    
    
    func saveEmailAndPassword(_ email:String,_ password:String){
        let defaults = UserDefaults.standard
        defaults.setValue(email, forKey: "save_email")
        defaults.setValue(password, forKey: "save_password")
    }
    
    func getEmailAndPassword() -> (email:String,password:String){
        return (UserDefaults.standard.string(forKey: "save_email") ?? "",UserDefaults.standard.string(forKey: "save_password") ?? "")
    }
    func updateProfilePhoto(image:UIImage,completion:@escaping(Bool)->Void){
        let imgData = image.jpegData(compressionQuality: 0.5)
        let parameters = [
            "action" : "edit_profile_photo",
            "verify_key" : verify_key,
            "user_id" : loggedInUser().id
        ]
        alamofireManager.upload(multipartFormData: { form in
            form.append(imgData!, withName: "userfile1", fileName: "temp.jpg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                form.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: BASE_URL + "?action=edit_profile_photo").responseDecodable(of: PhotoResponse.self){ response in
            switch response.result{
            case .success(let result):

                if result.status == "success"{
                    self.currentUser?.photo_url = result.photo_url ?? ""
                    completion(true)

                }else{
                    completion(false)
                }
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    func register_user(firstname:String,lastname:String,phone:String, country_code:String,username:String, age: String, grade:String, university_id:String, lat:String, lng:String, image:UIImage,photo_uploaded:String, completion:@escaping (Bool, String)->Void){
            let imgData = image.jpegData(compressionQuality: 0.5)
            let parameters = [
                "action" : "register_user",
                "verify_key" : verify_key,
                "phone" : phone,
                "country_code" : country_code,
                "firstname" : firstname,
                "lastname" : lastname,
                "username" : username,
                "age" : age,
                "grade" : grade,
                "university_id" : university_id,
                "lat" : lat,
                "lng" : lng,
                "player_id" : OneSignal.getDeviceState().userId ?? "",
                "photo_uploaded" : photo_uploaded
                
            ]
            alamofireManager.upload(multipartFormData: { form in
                form.append(imgData!, withName: "userfile1", fileName: "temp.jpg", mimeType: "image/jpeg")
                for (key, value) in parameters {
                    form.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: BASE_URL + "?action=register_user").responseDecodable(of: LoginResponse.self){ response in
                switch response.result{
                case .success(let result):
    
                    if result.status == "success"{
                        self.saveEmailAndPassword(phone, country_code)
                        self.currentUser = result.data?.first
                        completion(true, "")

                    }
                    else if result.status == "already_exist"{
                        completion(false, "This phone number is already registered. Try Log In instead.")

                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
                }
            }
//        let parameters = [
//            "action" : "register_user",
//            "email" : email,
//            "firstname" : firstname,
//            "lastname" : lastname,
//            "player_id" : "",
//            "platform" : "ios",
//            "version" : Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
//        ]
//        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
//            switch response.result{
//                case .success(let result):
//                    print(result.status)
//                    if result.status == "success"{
//                        self.saveEmailAndPassword(email, "")
//                        self.currentUser = result.data?.first
//                        completion(true)
//                    }else{
//                        completion(false)
//                    }
//                case .failure(let error):
//                    print(error)
//                    completion(false)
//            }
//        }
    }
    func login(phone:String, country_code: String,completion:@escaping (Bool, String) -> Void){
        let parameters = [
            "action" : "signin",
            "phone" : phone,
            "country_code" : country_code,
            "player_id" : OneSignal.getDeviceState().userId ?? "",
            "platform" : "ios",
            "verify_key" : verify_key,
            "version" : Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        self.saveEmailAndPassword(phone, country_code)
                        self.currentUser = result.data?.first
                        completion(true, "")
                    }
                    else if result.status == "disabled_user"
                    {
                        completion(false, "Your account is deactivated")
                    }
                    else if result.status == "error"
                    {
                        completion(false, "Can't find your phone number. Please try signup instead")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func edit_profile(firstname:String,lastname:String,phone:String, country_code:String,username:String, age: String,bio:String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "edit_profile",
                "verify_key" : verify_key,
                "phone" : phone,
                "country_code" : country_code,
                "firstname" : firstname,
                "lastname" : lastname,
                "username" : username,
                "age" : age,
                "bio" : bio,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        self.saveEmailAndPassword(phone, country_code)
                        self.currentUser = result.data?.first
                        completion(true, "")
                    }
                    else if result.status == "already_exist"
                    {
                        completion(false, "This phone number is registered already.")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func edit_grade(grade: String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "edit_grade",
                "verify_key" : verify_key,
                "grade" : grade,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        self.currentUser?.grade = grade
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func edit_university(university_id: String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "edit_university",
                "verify_key" : verify_key,
                "university_id" : university_id,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        self.currentUser?.university_id = university_id
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func contact_us(subject: String, message: String, completion:@escaping (Bool, String)->Void){
        var name = ""
        if loggedInUser().firstname != ""{
            name = "\(loggedInUser().firstname) \(loggedInUser().lastname)"
        }
        else{
            name = loggedInUser().username
        }
            let parameters = [
                "action" : "contact_us",
                "verify_key" : verify_key,
                "subject" : subject,
                "message" : message,
                "user_id" : loggedInUser().id,
                "phone" : loggedInUser().phone,
                "name" : name
                
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func report_user(subject: String, message: String,related_group_id:String,opp_id:String, completion:@escaping (Bool, String)->Void){
   
            let parameters = [
                "action" : "report_user",
                "verify_key" : verify_key,
                "reason" : subject,
                "message" : message,
                "opp_id" : opp_id,
                "related_group_id": related_group_id,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }

    func delete_user(completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "delete_user",
                "verify_key" : verify_key,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func delete_social(social:String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "delete_social",
                "verify_key" : verify_key,
                "user_id" : loggedInUser().id,
                "social" : social
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func edit_push_setting(status: String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "edit_push_setting",
                "verify_key" : verify_key,
                "status" : status,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        self.currentUser?.push_enabled = status
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func updateTikTokInfo(display_name: String, num_follower:String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "update_tiktok_info",
                "verify_key" : verify_key,
                "tiktok" : display_name,
                "num_follower" : num_follower,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        self.currentUser?.tiktok = display_name
                        self.currentUser?.tiktok_num_follower = num_follower
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func updateInstagramInfo(display_name: String, num_follower:String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "update_instagram_info",
                "verify_key" : verify_key,
                "instagram" : display_name,
                "num_follower" : num_follower,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        self.currentUser?.instagram = display_name
                        self.currentUser?.instagram_num_follower = num_follower

                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func sendVerifySMS(phone:String,country_code:String,should_check_exist:String="yes",completion:@escaping (Bool,String,String?)->Void){
        let parameters = [
            "action" : "send_sms",
            "phone" : phone,
            "country_code": country_code,
            "should_check_exist" : should_check_exist,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: CodeResponse.self) { response in
            switch response.result{
            case .success(let result):
                if result.status == "success"{
                    completion(true,"",result.code)
                }
                else{
                    if result.status == "already_exist" {
                        completion(false,"This phone number is already registered. Try Log In instead.","")
                    }
                    else{
                        completion(false,"Unknown error",nil)

                    }
                }
            
            case .failure(let error):
                print(error)
                completion(false,"Network Error",nil)
            }
        }
    }
    func sendSMSForLogin(phone:String,country_code:String,completion:@escaping (Bool,String,String?)->Void){
        let parameters = [
            "action" : "send_sms_for_login",
            "phone" : phone,
            "country_code": country_code,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: CodeResponse.self) { response in
            switch response.result{
            case .success(let result):
                if result.status == "success"{
                    completion(true,"",result.code)
                }
                else{
                    if result.status == "not_exist" {
                        completion(false,"This phone number is not registered. Try SignUp instead.","")
                    }
                    else{
                        completion(false,"Unknown error",nil)

                    }
                }
            
            case .failure(let error):
                print(error)
                completion(false,"Network Error",nil)
            }
        }
    }
    func getUniversityFromID(university_id: String, completion:@escaping (Bool, [University], String) -> Void){
        let parameters = [
            "action" : "get_university_from_id",
            "university_id" : university_id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: UniversityResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let groupsArray = result.data ?? [University]()
                        completion(true, groupsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[University](), "Verify Error")
                    }
                    else{
                        completion(false, [University](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [University](),"Sorry. Something went wrong")
            }
        }
    }
    func getUniversity(completion:@escaping (Bool, String) -> Void){
        let parameters = [
            "action" : "get_university",
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: UniversityResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        universitiesArray = result.data ?? [University]()
                        completion(true, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false, "Verify Error")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func getGroupsForUniversity(university_id: String, completion:@escaping (Bool, [Group], String) -> Void){
        let parameters = [
            "action" : "get_groups_list",
            "university_id" : university_id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: GroupResonpose.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let groupsArray = result.data ?? [Group]()
                        completion(true, groupsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[Group](), "Verify Error")
                    }
                    else{
                        completion(false, [Group](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [Group](),"Sorry. Something went wrong")
            }
        }
    }
    func searchUser(university_id: String,search_key:String, completion:@escaping (Bool, [User], String) -> Void){
        let parameters = [
            "action" : "search_user",
            "university_id" : university_id,
            "search_key" : search_key,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let usersArray = result.data ?? [User]()
                        completion(true, usersArray, "")
                    }
                    else if result.status == "no_data"
                    {
                        completion(true,[User](), "")
                    }
                    else{
                        completion(false, [User](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [User](),"Sorry. Something went wrong")
            }
        }
    }
    func getGroupDetails(group_id: String, completion:@escaping (Bool, [User],String, String) -> Void){
        let parameters = [
            "action" : "get_group_details",
            "group_id" : group_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: GroupDetailsResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let usersArray = result.data ?? [User]()
                        completion(true, usersArray,result.num_total_follower ?? "0", "")
                    }
                    else if result.status == "no_data"
                    {
                        completion(true,[User](), result.num_total_follower ?? "0", "")
                    }
                    else{
                        completion(false, [User](),"0", "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [User](),"0","Sorry. Something went wrong")
            }
        }
    }
    func getUserFromID(opp_id: String, completion:@escaping (Bool, [User], String) -> Void){
        let parameters = [
            "action" : "get_user_from_id",
            "opp_id" : opp_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let usersArray = result.data ?? [User]()
                        completion(true, usersArray, "")
                    }
                    else if result.status == "no_data"
                    {
                        completion(true,[User](), "")
                    }
                    else{
                        completion(false, [User](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [User](),"Sorry. Something went wrong")
            }
        }
    }
    func getMyProfile(completion:@escaping (Bool, [User], String) -> Void){
        let parameters = [
            "action" : "get_user_from_id",
            "opp_id" : loggedInUser().id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: LoginResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let usersArray = result.data ?? [User]()
                        self.currentUser = result.data?.first

                        completion(true, usersArray, "")
                    }
                    else if result.status == "no_data"
                    {
                        completion(true,[User](), "")
                    }
                    else{
                        completion(false, [User](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [User](),"Sorry. Something went wrong")
            }
        }
    }
    func checkExistUserName(username:String, completion:@escaping (Bool, String) -> Void){
        let parameters = [
            "action" : "check_exist_username",
            "username" :username,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "not_exist" {
                        completion(true, "")
                    }
                    else if result.status == "already_exist"
                    {
                        completion(false, "Username is registered already. Please try another one.")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func joinGroup(group_id:String, completion:@escaping (Bool, String) -> Void){
        let parameters = [
            "action" : "join_group",
            "group_id" :group_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" {
                        completion(true, "")
                    }
                    else if result.status == "already_joined"
                    {
                        completion(false, "Joined Already")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func leaveGroup(group_id:String, completion:@escaping (Bool, String) -> Void){
        let parameters = [
            "action" : "leave_group",
            "group_id" :group_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" {
                        completion(true, "")
                    }
                    else if result.status == "not_joined"
                    {
                        completion(false, "You didn't join previously.")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func getProfileDetails(opp_id: String, completion:@escaping (Bool, [Group],[BasicPost], [BasicPost],String, String) -> Void){
        let parameters = [
            "action" : "get_profile_details",
            "opp_id" : opp_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: ProfileDetailsResonpose.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"
                    {
                        let groupsArray = result.groups ?? [Group]()
                        let instagramArray = result.instagram_posts ?? [BasicPost]()
                        let tiktokArray = result.tiktok_posts ?? [BasicPost]()
                        let univ_name = result.university_name
                        completion(true, groupsArray,instagramArray, tiktokArray,univ_name, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[Group](), [BasicPost](), [BasicPost](),"", "Verify Error")
                    }
                    else{
                        completion(false, [Group](),[BasicPost](), [BasicPost](),"", "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [Group](),[BasicPost](), [BasicPost](),"", "Sorry. Something went wrong")
            }
        }
    }
    func getProfileTopPosts(opp_id: String, completion:@escaping (Bool,[BasicPost], String) -> Void){
        let parameters = [
            "action" : "get_profile_top_posts",
            "opp_id" : opp_id,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: ProfileTopPostsResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let postsArray = result.data ?? [BasicPost]()
                        
                        completion(true, postsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false, [BasicPost](), "Verify Error")
                    }
                    else{
                        completion(false, [BasicPost](), "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [BasicPost](), "Sorry. Something went wrong")
            }
        }
    }
    func getTopPosts(university_id: String, social_type: String, completion:@escaping (Bool, [Post], String) -> Void){
        let parameters = [
            "action" : "get_top_posts_of_day",
            "university_id" : university_id,
            "social_type" : social_type,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: PostResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let postsArray = result.data ?? [Post]()
                        completion(true, postsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[Post](), "Verify Error")
                    }
                    else{
                        completion(false, [Post](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [Post](),"Sorry. Something went wrong")
            }
        }
    }
    func getOnePost(post_id: String, social_type: String, completion:@escaping (Bool, [Post], String) -> Void){
        let parameters = [
            "action" : "get_one_post",
            "post_id" : post_id,
            "social_type" : social_type,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: PostResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let postsArray = result.data ?? [Post]()
                        completion(true, postsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[Post](), "Verify Error")
                    }
                    else{
                        completion(false, [Post](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [Post](),"Sorry. Something went wrong")
            }
        }
    }

    func addComment(post_id: String,comment:String, parent_id: String,social_type:String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "add_comment",
                "verify_key" : verify_key,
                "post_id" : post_id,
                "comment" : comment,
                "parent_id" : parent_id,
                "social_type" : social_type,
                "username" : loggedInUser().username,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
    func getComments(post_id: String,social_type:String, completion:@escaping (Bool, [Comment], String) -> Void){
        let parameters = [
            "action" : "get_comments",
            "post_id" : post_id,
            "social_type" : social_type,
            "user_id" : loggedInUser().id,
            "verify_key" : verify_key
        ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: CommentResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success" && result.data?.first != nil{
                        let postsArray = result.data ?? [Comment]()
                        completion(true, postsArray, "")
                    }
                    else if result.status == "verify_error"
                    {
                        completion(false,[Comment](), "Verify Error")
                    }
                    else{
                        completion(false, [Comment](),"Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, [Comment](),"Sorry. Something went wrong")
            }
        }
    }
    func updateCommentLike(comment_id: String,creator_id:String, like_action: String, completion:@escaping (Bool, String)->Void){
            let parameters = [
                "action" : "update_comment_like",
                "verify_key" : verify_key,
                "comment_id" : comment_id,
                "creator_id" : creator_id,
                "like_action" : like_action,
                "username" : loggedInUser().username,
                "user_id" : loggedInUser().id
            ]
        alamofireManager.request(BASE_URL,method: .get,parameters: parameters).responseDecodable(of: StatusResponse.self) { response in
            switch response.result{
                case .success(let result):
                    if result.status == "success"{
                        completion(true, "")
                    }
                    else{
                        completion(false, "Sorry. Something went wrong")
                    }
                case .failure(let error):
                    print(error)
                    completion(false, "Sorry. Something went wrong")
            }
        }
    }
}

//extension UILabel {
//    func addCharacterSpacing(kernValue: Double = 1.1) {
//    if let labelText = text, labelText.count > 0 {
//      let attributedString = NSMutableAttributedString(string: labelText)
//        attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
//      attributedText = attributedString
//    }
//  }
//}
extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        return image.withRenderingMode(self.renderingMode)
    }
}
extension UILabel {

    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }

            attributedString.addAttribute(NSAttributedString.Key.kern,
                                           value: newValue,
                                           range: NSRange(location: 0, length: attributedString.length))

            attributedText = attributedString
        }

        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}
extension UIButton{

    @IBInspectable
     var letterSpacing: CGFloat {
         set {
             let attributedString: NSMutableAttributedString
             if let currentAttrString = attributedTitle(for: .normal) {
                 attributedString = NSMutableAttributedString(attributedString: currentAttrString)
             }
             else {
                 attributedString = NSMutableAttributedString(string: self.title(for: .normal) ?? "")
                 setTitle(.none, for: .normal)
             }

             attributedString.addAttribute(NSAttributedString.Key.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length - 1))
             setAttributedTitle(attributedString, for: .normal)
         }
         get {
             if let currentLetterSpace = attributedTitle(for: .normal)?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                 return currentLetterSpace
             }
             else {
                 return 0
             }
         }
     }
}
//extension UITextView{
//    func addTextSpacing(_ spacing: CGFloat){
//        let attributedString = NSMutableAttributedString(string: text!)
////        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: attributedString.length))
////        attributedString.addAttribute("\(self.font?.lineHeight)", value: 50, range: NSRange(location: 0, length: text!.characters.count))
//        let attrs: [NSAttributedString.Key : Any] = [.kern: spacing,
//                                                     .font: self.font as Any]
//        self.attributedText = NSAttributedString(string: text!, attributes: attrs)
//
//        attributedText = attributedString
//    }
//}
func resizeImage(image: UIImage, targetSize: CGSize = CGSize(width: 800, height: 800)) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
func getSimpliedCountString(_ count: String) -> String{
    let count_int = Int(count)
    if count_int ?? 0 > 1000{
        if count_int! >= 10000
        {
            if count_int! >= 1000000
            {
                let float_count = Double(count_int!) / 1000000.0
                let converted = round(float_count * 10) / 10
                return "\(converted)m"

            }
            else{
                return "\(count_int! / 1000)k"
            }
        }
        else{
            let float_count = Double(count_int!) / 1000.0
            let converted = round(float_count * 10) / 10
            return "\(converted)k"

        }
    }
    else{
        return "\(count_int ?? 0)"
    }
//    return ""
}
func getInstagramPostId(_ mediaId: String?) -> String? {
  var postId = ""
  do {
    let myArray = mediaId?.components(separatedBy: "_")
    let longValue = "\(String(describing: myArray?[0]))"
    var itemId = Int(Int64(longValue) ?? 0)
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    while itemId > 0 {
      let remainder: Int = itemId % 64
      itemId = (itemId - remainder) / 64
      
      let charToUse = alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(remainder))]
      postId = "\(charToUse)\(postId)"
    }
  }
  return postId
}
func getTimeString(time:String)->String{
    let timeDouble = Double(time) ?? 0
    let difference = Date().timeIntervalSince1970 - timeDouble
    if difference < 60 {
        return "Just now"
    }else if difference < 60*60{
        return "\(Int(difference/60))m ago"
    }else if difference < 60*60*24{
        return "\(Int(difference/3600))h ago"
    }else if difference < 60*60*24*7{
        return "\(Int(difference/3600/24))d ago"
    }else{
        return "\(Int(difference/3600/24/7))w ago"
    }
}
