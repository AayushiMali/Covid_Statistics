//
//  ViewController.swift
//  FinalExam
//
//  Created by Student on 2020-04-18.
//  Copyright © 2020 Student. All rights reserved.
//

import UIKit
import CoreLocation
import Charts
import MapKit

struct Covid19: Codable{
    let totalConfirmed: Int
    let totalDeaths: Int
    let totalRecovered: Int
    let areas: [Areas]
}
struct Areas: Codable{
    let totalConfirmed: Int
    let displayName: String
    let long: Double
    let lat: Double
    let totalDeaths: Int?
    let totalRecovered: Int?
    let totalDeathsDelta: Int?
    let totalRecoveredDelta: Int?
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    var currentLongitude: Double?
    var currentLatitude: Double?
    var currentLocation : CLLocation?
    
    
    let lm = CLLocationManager()
    var distTemp = 0.0
    var countryName1 : String = ""
    var distanceArray = [CLLocationDistance]()
    var index : Int?
    
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var totalCount: UILabel!
    @IBOutlet weak var recoveredCount: UILabel!
    @IBOutlet weak var deathCount: UILabel!
    @IBOutlet weak var recoverPercentage: UILabel!
    @IBOutlet weak var deathPercentage: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var countryName: UILabel!
    
    @IBOutlet weak var countryTotalCount: UILabel!
    
    @IBOutlet weak var countryRecoverCount: UILabel!
    
    
    @IBOutlet weak var countryDeathCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lm.delegate = self
        lm.requestWhenInUseAuthorization()
        self.lm.startUpdatingLocation()
        
        decodeCovidJSON()
        
    }
    
    func decodeCovidJSON()->Void{
        
        let urlString = "https://www.bing.com/covid/data"
        /* step 2 create url session */
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)
        if let url = url
        {
            /* step 3 give URL session a data task */
            let dataTask = urlSession.dataTask(with: url)
            {
                (data, respose, error) in
                if let data = data
                {
                    let jsonDecoder = JSONDecoder()
                    
                    do {
                        let readableData = try jsonDecoder.decode(Covid19.self, from: data)
                        
                        for i in 0..<readableData.areas.count
                        {
                            
                            let countryLocation = CLLocation(latitude: readableData.areas[i].lat, longitude: readableData.areas[i].long)
                            print(self.currentLocation!)
                            print(countryLocation)
                            let distance = self.currentLocation!.distance(from: countryLocation)
                            self.distanceArray.append(distance)
                            let minDistance = self.distanceArray.min()
                            let j = self.distanceArray.firstIndex(of: minDistance!)
                            print(j!)
                            self.index = j!
                            
                            
                        }
                        self.displayCovidData(readableData)
                        self.displayChart(readableData)
                        
                    }
                    catch
                    {
                        print("Unable to Decode")
                    }
                }
            }
            /* step 4 start data task */
            dataTask.resume()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last
        {
            currentLocation = location
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            
            print(currentLatitude!)
            print(currentLongitude!)
        }
        else
        {
            print("location data not found!")
        }
        
    }
    
    func displayCovidData(_ readableData: Covid19)
    {
        DispatchQueue.main.async{
            self.totalCount.text = String(readableData.totalConfirmed)
            self.recoveredCount.text = String(readableData.totalRecovered)
            self.deathCount.text =  String(readableData.totalDeaths)
            self.recoverPercentage .text =  String(((readableData.totalDeaths)*100)/readableData.totalConfirmed) + " %"
            self.deathPercentage.text =  String(((readableData.totalRecovered)*(100))/(readableData.totalConfirmed)) + " %"
            self.countryName.text = readableData.areas[(self.index)!].displayName
            self.countryTotalCount.text = String(readableData.areas[(self.index)!].totalConfirmed)
            self.countryRecoverCount.text = String(readableData.areas[(self.index)!].totalRecovered!)
            self.countryDeathCount.text = String(readableData.areas[(self.index)!].totalDeaths!)
        }
        
    }
    func displayChart(_ readableData: Covid19){
        let d1 = BarChartDataEntry(x: 1, y: Double(readableData.totalRecovered))
        let d2 = BarChartDataEntry(x: 2, y: Double(readableData.totalDeaths))
        let d3 = BarChartDataEntry(x: 3, y: Double(readableData.totalConfirmed))
        
        let dataSet = BarChartDataSet(entries: [d1,d2,d3], label: "CovidData")
        
        dataSet.colors = [.systemGreen,.systemRed,.systemBlue]
        
        let data = BarChartData(dataSet: dataSet)
        
        DispatchQueue.main.async {
            self.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["X axis","Y axis","Z axis"])
            self.barChart.data = data
        }
    }
}



