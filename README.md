# RxSwiftMapViewDelegateProxyExample

This is a follow up to the Swift Meetup on RxSwift (#SLUG)

A lot of people asked me how to encapsulate delegate implementations into Rx nicely.
In other languages, you're usually forced to implement an entire class but Swift allows us
to add extensions!

This example app shows how to migrate from Delegate implementations to Rx `Observables<T>` using `MKMapView` and `MKMapViewDelegate`

We will be turning `func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)` method into an `Observable<Bool>` property

In addition we'll add a simple `var rx_centerDidChange : Observable<CLLocationCoordinate2D>` extension property.
This will fire when the center changes.

We'll out put some data to the console as well as a UILabel right up top.


# The Example Source Code is Complete, but here are the steps if you want to recreate the magical experience

## Step 1 - Proxy Setup

Create a DelegateProxy class for MKMapView. This is just an Object that inherits `DelegateProxy`, `MKMapViewDelegate` and `DelegateProxyType`

```swift
import RxSwift
import RxCocoa

class RxMKMapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
    //We need a way to read the current delegate 
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

## Step 2 - Create the Extension Methods

Okay now let's create an Extension for `MKMapView` and add the methods that we want.

1. We'll need a property of `rx_delegate` which is of the type we made above.
2. Create methods that listen to the delegates respective selectors

To translate
`func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)`

We will need to convert this function's selector into its string format. Here it is:

`"mapView:regionDidChangeAnimated:"`

The delegate proxy we made has a method called: `rx_observe` which takes a `selector string` like above and returns an `Array<Any?>`
This array contains the parameters passed down from that method. You will have to cast it appropriately based off of the documentation. 

The full extension code is below:

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

## Step 3 - Listen for the Changes

Now you don't have to implement the delegate! Just observe the property right on the spot.

```swift
var mapView = MKMapView();
mapView.rx_centerDidChange
  .subscribeNext{ newCenterCoord in
    // so do something with it already
  }
```

## Going forward
I hope this example shows you how you can leverage extensions to encapsulate Delegate listeners into consumable RxSwift Methods.

Follow this pattern and enjoy your bliss!
