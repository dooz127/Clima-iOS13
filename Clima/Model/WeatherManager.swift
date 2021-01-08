//
//  WeatherManager.swift
//  Clima
//
//  Created by Duy Nguyen on 1/7/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3febbc42aebd53f9ade33074f25213b6&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(WeatherData.self, from: safeData)
                        let id = decodedData.weather[0].id
                        let temp = decodedData.main.temp
                        let name = decodedData.name
                        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                        
                        delegate?.didUpdateWeather(self, weather)
                    } catch {
                        delegate?.didFailWithError(error: error)
                    }
                }
                
            }
            
            // 4. Run the task
            task.resume()
        }
    }
    
}
