//
//  APIService.swift
//  URLSession_Practice
//
//  Created by 이차민 on 2021/09/08.
//

import Foundation

class APIHandler {
    func getNASAData(completion: @escaping (SpaceData) -> ()) {
        let key = "eaScc7VpbvURyzMwbRzbFsik2vjZpdKV3ncAI3Pv"
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(key)")!
        let requestURL = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    let parsedData = try JSONDecoder().decode(SpaceData.self, from: data)
                    completion(parsedData)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }.resume()
    }
}
