//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Dog: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = try? Dog(dogName: self.dogName) else {
            return Dog()
        }
        
        copy.dogId = self.dogId
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager ?? ReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? LogManager ?? LogManager()
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogId = aDecoder.decodeInteger(forKey: KeyConstant.dogId.rawValue)
        // shift dogId of 0 to proper placeholder of -1
        dogId = dogId >= 1 ? dogId : -1
        
        dogName = aDecoder.decodeObject(forKey: KeyConstant.dogName.rawValue) as? String ?? dogName
        dogLogs = aDecoder.decodeObject(forKey: KeyConstant.dogLogs.rawValue) as? LogManager ?? dogLogs
        dogReminders = aDecoder.decodeObject(forKey: KeyConstant.dogReminders.rawValue) as? ReminderManager ?? dogReminders
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        aCoder.encode(dogName, forKey: KeyConstant.dogName.rawValue)
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
        aCoder.encode(dogReminders, forKey: KeyConstant.dogReminders.rawValue)
    }
    
    // MARK: - Properties
    
    var dogId: Int = ClassConstant.DogConstant.defaultDogId
    
    // TODO FUTURE sync dogIcon and dogLogImage with server
    /*
     Backend (JS/Node.js)
     The backend server will be responsible for two main tasks related to the images: uploading to S3, and serving the URLs to the client.

     Uploading to S3:

     When a log is created and an image is uploaded, the image should be sent to your backend server in a format like Base64 or as multipart/form-data.

     Before the image is uploaded to S3, it's generally a good idea to generate a unique filename for it. This can be done using Node.js' built-in uuid module, for example:

     javascript


     const { v4: uuidv4 } = require('uuid');
     const filename = uuidv4();
     Then, you can use the AWS SDK to upload the image to S3:

     javascript


     const AWS = require('aws-sdk');

     const s3 = new AWS.S3();

     const params = {
       Bucket: 'your-bucket-name',
       Key: filename,
       Body: imageBuffer, // this is your image data
       ACL: 'public-read' // this makes the file publicly readable
     };

     s3.upload(params, function(err, data) {
       if (err) {
         console.log("Error uploading data: ", err);
       } else {
         console.log("Successfully uploaded image to S3");
       }
     });
     Storing the URL in the database:

     Once the image is successfully uploaded to S3, the URL of the image is then saved to the database alongside the other log data. The URL would be the data.Location from the response of the upload function.

     Serving URLs to the client:

     When a client requests a log, the server fetches the log from the database (including the URL of the image), and sends this data to the client. The client will then be able to use this URL to fetch the image.

     Database (MariaDB)
     Add a new column to the logs table, maybe called image_url. This column will hold the URL of the image in S3. The URL is generated after uploading the image file to S3.

     sql


     ALTER TABLE logs ADD COLUMN image_url TEXT;
     When a log with an image is created, save the URL of the image in this column.

     Client (Swift)
     When the client receives the log data (including the image URL), it can use this URL to fetch the image. Here's an example of how you might do this using Swift:
     
     To encode and send the image as Base64, you'd convert the Data to a Base64-encoded string like this:

     swift


     let base64String = imageData.base64EncodedString()
     Then you'd send this string to your server in a JSON object, for example. On the server side, you can convert the Base64 string back to a Buffer like this:

     let imageData = yourUIImage.jpegData(compressionQuality: 0.5)


     let imageBuffer = Buffer.from(req.body.base64String, 'base64');
     This imageBuffer can then be uploaded to S3 just like in the previous example.

     It's important to note that Base64 encoding increases the size of the data by about 33%, and is therefore less efficient than sending the data as multipart/form-data. However, it can be easier to handle, especially if you're sending other data along with the image.

     swift


     let url = URL(string: "https://my-bucket.s3.us-west-2.amazonaws.com/123e4567-e89b-12d3-a456-426655440000")!
     let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
         if let data = data {
             DispatchQueue.main.async {
                 // Assume imageView is your image view
                 imageView.image = UIImage(data: data)
             }
         }
     }
     task.resume()
     This code creates a URL from the string you received from the server, creates a URLSession data task with that URL, and starts the task. When the task completes, it will call the completion handler with the data that was downloaded. This data can then be used to create a UIImage.

     AWS S3
     In the AWS S3, you should have a bucket where all the images are uploaded. Make sure to setup proper access control. In this case, we're making the uploaded image publicly readable so that it can be accessed directly using the URL.

     Considerations
     Make sure to handle errors at each step of the process, and have a plan for what to do if something goes wrong. For example, if the image fails to upload to S3, you might want to send an error message to the client and not create the log in the database.
     Be aware that making your images publicly readable in S3 makes them accessible to anyone who has the URL. This is generally safe as the URLs include a UUID and are not guessable, but it does mean that anyone who obtains a URL can view the image it points to.
     You might want to consider adding some kind of cleanup process for orphaned images in S3 (for example, if an image is uploaded but the corresponding log is not created in the database).
     You will be charged for storage and data transfer in S3. Make sure to monitor your usage and understand the cost implications.
     Be aware that if you have a lot of large images, this can slow down the process of creating logs and increase the load on your server. You might want to consider implementing some kind of size limit or compression for the images.
     This strategy should allow you to effectively add images to your logs in a scalable and efficient way.
     */
    var dogIcon: UIImage?
    
    private(set) var dogName: String = ClassConstant.DogConstant.defaultDogName
    func changeDogName(forDogName: String?) throws {
        guard let forDogName = forDogName else {
            throw ErrorConstant.DogError.dogNameNil()
        }
        
        guard forDogName.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            throw ErrorConstant.DogError.dogNameBlank()
        }
        
        guard forDogName.count <= ClassConstant.DogConstant.dogNameCharacterLimit else {
            throw ErrorConstant.DogError.dogNameCharacterLimitExceeded()
        }
        
        dogName = forDogName
    }
    
    /// ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager = ReminderManager()
    
    /// LogManager that handles all the logs for a dog
    var dogLogs: LogManager = LogManager()
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(
        dogId: Int = ClassConstant.DogConstant.defaultDogId,
        dogName: String? = ClassConstant.DogConstant.defaultDogName) throws {
            self.init()
            
            self.dogId = dogId
            try changeDogName(forDogName: dogName)
            self.dogIcon = DogIconManager.getIcon(forDogId: dogId)
        }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from dogBody.
    convenience init?(forDogBody dogBody: [String: Any], overrideDog: Dog?) {
        // Don't pull dogId or dogIsDeleted from overrideDog. A valid dogBody needs to provide this itself
        let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
        let dogIsDeleted: Bool? = dogBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
        
        // a dog body needs a dogId and dogIsDeleted to be intrepreted as same, updated, or deleted
        guard let dogId = dogId, let dogIsDeleted = dogIsDeleted else {
            // couldn't construct essential components to intrepret dog
            return nil
        }
        
        guard dogIsDeleted == false else {
            // the dog has been deleted
            // no need to process reminders or logs
            return nil
        }
        
        // if the dog is the same, then we pull values from overrideDog
        // if the dog is updated, then we pull values from dogBody
        let dogName: String? = dogBody[KeyConstant.dogName.rawValue] as? String ?? overrideDog?.dogName
        
        // no properties should be nil. Either a complete dogBody should be provided (i.e. no previousDogManagerSynchronization was used in query) or a potentially partial dogBody (i.e. previousDogManagerSynchronization used in query) should be passed with an overrideDogManager
        guard let dogName = dogName else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }
        
        do {
            try self.init(dogId: dogId, dogName: dogName)
        }
        catch {
            try! self.init(dogId: dogId) // swiftlint:disable:this force_try
        }
        
        if let reminderBodies = dogBody[KeyConstant.reminders.rawValue] as? [[String: Any]] {
            self.dogReminders = ReminderManager(fromReminderBodies: reminderBodies, overrideReminderManager: overrideDog?.dogReminders)
        }
        if let logBodies = dogBody[KeyConstant.logs.rawValue] as? [[String: Any]] {
            self.dogLogs = LogManager(fromLogBodies: logBodies, overrideLogManager: overrideDog?.dogLogs)
        }
    }
}

extension Dog {
    // MARK: - Request
    
    /// Returns an array literal of the dog's properties (does not include nested properties, e.g. logs or reminders). This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.dogName.rawValue] = dogName
        body[KeyConstant.dogIsDeleted.rawValue] = false
        return body
    }
}
