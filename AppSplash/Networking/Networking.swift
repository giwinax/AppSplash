//
//  Networking.swift
//  AppSplash
//
//  Created by s b on 29.04.2022.
//

import Alamofire
import SwiftyJSON

final class Networking {
    // MARK: - Fetch Details
    func fetchDetails(id: String, completion: @escaping (Result<(name: String, date: NSDate, location: String, downloads: String, largeImage: UIImage), Error>) -> Void) {
        
        AF.request("https://api.unsplash.com/photos/\(id)?client_id=dyPSoF7QAMA9JFB7SmLipxh7eJowBSb-_qSrnQQwnBE").responseJSON { response in
            
            switch response.result {
            
            case .success(let value):
            
                let json = JSON(value)
                
                AF.request(json["urls"]["full"].stringValue).responseData { responseTwo in
             
                    switch responseTwo.result {
                    
                    case .success(let dataTwo):
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let date: NSDate? = dateFormatter.date(from: "\(json["created_at"])") as NSDate?
                       
                        let location = json["location"]["title"]
                        
                        completion(.success((name: json["user"]["name"].stringValue, date: date ?? NSDate(), location: location.stringValue == "" ? "Unknown location" : location.stringValue ,downloads: json["downloads"].stringValue, largeImage: UIImage(data: dataTwo)!)))
                   
                    case .failure(let errorMsg):
                    
                        completion(.failure(errorMsg))
                    }
                }
            
            case .failure(let errorMsg):
            
                completion(.failure(errorMsg))
            }
            
        }
    }
    
    
    // MARK: - Search
    func search(searchString: String, completion: @escaping (Result<[Photos], Error>) -> Void) {
      
        AF.request("https://api.unsplash.com/search/photos?client_id=dyPSoF7QAMA9JFB7SmLipxh7eJowBSb-_qSrnQQwnBE&per_page=10&page=1&query=\(searchString)").responseJSON { response in
            
            var result = [Photos]()
            
            var i = 0
            
            while i < 10 {
            
                switch response.result {
                
                case .success(let value):
                
                    let json = JSON(value)
                    
                    let imageURL = json["results"][i]["links"]["download"].stringValue
                    let phId = json["results"][i]["id"].stringValue
                    let phName = json["results"][i]["user"]["name"].stringValue
                    
                    AF.request(imageURL).responseData { responseTwo in
                    
                        switch responseTwo.result {
                        
                        case .success(let dataTwo):
                        
                            result.append(Photos(id: phId, name: phName, image: UIImage(data: dataTwo)!))
                            completion(.success(result))
                        
                        case .failure(let errorMsg):
                        
                            completion(.failure(errorMsg))
                        }
                    }
                    
                    completion(.success(result))
                
                case .failure(let errorMsg):
                
                    completion(.failure(errorMsg))
                }
                i = i + 1
            }
        }
    }
    
    // MARK: - Fetch Ranndom
    func getRandom(completion: @escaping (Result<[Photos], Error>) -> Void) {
        
        AF.request("https://api.unsplash.com/photos/random?client_id=dyPSoF7QAMA9JFB7SmLipxh7eJowBSb-_qSrnQQwnBE&count=10").responseJSON { response in
        
            var result = [Photos]()
           
            var i = 0
            
            while i < 10 {
            
                switch response.result {
                
                case .success(let value):
                
                    let json = JSON(value)
                    
                    let imageURL = json[i]["urls"]["thumb"].stringValue
                    let phId = json[i]["id"].stringValue
                    let phName = json[i]["user"]["name"].stringValue
                    
                    AF.request(imageURL).responseData { responseTwo in
                    
                        switch responseTwo.result {
                        
                        case .success(let dataTwo):
                        
                            result.append(Photos(id: phId, name: phName, image: UIImage(data: dataTwo)!))
                            completion(.success(result))
                        
                        case .failure(let errorMsg):
                        
                            completion(.failure(errorMsg))
                        }
                    }
                    
                    completion(.success(result))
                
                case .failure(let errorMsg):
                   
                    completion(.failure(errorMsg))
                }
                i = i + 1
            }
        }
    }
}
