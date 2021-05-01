# Carpool-App
An iOS social networking app that let users carpool with other users.

# Table of Contents

* [Summary](#summary)
* [Technical Implementation](#technical-implementation)
* [Screenshots](#screenshots)

## <a name="summary"></a>Summary

CarPool App is a carpooling or ridesharing based social networking application that allows registered and verified users to be drivers or riders. 
Anybody could be a rider or a driver this is what sets it apart from cab hailing companies like Uber or Lyft. 
Carpooling is an activity deemed towards protecting the environment, users heading in the same direction can pair up with each other and drive each other to a mutual location thereby saving natural resources like gas and reducing air pollution.
The process is fairly simple. The app will only have one module that works as both driver and rider.

### Driver
For somebody who will be driving that day:
* He/she enters his starting location.
* He/she enters their destination.
* He/she enters time of departure.
* A record for this ride is created in the database and is shown to all users.
* Once a ride has been established, the driver and rider can chat from within the app and
when the ride is done they can provide a rating for each other.


### Passenger
For somebody who needs a ride:
* He/she scans through the list of available carpools.
* Can sort based on time, leaving nearest from his/her current location, or to a specific
destination.
* On selecting a carpool, a confirmation message is sent out to the driver.
* Once a ride has been established, the driver and rider can chat from within the app and
when the ride is done they can provide a rating for each other.


## <a name="technical-implementation"></a>Technical Implementation

### Apple Frameworks
* MapKit
* APNS

### Third-Libraries
* Firebase
* FacebookAuth
* GoogleSignIn
* JSQMessagesViewController
* Geofire 
* FCAlertView

## <a name="screenshots"></a> Screenshots

### Home Screen
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/HomeScreen_iphone7plusspacegrey_portrait.png)

### Request A Ride
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/RequestARide_iphone7plusspacegrey_portrait.png)

### Select A Ride
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/SelectARide_iphone7plusspacegrey_portrait.png)

### Profile 
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/ProfileView_iphone7plusspacegrey_portrait.png)

### Driver Info
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/DriverInfo_iphone7plusspacegrey_portrait.png)

### Messaging
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/MessagesDemo_iphone7plusspacegrey_portrait.png)

### User Rating
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/UserRatings_iphone7plusspacegrey_portrait.png)

### Push Notifications
![alt text](https://github.com/rpramirez87/Carpool-App/blob/master/DemoLibrary/PushNotification_iphone7plusspacegrey_portrait.png)

