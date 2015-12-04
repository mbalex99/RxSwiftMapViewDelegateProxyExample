//
//  MKMapViewRxExtensions.swift
//  RxSwiftMapViewDelegateProxyExample
//
//  Created by Maximilian Alexander on 12/3/15.
//  Copyright © 2015 Epoque. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

class RxMKMapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let mapView: MKMapView = object as! MKMapView
        return mapView.delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: MKMapView = object as! MKMapView
        mapView.delegate = delegate as! MKMapViewDelegate
    }
}

extension MKMapView {
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxMKMapViewDelegateProxy
    }
    
    public var rx_regionDidChangeAnimated: Observable<Bool> {
        return rx_delegate.observe("mapView:regionDidChangeAnimated:")
            .map { params in
                return params[1] as! Bool
            }
    }
    
    public var rx_centerDidChange: Observable<CLLocationCoordinate2D> {
        return rx_regionDidChangeAnimated.map({ (animated) -> CLLocationCoordinate2D in
            return self.centerCoordinate
        })
    }
    
}