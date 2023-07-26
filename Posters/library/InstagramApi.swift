//
//  InstagramApi.swift
//  Posters
//
//  Created by admin on 9/21/20.
//  Copyright © 2020 DolfinTeam. All rights reserved.
//

import UIKit

class InstagramApi {
	static let shared = InstagramApi()
	
	private let instagramAppID = "1176265633079772"
	private let redirectURIURLEncoded = "https%3A%2F%2Fwww.postersglobal.com%2F"
    
	private let redirectURI = "https://www.postersglobal.com/"
//	private let app_secret = "ca2b82a64daf4ef6911ce2e0df7d1593"
    private let app_secret = "5be12dc5d213f336dfcf253ab9a5ca72"

    
	private let boundary = "boundary=\(NSUUID().uuidString)"
	
	private enum BaseURL: String {
		case displayApi = "https://api.instagram.com/"
		case graphApi = "https://graph.instagram.com/"
	}
	
	private enum Method: String {
		case authorize = "oauth/authorize"
		case access_token = "oauth/access_token"
	}
	
	//MARK:- Constructor
	private init() {}
	
	//MARK:- Private Methods
	private func getFormBody(_ parameters: [[String : String]], _ boundary: String) -> Data {
		var body = ""
		let error: NSError? = nil
		for param in parameters {
			let paramName = param["name"]!
			body += "--\(boundary)\r\n"
			body += "Content-Disposition:form-data; name=\"\(paramName)\""
			if let filename = param["fileName"] {
				let contentType = param["content-type"]!
				var fileContent: String = ""
				do { fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)}
				catch {
					print(error)
				}
				if (error != nil) {
					print(error!)
				}
				body += "; filename=\"\(filename)\"\r\n"
				body += "Content-Type: \(contentType)\r\n\r\n"
				body += fileContent
			} else if let paramValue = param["value"] {
				body += "\r\n\r\n\(paramValue)"
			}
		}
		return body.data(using: .utf8)!
	}
	
	private func getTokenFromCallbackURL(request: URLRequest) -> String? {
		let requestURLString = (request.url?.absoluteString)! as String
		if requestURLString.starts(with: "\(redirectURI)?code=") {
			
			print("Response uri:",requestURLString)
			if let range = requestURLString.range(of: "\(redirectURI)?code=") {
				return String(requestURLString[range.upperBound...].dropLast(2))
			}
		}
		return nil
	}
	
	private func getMediaData(testUserData: InstagramTestUser, completion: @escaping (Feed) -> Void) {
		let urlString = "\(BaseURL.graphApi.rawValue)me/media?fields=id,caption&access_token=\(testUserData.access_token)"
		
		let request = URLRequest(url: URL(string: urlString)!)
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error in
			if let response = response {
				print(response)
			}
			do { let jsonData = try JSONDecoder().decode(Feed.self, from: data!)
				print(jsonData)
				completion(jsonData)
			}
			catch let error as NSError {
				print(error)
			}
		})
		task.resume()
	}
	
	//MARK:- Public Methods
	func authorizeApp(completion: @escaping (_ url: URL?) -> Void ) {
//		let urlString = "\(BaseURL.displayApi.rawValue)\(Method.authorize.rawValue)?client_id=\(instagramAppID)&redirect_uri=\(redirectURIURLEncoded)&scope=user_profile,user_media&response_type=code"
        let urlString = "\(BaseURL.displayApi.rawValue)\(Method.authorize.rawValue)?client_id=\(instagramAppID)&redirect_uri=\(redirectURIURLEncoded)&scope=user_profile&response_type=code"

		let request = URLRequest(url: URL(string: urlString)!)
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error in
			if let response = response {
				print(response)
				completion(response.url)
			}
		})
		task.resume()
	}
	
	func getTestUserIDAndToken(request: URLRequest, completion: @escaping (InstagramTestUser) -> Void){
		
		guard let authToken = getTokenFromCallbackURL(request: request) else {
			return
		}
		
		let headers = [
			"content-type": "multipart/form-data; boundary=\(boundary)"
		]
		let parameters = [
			[
				"name": "client_id",
				"value": instagramAppID
			],
			[
				"name": "client_secret",
				"value": app_secret
			],
			[
				"name": "grant_type",
				"value": "authorization_code"
			],
			[
				"name": "redirect_uri",
				"value": redirectURI
			],
			[
				"name": "code",
				"value": authToken
			]
		]
		
		var request = URLRequest(url: URL(string: BaseURL.displayApi.rawValue + Method.access_token.rawValue)!)
		
		let postData = getFormBody(parameters, boundary)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = postData
        
        request.httpShouldHandleCookies = false //added at May/2/2023
        
		let session = URLSession.shared
		let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
			if (error != nil) {
				print(error!)
			} else {

				do { let jsonData = try JSONDecoder().decode(InstagramTestUser.self, from: data!)
					print(jsonData)
					completion(jsonData)
				}
				catch let error as NSError {
					print(error)
                    let str = String(decoding: data!, as: UTF8.self)
                    print(str)
				}
				
			}
		})
		dataTask.resume()
	}

	
	func getInstagramUser(testUserData: InstagramTestUser, completion: @escaping (InstagramUser) -> Void) {
		let urlString = "\(BaseURL.graphApi.rawValue)\(testUserData.user_id)?fields=id,username&access_token=\(testUserData.access_token)"
		let request = URLRequest(url: URL(string: urlString)!)
		let session = URLSession.shared
		let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
			if (error != nil) {
				print(error!)
			} else {
				let httpResponse = response as? HTTPURLResponse
				print(httpResponse!)
			}
			do { let jsonData = try JSONDecoder().decode(InstagramUser.self, from: data!)
				completion(jsonData)
			}
			catch let error as NSError {
				print(error)
			}
		})
		dataTask.resume()
	}
	
	func getMedia(testUserData: InstagramTestUser, completion: @escaping (InstagramMedia) -> Void) {
		
		getMediaData(testUserData: testUserData) { (mediaFeed) in
			let urlString = "\(BaseURL.graphApi.rawValue + mediaFeed.data[1].id)?fields=id,media_type,media_url,username,timestamp&access_token=\(testUserData.access_token)"
			let request = URLRequest(url: URL(string: urlString)!)
			
			let session = URLSession.shared
			let task = session.dataTask(with: request, completionHandler: { data, response, error in
				if let response = response {
					print(response)
				}
				do { let jsonData = try JSONDecoder().decode(InstagramMedia.self, from: data!)
					print(jsonData)
					completion(jsonData)
				}
				catch let error as NSError {
					print(error)
				}
			})
			task.resume()
		}
	}
	
	func fetchImage(urlString: String, completion: @escaping (Data?) -> Void) {
		let request = URLRequest(url: URL(string: urlString)!)
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error in
			if let response = response {
				print(response)
			}
			completion(data)
		})
		task.resume()
	}
   
}
