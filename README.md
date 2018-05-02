# iOS-App-And-Server-Capstone

  This is an app built with Swift that is designed to be an interface for service industry apps. 

  It fetches data from a Node.js server through Socket.io, the server uses Socket.io emit event handling in a custom built API, and the app's data is stored in a MySQL database.

  To run this app, you'll want to install Node.js v9.9.0, MySQL v5.7.21, Cocoapods v1.4.0, Xcode 9.3, and the Swift 4 implementation of Socket.io. That's what I built it on.

I would start with the installation instructions on this page:

https://medium.com/@spiromifsud/realtime-updates-in-ios-swift-4-using-socket-io-with-mysql-and-node-js-de9ae771529

Installation excerpt from the article:

"MySQL (executable .pkg installer) 

https://dev.mysql.com/downloads/mysql/5.1.html#macosx-dmg

Node.js and NPM (from the Terminal)

`$ brew install node`

Express (from the Terminal)

`$ npm install express --save`

Node MySQL Driver (from the Terminal)

`$ npm install mysql --save`

Socket.IO (from the Terminal)

`$ npm install socket.io --save"`


Here are a few hiccups and tips for following the steps above:


`cd` = change directory

`ls` = list all items in current working directory

`cd ..` goes to parent folder


To log into mysql server:

`/usr/local/mysql/bin/mysql -u root -p`


//podfile installation may not be required

Must *init* cocoa pods in same folder as *.xcodeproject* file

Must *install* cocoa pods in same folder as *project.swift* files


Cannot load underlying module for 'SocketIO’ - - - v

https://github.com/socketio/socket.io-client-swift/issues/908

Once these steps are complete, you should be able to call `node app.js` from the Server folder in the downloaded repository, and then hit play in Xcode to run the app.


# INTRODUCTION

I’ve chosen to use my capstone to teach myself what I view as a vital component of programming: client-server communication. 
Since this is a capstone, I’m focusing less on the learning, and more on the implementing. In that spirit, I’m choosing a simple, 8 minute article as my learning tool.

Furthermore, I understand that a capstone is intended to be a demonstration of skills acquired, as opposed to an opportunity to acquire new skills. I would posit that learning and implementing new languages, API’s, and libraries is THE MOST IMPORTANT hard skill for a programmer to possess, and that is the primary skill I am displaying.

# Languages & Libraries To Learn

As a new programmer, I’m not in a position to be able to choose what libraries and database management are ”best”, just because I don’t know. However, I have heard these names very, very often, and although I would probably rather learn React, simply because frontend is more in demand than Node.js’s backend, I’m going to learn whatever I can be taught, and this article is teaching Node.js and MySQL just enough to meet the needs of client-server communication.
I, of course, plan to expand on what the article has to offer, so I’m going to have to rely on google for some self-education.

# Client-Server Justification

Every and any app relies on the internet. You have to get it FROM the internet, and if you want someone to have unique data, particularly large amounts of it, particularly not on their phone’s small storage space, you need a remote server to put all of that info in. Usernames, passwords, updates, basically anything real-time or unique to the app user has to be stored on a server. This is a core component of almost every app in existence.


Feel free to download the app and play around with it, and please contact me at austenstrine@gmail.com if you encounter any issues - chances are others will run into the same problems, so I'll update the readme with more detailed instructions.



