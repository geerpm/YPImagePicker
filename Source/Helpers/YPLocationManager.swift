//
//  LocationManager.swift
//  YPImagePicker
//
//  Created by FunatoShuhei on 2018/01/26.
//  Copyright © 2018年 ytakzk. All rights reserved.
//

import Foundation
import CoreLocation

class YPLocationManager: NSObject, CLLocationManagerDelegate {
    
    let locManager: CLLocationManager!
    var lastLocation: CLLocation?
    var completion: ((CLLocation?) -> Void)?
    var isExcutingCompletion = false
    
    
    override init() {
        locManager = CLLocationManager()
        super.init()
        locManager.delegate = self
    }
    
    deinit {
        self.stopLocation()
    }
    
    func startLocation() {
        locManager.requestWhenInUseAuthorization()
    }
    
    func stopLocation() {
        locManager.stopUpdatingLocation()
    }
    
    func location(with completion: @escaping (CLLocation?) -> Void) {
        if let lastLocation = lastLocation {
            completion(lastLocation)
        
        } else {
            self.completion = completion
            locManager.requestLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            break
        case .denied:
//            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
//            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways, .authorizedWhenInUse:
            // 位置情報取得の開始処理
            locManager.startUpdatingLocation()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            lastLocation = locations.last
            
            self.doCompletionOnce()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.doCompletionOnce()
    }
    
    
    private func doCompletionOnce() {
        
        if let completion = completion {
            
            if !isExcutingCompletion {
                
                isExcutingCompletion = true
                completion(lastLocation)
                self.completion = nil
                isExcutingCompletion = false
            }
        }
    }
}
