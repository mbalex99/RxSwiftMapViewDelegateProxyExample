//
//  ViewController.swift
//  RxSwiftMapViewDelegateProxyExample
//
//  Created by Maximilian Alexander on 12/3/15.
//  Copyright © 2015 Epoque. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    
    var mapView : MKMapView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView(frame: self.view.frame)
        view.addSubview(mapView)
        
        let coordinateLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 50))
        view.addSubview(coordinateLabel)
        
        mapView.rx_regionDidChangeAnimated
            .subscribeNext { (animated: Bool) -> Void in
                print("Map Region Did Change \(animated)")
            }
            .addDisposableTo(disposeBag)
        
        mapView.rx_centerDidChange
            .map { (coord) -> String in
                return "center is at  \(coord.latitude) , \(coord.longitude)"
            }
            .bindTo(coordinateLabel.rx_text)
            .addDisposableTo(disposeBag)
        
    }
}

