//
//  ViewController.swift
//  MapUse
//
//  Created by 김현수 on 2020/09/15.
//  Copyright © 2020 Hyun Soo Kim. All rights reserved.
//

import UIKit
//지도 사용을 위한 프레임워크
import MapKit
//현재 위치를 가져오기 위한 프레임워크
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    //위치 정보 사용 객체의 참조를 저장할 변수
    var locationManager: CLLocationManager!
    
    //검색된 위치 정보를 저장할 배열을 생성
    var matchingItems = [MKMapItem]()
    
    //영역 객체를 저장할 변수
    var region: CLCircularRegion!
    //지도에 출력할 이미지 뷰
    var couponView: UIImageView!
    
    @IBAction func textFieldReturn(_ sender: Any) {
        //키보드 제거
        searchText.resignFirstResponder()
        
        //기존에 존재하던 어노테이션 제거
        mapView.removeAnnotations(mapView.annotations)
        
        //검색된 결과도 삭제
        matchingItems.removeAll()
        
        //검색 요청 객체 생성
        let request = MKLocalSearch.Request()
        //검색어 설정
        request.naturalLanguageQuery = searchText.text
        //검색 범위 설정
        request.region = mapView.region
        
        //실제 검색을 수행해 줄 객체를 생성
        let search = MKLocalSearch(request: request)
        //검색 요청
        search.start(completionHandler: {(response: MKLocalSearch.Response!, error: Error!) in
            if error != nil {
                NSLog("검색 실패")
            } else if response.mapItems.count == 0 {
                NSLog("검색 결과 없음")
            } else {
                NSLog("검색 결과 존재")
                //검색 결과 순회
                for item in response.mapItems as [MKMapItem] {
                    //배열에 검색된 내용을 추가
                    self.matchingItems.append(item as MKMapItem)
                    
                    //지도에 출력할 어노테이션 생성
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    //지도에 출력
                    self.mapView.addAnnotation(annotation)
                }
                
                //결과 출력화면으로 이동
                let resultListVC = self.storyboard?.instantiateViewController(identifier: "ResultListVC") as! ResultListVC
                resultListVC.mapItems = self.matchingItems
                self.navigationController?.pushViewController(resultListVC, animated: true)
            }
        })
    }
    
    @IBAction func zoom(_ sender: Any) {
        //현재 위치를 가져오기
        let userLocation = mapView.userLocation
        //현재 위치를 기준으로 영역을 생성
        let region = MKCoordinateRegion(center: userLocation.location!.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        
        //맵 뷰의 영역을 설정
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func type(_ sender: Any) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
        } else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "지도 출력"
        
        //위치 정보 객체 생성
        locationManager = CLLocationManager()
        //위치정보 사용 권한을 요청 - 실행 중일 때만 권한을 사용
        locationManager.requestWhenInUseAuthorization()
        
        //현재 위치를 지도에 표시하도록 설정
        mapView.showsUserLocation = true
        
        //맵 뷰의 Delegate 설정
        mapView.delegate = self
        
        //영역 설정
        let center = CLLocationCoordinate2D(latitude: 37.5690886, longitude: 126.984652)
        let maxDistance = 1000.0
        region = CLCircularRegion(center: center, radius: maxDistance, identifier: "종로")
        
        //위치 정보 옵션 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        //영역 감시를 시작
        locationManager.startMonitoring(for: region)
        
        //이미지 뷰 생성
        couponView = UIImageView(image: UIImage(named: "coupon.png"))
        couponView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    //사용자의 위치 정보가 갱신된 경우 호출되는 메소드
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    //영역 안에 들어오면 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        mapView.addSubview(couponView)
    }
    
    //영역에서 벗어나면 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        couponView.removeFromSuperview()
    }
}
