//
//  ViewController.swift
//  Weather App
//
//  Created by Shereen H on 7/7/18.
//  Copyright © 2018 ShereenH. All rights reserved.
//

import UIKit
import SafariServices



class ViewController: UIViewController {
    
    struct Coord: Decodable{
        let lon : Double
        let lat : Double
        
        enum CodingKeys : String, CodingKey{
            case lon
            case lat
            
        }
    }
    
    struct Weather : Decodable {
        let id : Int
        let main : String
        let description : String
        let icon : String
        
        enum CodingKeys : String, CodingKey{
            case id
            case main
            case description
            case icon
            
        }
        
    }
    
    struct Main: Decodable {
        let temp: Float
        let pressure: Float
        let humidity: Float
        let temp_min : Float
        let temp_max : Float
        
        enum CodingKeys : String, CodingKey{
            case temp
            case pressure
            case humidity
            case temp_min
            case temp_max
            
        }
        
    }
    
    struct Wind: Decodable {
        let speed : Float
        let deg: Float
        
        enum CodingKeys : String, CodingKey{
            case speed
            case deg
        }
        
    }
    
    struct Clouds: Decodable {
        let all : Int
        
        enum CodingKeys : String, CodingKey{
            case all
            
        }
        
    }
    
    struct Sys : Decodable{
        let type : Int
        let id : Int
        let message : Float
        let country : String
        let sunrise : Int
        let sunset : Int
        
        enum CodingKeys : String, CodingKey{
            case type
            case id
            case message
            case country
            case sunrise
            case sunset
            
        }
        
    }
    
    struct Outtest: Decodable {
        let coord: Coord
        let weather : [Weather]
        let base: String
        let main: Main
        let visibility : Int
        let wind : Wind
        let clouds : Clouds
        let sys : Sys
        let id : Int
        let name : String
        let cod : Int
        
        enum CodingKeys : String, CodingKey{
            case coord
            case weather
            case base
            case main
            case visibility
            case wind
            case clouds
            case sys
            case id
            case name
            case cod
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addVideoTextField: UITextField!
    
    var weatherList: [Outtest] = []
    
    var weatherItem1 : Outtest!
    
    var city = "London"
    
    
    //var videos: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func insertNewVideoTitle(_ text: String) {
        
        print("rake this please: \(text)")
        if addVideoTextField.text!.isEmpty {
            print("Add Video Text Field is empty")
        }
        weatherList.append(weatherItem1)
        //videos.append(addVideoTextField.text!)
        
        let indexPath = IndexPath(row: weatherList.count - 1, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        addVideoTextField.text = ""
        view.endEditing(true)
    }
    
    
    @IBAction func addCity(_ sender: Any) {
        
        city = (addVideoTextField.text!).replacingOccurrences(of: " ", with: "%20")
        updateIP()
        //insertNewVideoTitle()
    }
    
    //MARK: - REST calls
    // This makes the GET call to httpbin.org. It simply gets the IP address and displays it on the screen.
    func updateIP() {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = "https://api.openweathermap.org/data/2.5/weather?q="+self.city+"&appid=c0ab963717343ca50ce1fb9be23b5fb2"
        //"https://httpbin.org/ip"
        let session = URLSession.shared
        let url = URL(string: postEndpoint)!
        
        // Make the POST call and handle it in a completion handler
        session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                guard let blog = try? JSONDecoder().decode(Outtest.self, from: data!) else {
                    print("Error: Couldn't decode data into Outtest")
                    return
                }
                
                self.weatherItem1 = blog
                
                print("See this:\nName: \(blog.base) and \(blog.coord.lat)\nand Country \(blog.sys.country) and \(blog.weather[0].main)\n")
                self.performSelector(onMainThread: #selector(ViewController.insertNewVideoTitle(_:)), with: blog.base, waitUntilDone: false)
                
                //insertNewVideoTitle(blog)
                
                //self.weatherList.append(blog)
                
                for i in self.weatherList{
                    print("\(i.name) and \(i.sys.country) and \(i.weather[0].main)")
                }
                
                
                if let ipString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue) {
                    // Print what we got from the call
                    print(ipString)
                    
                    // Parse the JSON to get the IP
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    
                    let origin = jsonDictionary["base"] as! String
                    
                    print("Result:"+origin)
                    
                    // Update the label
                    //self.performSelector(onMainThread: #selector(ViewController.updateIPLabel(_:)), with: origin, waitUntilDone: false)
                }
            } catch {
                print("bad things happened")
            }
        } ).resume()
    }
    
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let weatherItem = weatherList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
        let mytemp = weatherItem.main.temp*(9.0/5.0)-459.67
        var thisImage = "clouds"
        
        if String(weatherItem.weather[0].description).lowercased().range(of:"cloud") != nil {
            thisImage = "clouds"
        }else if String(weatherItem.weather[0].description).lowercased().range(of:"sun") != nil{
            thisImage = "sun"
        }else if String(weatherItem.weather[0].description).lowercased().range(of:"rain") != nil{
            thisImage = "rain"
        }else if String(weatherItem.weather[0].description).lowercased().range(of:"thunderstorm") != nil{
            thisImage = "rain"
        }else if String(weatherItem.weather[0].description).lowercased().range(of:"snow") != nil{
            thisImage = "snowflake"
        }else{
            thisImage = "sun_cloudy"
        }
        
        cell.country.text = weatherItem.sys.country
        cell.city.text = weatherItem.name
        cell.temp.text = String(format:"%.1f",mytemp)+" °F"
        cell.desc.text = String(weatherItem.weather[0].description)
        cell.hum.text = "Hm: "+String(weatherItem.main.humidity)+"%"
        cell.pres.text = "Pr: "+String(weatherItem.main.pressure)+" hPa"
        cell.win.text = "Wn: "+String(weatherItem.wind.speed)+" mps"
        cell.icon.image = UIImage(named:thisImage+".png")
    
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            weatherList.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}



