# RxSwiftMapViewDelegateProxyExample

This is a follow up to the Swift Meetup Group Topic on RxSwift

I mentioned that navigating traditional implementation of protocols can be very nasty with Rx.
Luckily swift allows you to add extension methods on top of existing classes to make the Rx - Compatible.

This example app shows how to navigate from Delegate implementations to Rx Observables using MKMapView and MKMapViewDelegate

We will be turning `func mapView(_ mapView: MKMapView,
regionDidChangeAnimated animated: Bool)` method into an `Observable<Bool>` property

In addition we'll add a simple `var rx_centerDidChange : Observable<CLLocationCoordinate2D>` extension property.
This will fire when the center changes.

We'll out put some data to the console as well as a UILabel right up top.


# Step 1 - Proxy Setup

Create a DelegateProxy class for MKMapView. This is just an Object that inherits `DelegateProxy`, `MKMapViewDelegate` and `DelegateProxyType`

```swift
import RxSwift
import RxCocoa

class RxMKMapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
    //We need a way to set the current delegate 
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let mapView: MKMapView = object as! MKMapView
        return mapView.delegate
    }
    //We need a way to set the current delegate 
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: MKMapView = object as! MKMapView
        mapView.delegate = delegate as! MKMapViewDelegate
    }
}
```

# Step 2 - Create the Extension Methods

```swift
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
```

# Step 3 - Listen for the Changes

Now you don't have to implement the delegate! Just observe the property right on the spot.

```swift
var mapView = MKMapView();
mapView.rx_centerDidChange
  .subscribeNext( (newCenterCoord) -> {
    // so do something with it already
  })
```
