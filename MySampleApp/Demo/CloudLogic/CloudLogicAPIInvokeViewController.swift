//
//  CloudLogicAPIInvokeViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.8
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSAPIGateway

let HTTPMethodGet = "GET"
let HTTPMethodHead = "HEAD"

class CloudLogicAPIInvokeViewController: UIViewController {
    
    @IBOutlet weak var responseTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var apiResponse: UITextView!
    @IBOutlet weak var apiEndpoint: UILabel!
    @IBOutlet weak var methodPath: UITextField!
    @IBOutlet weak var methodName: UILabel!
    @IBOutlet weak var queryStringParameters: UITextField!
    @IBOutlet weak var requestBody: UITextView!
    @IBOutlet weak var requestBodyLabel: UILabel!
    var cloudLogicAPI: CloudLogicAPI?
    var methodPathValue: String?
    var methodNameValue: String?
    var apiEndpointValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        methodPath.text = methodPathValue
        methodName.text = methodNameValue
        apiEndpoint.text = apiEndpointValue
        
        // Request Body are not supported on GET http method by API Gateway
        if (methodNameValue == HTTPMethodGet ||
            methodNameValue == HTTPMethodHead) {
            requestBody.text = ""
            requestBodyLabel.hidden = true
            requestBody.hidden = true
        }
    }
    
    @IBAction func onClear(sender: UIButton) {
        self.requestBody.text = ""
        self.queryStringParameters.text = ""
        self.apiResponse.text = ""
        self.statusLabel.text = ""
        self.responseTimeLabel.text = ""
    }
    @IBAction func onReset(sender: UIButton) {
        let defaultRequestBody = "{ \n  \"key1\":\"value1\", \n  \"key2\":\"value2\", \n  \"key3\":\"value3\"\n}"
        let defaultQueryStringParameters = "?lang=en"
        self.requestBody.text = defaultRequestBody
        self.queryStringParameters.text = defaultQueryStringParameters
        self.apiResponse.text = ""
        self.statusLabel.text = ""
        self.responseTimeLabel.text = ""
    }
    @IBAction func onInvokeApi(sender: AnyObject) {
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        var parameters: [String: AnyObject]?
        var queryParameters = [String: String]()
        
        // Parse query string parameters to Dictionary if not empty
        if var queryString = queryStringParameters.text where !queryString.isEmpty {
            // check if the query string begins with a `?`
            if queryString.hasPrefix("?") {
                // remove first character, i.e. `?`
                queryString.removeAtIndex(queryString.startIndex)
                let keyValuePairStringArray = queryString.componentsSeparatedByString("&")
                // check if there are any key value pairs
                if keyValuePairStringArray.count > 0 {
                    for pairString in keyValuePairStringArray {
                        let keyValue = pairString.componentsSeparatedByString("=")
                        if keyValue.count == 2 {
                            queryParameters.updateValue(keyValue[1], forKey: keyValue[0])
                        } else if keyValue.count == 1 {
                            queryParameters.updateValue("", forKey: keyValue[0])
                        } else {
                            print("Discarding query string for request: query string malformed.")
                        }
                    }
                }
            } else {
                print("Discarding query string for request: query string must begin with a `?`.")
            }
        }
        
        do {
            // Parse HTTP Body for methods apart from GET / HEAD
            if (methodNameValue != HTTPMethodGet &&
                methodNameValue != HTTPMethodHead) {
                // Parse the HTTP Body to JSON if not empty
                if (!requestBody.text.isEmpty) {
                    let jsonInput = requestBody.text.makeJsonable()
                    let jsonData = jsonInput.dataUsingEncoding(NSUTF8StringEncoding)!
                    parameters = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
                }
            }
        } catch let error as NSError {
            self.apiResponse.text = "JSON request is not well-formed."
            self.statusLabel.text = ""
            self.responseTimeLabel.text = ""
            
            print("json error: \(error.localizedDescription)")
            return
        }
        
        let apiRequest = AWSAPIGatewayRequest(HTTPMethod: methodName.text!, URLString: methodPath.text!, queryParameters: queryParameters, headerParameters: headerParameters, HTTPBody: parameters)
        let startTime = NSDate()
        
        cloudLogicAPI?.apiClient?.invoke(apiRequest).continueWithBlock({[weak self](task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            let endTime = NSDate()
            let timeInterval = endTime.timeIntervalSinceDate(startTime)
            if let error = task.error {
                print("Error occurred: \(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    strongSelf.apiResponse.text = "Error occurred while trying to invoke API: \(error)"
                    strongSelf.statusLabel.text = ""
                    strongSelf.responseTimeLabel.text = ""
                }
                return nil
            }
            
            if let exception = task.exception {
                print("Exception Occurred: \(exception)")
                dispatch_async(dispatch_get_main_queue()) {
                    strongSelf.apiResponse.text = "Exception Occurred while trying to invoke API: \(exception)"
                    strongSelf.statusLabel.text = ""
                    strongSelf.responseTimeLabel.text = ""
                }
                return nil
            }
            
            let result = task.result as! AWSAPIGatewayResponse
            let responseString = String(data: result.responseData!, encoding: NSUTF8StringEncoding)
            
            print(responseString)
            print(result.statusCode)
            
            dispatch_async(dispatch_get_main_queue()) {
                strongSelf.statusLabel.text = "\(result.statusCode)"
                strongSelf.apiResponse.text = responseString
                strongSelf.responseTimeLabel.text = String(format:"%.3f s", timeInterval)
            }
            
            return nil
        })
        
    }
}

extension String {
    private func makeJsonable() -> String {
        let resultComponents: NSArray = self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        return resultComponents.componentsJoinedByString("")
    }
}
