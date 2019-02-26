//
//  ViewController.swift
//  WeatherInfoLAB11
//
//  Created by iosdev on 06/02/2019.
//  Copyright © 2019 iosdev. All rights reserved.
//
//GITHUB

import UIKit


//Creating structs to match the JSON response we get to decode the JSON data easily
struct WeatherInfoJson: Decodable {
    let weather: [Weather]
    let main: Main
    let visibility: Int?
    let name: String
}


struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Decodable {
    let temp: Double
    let pressure: Double
    let humidity: Int
    let temp_min: Double
    let temp_max: Double
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //Pickerview datasource array of List of cities
    
    private let citiesDataSource:[String] = ["Beijing","Helsinki","Kathmandu","London","New York","Miami","Mumbai","San Fransisco","Tokyo"]
    
    
    //MARK: Properties
    @IBOutlet weak var loactionLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationPickerView: UIPickerView!
    @IBOutlet weak var backgroundView: UIView!
    
    let gradientLayer = CAGradientLayer()
    let apiKey = "b02a50898127503881904f265031b447"
    var cityName = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        //Using Observer pattern instead of delegate protocol
        NotificationCenter.default.addObserver(self, selector: #selector(getWeatherData), name: NSNotification.Name("UPDATEWEATHERINFO"), object: nil)
        
        locationPickerView.dataSource = self
        locationPickerView.delegate = self
        cityName = citiesDataSource[0]
        getWeatherData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setGreyGradientBackground()
    }
    
    
    //MARK: UIPickerViewDataSource
    //Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return citiesDataSource.count
    }
    
    //MARK: UIPickerViewDelegate
    //Capture the pickerviewselection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cityName = citiesDataSource[row]
        NotificationCenter.default.post(name: NSNotification.Name("UPDATEWEATHERINFO"), object: nil, userInfo: nil)
    }
    
    //Data for component selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(citiesDataSource[row])
    }
    
    
    
    
    
    
    //MARK: Private Methods
    
    @objc func getWeatherData() {
        //Replacing any space characters in city's name with "%20"
        guard let newCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            fatalError("City Name consists of invalid charaters for url")
        }
        //Fetching data from the api
        //Create a URL object
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(newCityName)&appid=\(apiKey)&units=metric") else {
            fatalError("Failed to create URL")
        }
        print(url)
        //Create URLSession dataTask
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //Handling data
            if let dataRecieved = data {
                do{
                    let weatherInfo = try JSONDecoder().decode(WeatherInfoJson.self, from: dataRecieved)
                    
                    
                    DispatchQueue.main.async {
                        //In here you could call a method that updates the UI as this closure is dispatched to the main queue
                        
                        let iconName = weatherInfo.weather[0].icon
                        self.loactionLabel.text = weatherInfo.name
                        self.conditionImageView.image = UIImage(named: iconName)
                        self.conditionLabel.text = weatherInfo.weather[0].main
                        self.tempLabel.text = "\(Int(round(weatherInfo.main.temp)))"
                        
                        //Sets the day
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        self.dayLabel.text = dateFormatter.string(from: date)
                        
                        //Sets the icon image
                        let suffix = iconName.suffix(1)
                        print(iconName)
                        if(suffix == "n"){
                            self.setGreyGradientBackground()
                        }else{
                            self.setBlueGradientBackground()
                        }
                    }
                    
                    
                    
                    print(weatherInfo.main.temp ,weatherInfo.weather[0].description)
                    
                } catch {
                    print("Error seralizing json: \(error)")
                }
            }
            
        }
        //Calling resume to start the task
        task.resume()
    }
    
    
    
    //Sets the gradient of background view to blue
    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    //Sets the gradient of background view to grey
    func setGreyGradientBackground(){
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    
    
    
    
}

