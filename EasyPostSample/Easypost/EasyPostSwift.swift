//
//  EasyPostSwift.swift
//  EasyPostSample
//
//  Created by Ruben Nieves on 6/4/16.
//  Copyright © 2016 TopBalance Software. All rights reserved.
//

import UIKit


enum EasyPostServiceErrorCode : Int {
    case EasyPostServiceErrorGeneral = 1 /* Non-specific error */
    case EasyPostServiceErrorMissingParameters = 2
}
typealias CompletionBlock = (NSError?, Dictionary <String , String>?) -> Void //error and result


class EasyPostSwift: NSObject {
    static var EasyPostServiceErrorDomain : String = "EasyPostServiceError"
#if (TEST_VERSION)
    static var APIKEY = "" //Test Key
#else
    static var APIKEY = "";
#endif

    func showNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
    }
    
    func hideNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
    }
    
    //Generic function for getting something from API
    class func requestService(parameters:Dictionary <String, String>, link:String, completion:CompletionBlock) {
        var body : String = ""
        for (key, value) in parameters {
            body += "\(key)=\(value)&"
        }
        let method = parameters.isEmpty ? "GET" : "POST"
        if method == "POST" {
            body = String(body.characters.dropLast()) //Delete last & character
        }
        
        
        let requestData : NSData? = body.dataUsingEncoding(NSUTF8StringEncoding)
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: link)!)
        if (requestData != nil) {
            
            //Authorization
            let authStr : String = "\(APIKEY):"
            let authData : NSData = authStr.dataUsingEncoding(NSASCIIStringEncoding)!
            let authValue : String = "Basic\(Base64Encoder.base64EncodeForData(authData) as String)="
            request.setValue(authValue, forKey: "Authorization")
            
            //Finish request
            let postLength : String = "\(String(requestData?.length))"
            request.HTTPMethod = method
            request.setValue(postLength, forKey: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forKey: "Content-Type")
            
            
            let config : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session : NSURLSession = NSURLSession(configuration: config)
            let uploadTask : NSURLSessionUploadTask = session.uploadTaskWithRequest(request, fromData: requestData, completionHandler: { (data, response, error) in
                if error == nil {
                    completion(error,nil)
                } else {
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: String]
                        completion(nil, json)
                    } catch let error as NSError {
                        print("Failed to parse: \(error.localizedDescription)")
                        completion(error, nil)
                    }
                }
            });
            uploadTask .resume()
        } else {
            completion(NSError.init(domain: EasyPostServiceErrorDomain, code: 500, userInfo: ["Error":"Error creating request"]), nil)
        }   
    }
    
    class func getPostageLabelForShipment(shipmentId:String, rateId:String, completion:CompletionBlock) {
        let link : String = "https://api.easypost.com/v2/shipments/\(shipmentId)/buy"
        let dict : Dictionary = ["rate[id]" : rateId]
        EasyPostSwift.requestService(dict, link: link, completion: completion)
    }
    
    class func getAddress(addressDict:Dictionary <String,String>, completion:CompletionBlock) {
        EasyPostSwift.requestService(addressDict, link: "https://api.easypost.com/v2/addresses", completion: completion)
    }
    
    class func getParcel(parcelDict:Dictionary<String, String>, completion:CompletionBlock) {
        EasyPostSwift.requestService(parcelDict, link: "https://api.easypost.com/v2/parcels", completion: completion)
    }
    
    class func getShipment(toAddressId:String, fromAddressId:String, parcelId:String, customsId:String?, completion:CompletionBlock) {
        var dict : Dictionary = ["shipment[to_address][id]" : toAddressId,
                    "shipment[from_address][id]" : fromAddressId,
                    "shipment[parcel][id]" : parcelId
                    ]
        if customsId != nil {
            dict["shipment[customs_info][id]"] = customsId
        }
        EasyPostSwift.requestService(dict, link: "https://api.easypost.com/v2/shipments", completion: completion)
    }
    
    class func getShipment(toDictionary:Dictionary<String,String>, fromDictionary:Dictionary<String,String>, parcelDictionary:Dictionary<String,String>, completion:CompletionBlock) {
        var dict : Dictionary = [String:String]() //Empty dictionary first

        //Add addresses values for shipment
        for index in 0...1 {
            var addressDict : Dictionary = index == 0 ? fromDictionary : toDictionary
            let addressKeyString = index == 0 ? "from_address" : "to_address"
            if let name = addressDict["address[name]"] {
                dict["shipment[\(addressKeyString)][name]"] = name
            }
            
            if let company = addressDict["address[company]"] {
                dict["shipment[\(addressKeyString)][company]"] = company
            }
            
            if let street1 = addressDict["address[street1]"] {
                dict["shipment[\(addressKeyString)][street1]"] = street1
            }
            
            if let street2 = addressDict["address[street2]"] {
                dict["shipment[\(addressKeyString)][street2]"] = street2
            }
            
            if let city = addressDict["address[city]"] {
                dict["shipment[\(addressKeyString)][city]"] = city
            }
            
            if let state = addressDict["address[state]"] {
                dict["shipment[\(addressKeyString)][state]"] = state
            }
            
            if let zip = addressDict["address[zip]"] {
                dict["shipment[\(addressKeyString)][zip]"] = zip
            }
            
            if let zip = addressDict["address[country]"] {
                dict["shipment[\(addressKeyString)][country]"] = zip
            } else {
                dict["shipment[\(addressKeyString)][country]"] = "US"
            }
            
            if let phone = addressDict["address[phone]"] {
                dict["shipment[\(addressKeyString)][phone]"] = phone
            }
            
            if let email = addressDict["address[email]"] {
                dict["shipment[\(addressKeyString)][email]"] = email
            }
            
        }
        
        if let predefinedPackage = parcelDictionary["parcel[predefined_package]"] {
            dict["shipment[parcel][predefined_package]"] = predefinedPackage
        }
        
        if let weight = parcelDictionary["parcel[weight]"] {
            dict["shipment[parcel][weight]"] = weight
        }
        
        if let length = parcelDictionary["parcel[length]"] {
            dict["shipment[parcel][length]"] = length
        }
        
        if let width = parcelDictionary["parcel[width]"] {
            dict["shipment[parcel][width]"] = width
        }
        
        if let height = parcelDictionary["parcel[height]"] {
            dict["shipment[parcel][height]"] = height
        }
        EasyPostSwift.requestService(dict, link: "https://api.easypost.com/v2/shipments", completion: completion)
    }
}
