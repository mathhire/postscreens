//
//  CPSocialVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import SVProgressHUD
import TikTokOpenSDK
import WebKit

class CPSocialVC: UIViewController {
    var isFromSetting = false
    @IBOutlet weak var btn_social3: UIButton!
    @IBOutlet weak var btn_social2: UIButton!
    @IBOutlet weak var btn_social1: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var instagramConnectView: UIView!
    @IBOutlet weak var m_wvInstagram: WKWebView!
    var instagram_username = ""
    @IBOutlet weak var btn_back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromSetting{
            btn_next .setTitle("Done", for: .normal)
            if DataManager.shared.loggedInUser().tiktok != ""
            {
                btn_social1.isSelected = true
            }
            if DataManager.shared.loggedInUser().instagram != ""
            {
                btn_social2.isSelected = true
            }
            
        }
        else{
            btn_back.isHidden = true
        }
        if(!btn_social1.isSelected && !btn_social2.isSelected)
        {
            btn_next.isHidden = true
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if !btn_social1.isSelected && !btn_social2.isSelected
        {
            return
        }
        if(isFromSetting)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else{
            let actionSheetAlertController: UIAlertController = UIAlertController(title: "Registered Successfully.", message: "", preferredStyle: .alert)
            let cancelActionButton = UIAlertAction(title: "OK", style: .cancel) { action in
                justRegistered = true
                self.navigationController?.popToRootViewController(animated: false)

            }
            actionSheetAlertController.addAction(cancelActionButton)

            self.present(actionSheetAlertController, animated: true, completion: nil)
        }
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPUniveresityVC") as! CPUniveresityVC
//        self.navigationController?.pushViewController(vc, animated: true)
        

    }
    func showConfirmDialogForTikTokRemoval()
    {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Are you sure you want to remove your TikTok account?", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes, I am sure.", style: .destructive) { (action) in
            self.callDeleteAPI(social: "tiktok")
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)

    }
    func showConfirmDialogForInstagramRemoval()
    {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Are you sure you want to remove your Instagram account?", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes, I am sure.", style: .destructive) { (action) in
            self.callDeleteAPI(social: "instagram")
        }

          actionSheetAlertController.addAction(action)
        

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)

        self.present(actionSheetAlertController, animated: true, completion: nil)

    }
    func callDeleteAPI(social: String){
        SVProgressHUD.show()
        DataManager.shared.delete_social(social: social){ success, message in
            SVProgressHUD.dismiss()
            if success{
                if social == "tiktok"{
                    self.btn_social1.isSelected = false
                }
                else if social == "instagram"
                {
                    self.btn_social2.isSelected = false
                }
                shouldReloadProfile = true
            }else{
                self.view.makeToast(message)
            }
        }
    }

    @IBAction func connectTikTokBtnTapped(_ sender: Any) {
        if btn_social1.isSelected{
            self.showConfirmDialogForTikTokRemoval()
            return
        }
        
        /* STEP 1: Create the request and set permissions */
        let scopes = ["user.info.basic","video.list"] // list your scopes
        let scopesSet = NSOrderedSet(array:scopes)
        
        let request = TikTokOpenSDKAuthRequest()
        request.permissions = scopesSet

        /* STEP 2: Send the request */
        request.send(self, completion: { resp -> Void in
            print("\(resp.errCode)")
            print("\(resp)")
            
            /* STEP 3: Parse and handle the response */
            if resp.errCode == TikTokOpenSDKErrorCode.success
            {
                let responseCode = resp.code
                
                
                // replace this baseURLstring with your own wrapper API
                let baseURlString = "https://open-api.tiktok.com/oauth/access_token/?code=\(responseCode ?? "")&client_key=\(tiktokClientKey)&client_secret=\(tiktokClientSecret)&grant_type=authorization_code"
                let url = NSURL(string: baseURlString)

                /* STEP 3.b */
                let session = URLSession(configuration: .default)
                let urlRequest = NSMutableURLRequest(url: url! as URL)
                let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) -> Void in
//                    let strData = String(data: data ?? Data(), encoding: .utf8)
//                    let strDict =
                    do{
                        let strDict = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? [String:Any]
                        if strDict?["message"] as? String == "success", let dataBodyDict = strDict?["data"] as? [String:Any],let access_token = dataBodyDict["access_token"] as? String{
                            print(access_token)
                            self.getTikTokProfileInfo(access_token: access_token)
                        }
                        else{
                            DispatchQueue.main.async {
                                
                                self.view.makeToast("Something went wrong when authenticating with Tiktok")
                            }
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            
                            self.view.makeToast("Something went wrong when authenticating with Tiktok")
                        }
                    }
                    
                     /* STEP 3.c */
                }
                task.resume()
            
                // Upload response code to your server and obtain user access token
            } else {
                DispatchQueue.main.async {
                    
                    self.view.makeToast("Something went wrong when authenticating with Tiktok")
                }
                // User authorization failed. Handle errors
            }
        })
                     
    }
    func getTikTokProfileInfo(access_token: String)
    {
//        let headers = [
//          "Accept": "application/json",
//          "AccessKey": "8d68b373-3db4-439d-a4b10788c40f-33e8-406e"
//        ]
//
        SVProgressHUD.show()
        let baseURlString = "https://open.tiktokapis.com/v2/user/info/?fields=open_id,username,union_id,avatar_url,display_name,profile_deep_link,follower_count,likes_count,is_verified,secret"
        let url = NSURL(string: baseURlString)
        let session = URLSession(configuration: .default)
        
        let urlRequest = NSMutableURLRequest(url: url! as URL)
        urlRequest.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) -> Void in
            SVProgressHUD.dismiss()
            do{
                let strDict = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? [String:Any]
                if let errorDict = strDict?["error"] as? [String:Any], errorDict["code"] as? String == "ok", let dataBodyDict = strDict?["data"] as? [String:Any],let userDict = dataBodyDict["user"] as? [String:Any]{
            
                        let profile_name = userDict["username"]
                        let follower_count = userDict["follower_count"] as! Int
//                    self.updateTiktokInfo(display_name: profile_name as! String , num_follower: follower_count)
                    self.getUserInfoViaRapidAPIToCheckPrivateAccount(display_name: profile_name as! String , num_follower: follower_count)

                }
                else{
                    DispatchQueue.main.async {
                        self.view.makeToast("Something went wrong when getting the profile info")
                    }
                }
            }
            catch{
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.view.makeToast("Something went wrong when getting the profile info")
                }
            }
            
            
        }
        task.resume()
    }
    func getUserInfoViaRapidAPIToCheckPrivateAccount(display_name:String, num_follower:Int)
    {
        SVProgressHUD.show()
        let headers = [
            "X-RapidAPI-Key": "13ce78f709msh61fb00a0a4e832ap1a1518jsnd052920cf6b6",
            "X-RapidAPI-Host": "tiktok-video-no-watermark2.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://tiktok-video-no-watermark2.p.rapidapi.com/user/info?unique_id=\(display_name)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            SVProgressHUD.dismiss()
            if (error != nil) {
//                print(error)
                self.view.makeToast("Something went wrong when checking the account's private/public status")

            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
                do{
                    let strDict = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? [String:Any]
//                    print("\(strDict)")
                    if  strDict?["code"] as?Int == 0, let dataBodyDict = strDict?["data"] as? [String:Any],let userDict = dataBodyDict["user"] as? [String:Any]{
                
                        let secret = userDict["secret"] as! Bool
                        if !secret {
                            self.updateTiktokInfo(display_name: display_name , num_follower: num_follower)
                        }
                        else{
                            self.showPrivateAccountAlert()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.view.makeToast("Something went wrong when checking the account's private/public status")
                        }
                    }

                }
                catch{
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.view.makeToast("Something went wrong when checking the account's private/public status")
                    }
                }
                
                
            }
        })

        dataTask.resume()
    }
    func updateTiktokInfo(display_name:String, num_follower:Int)
    {
        let numFollowerStr = "\(num_follower)"
        SVProgressHUD.show()
        DataManager.shared.updateTikTokInfo(display_name: display_name, num_follower: numFollowerStr){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.btn_social1.isSelected = true
                self.btn_next.isHidden = false
                if self.isFromSetting{
                    shouldReloadProfile = true
                }
                self.view.makeToast("Connected successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }
            }else{
                self.view.makeToast(message)
            }
        }

    }
    func updateInstagramInfo(display_name:String, num_follower:Int)
    {
        SVProgressHUD.show()
        let numFollowerStr = "\(num_follower)"
        SVProgressHUD.show()
        DataManager.shared.updateInstagramInfo(display_name: display_name, num_follower: numFollowerStr){ success, message in
            SVProgressHUD.dismiss()
            if success{
                self.btn_social2.isSelected = true
                self.btn_next.isHidden = false
                if self.isFromSetting{
                    shouldReloadProfile = true
                }
                self.view.makeToast("Connected successfully.", duration: 2.5, position: .center, title: nil, image: nil, style: .init()) { didTap in
                }
            }else{
                self.view.makeToast(message)
            }
        }

    }

    func showPrivateAccountAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Please connect a public TikTok account", message: "Your tiktok account is a private account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    func showPrivateAccountAlertInstagram(){
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Please connect a public Instagram account", message: "Your Instagram account is a private account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    @IBAction func connectInstagramBtnTapped(_ sender: Any) {
        if btn_social2.isSelected{
            self.showConfirmDialogForInstagramRemoval()
            return
        }
        m_wvInstagram.clean {
            SVProgressHUD.show(withStatus: "Connecting...")
            
            InstagramApi.shared.authorizeApp { (url) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if let url = url {
                        print(">>> instagram - ", url)
                        self.instagramConnectView.isHidden = false
                        self.view.bringSubviewToFront(self.instagramConnectView)
                        self.m_wvInstagram.navigationDelegate = self
                        let request = URLRequest(url: url)
                        self.m_wvInstagram.load(request)
                    }
                }
            }
        }
    

    }
    
    @IBAction func connectTwitterBtnTapped(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Connecting...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.btn_social3.isSelected = true
            SVProgressHUD.dismiss()
        }
    }
    
    
    @IBAction func backFromInstagramConnectView(_ sender: Any) {
        self.instagramConnectView.isHidden = true
    }
    func getInstagramInfo(instagram_username: String)
    {
        SVProgressHUD.show()
        let headers = [
            "X-RapidAPI-Key": "13ce78f709msh61fb00a0a4e832ap1a1518jsnd052920cf6b6",
            "X-RapidAPI-Host": "instagram-looter2.p.rapidapi.com"
        ]
        let strUrl = "https://instagram-looter2.p.rapidapi.com/profile?username=\(instagram_username)"
        let request = NSMutableURLRequest(url: NSURL(string: strUrl)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            SVProgressHUD.dismiss()
            if (error != nil) {
//                print(error)
            } else {
//                let httpResponse = response as? HTTPURLResponse
                do{
                    let strDict = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? [String:Any]
//                    print("\(strDict)")
                    if  strDict?["status"] as?Bool == true{
                        let isPrivate = strDict?["is_private"] as! Bool
                        if !isPrivate {
                            let follower_count_dict = strDict?["edge_followed_by"] as? [String:Any];
                            let follower_count = follower_count_dict!["count"] as? Int ?? 0
                            self.updateInstagramInfo(display_name: instagram_username , num_follower: follower_count)
                        }
                        else{
                            self.showPrivateAccountAlertInstagram()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.view.makeToast("Something went wrong when checking the account's private/public status")
                        }
                    }

                }
                catch{
                    print(error.localizedDescription)
                }            }
        })

        dataTask.resume()
    }
}
extension CPSocialVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        InstagramApi.shared.getTestUserIDAndToken(request: request) { (instagramTestUser) in
            print(">>> Instagram User: ", instagramTestUser)
            InstagramApi.shared.getInstagramUser(testUserData: instagramTestUser) { (instagramUser) in
                DispatchQueue.main.async {
                    print("\(instagramUser.username)")
                    self.instagram_username = instagramUser.username
                    self.getInstagramInfo(instagram_username: self.instagram_username)
//                    self.instagramUser = instagramUser.username
//                    self.m_btnInstagramUser.setTitle(self.instagramUser, for: .normal)
//                    self.isInstagramConnected = true
                }
            }
            DispatchQueue.main.async {
                self.instagramConnectView.isHidden = true
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}
extension WKWebView {

    func clean(completion : @escaping () -> Void) {
        
        guard #available(iOS 9.0, *) else {return}

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let dispatch_group = DispatchGroup()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                dispatch_group.enter()
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                    dispatch_group.leave()
                })
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
            dispatch_group.notify(queue: DispatchQueue.main) {
                completion() //
            }
        }
    }
}
