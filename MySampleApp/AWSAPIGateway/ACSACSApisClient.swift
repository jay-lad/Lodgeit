/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

import AWSCore
import AWSAPIGateway

public class ACSACSApisClient: AWSAPIGatewayClient {

	static let AWSInfoClientKey = "ACSACSApisClient"

	private static let _serviceClients = AWSSynchronizedMutableDictionary()
	private static var token: dispatch_once_t = 0
	private static var _defaultClient:ACSACSApisClient?
    
	/**
	 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `AWSServiceManager.defaultServiceManager()`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.
	
	 If you want to enable AWS Signature, set the default service configuration in `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)`
	
	     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
	         let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
	         AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
	
	         return true
	     }
	
	 Then call the following to get the default service client:
	
	     let serviceClient = ACSACSApisClient.defaultClient()

     Alternatively, this configuration could also be set in the `info.plist` file of your app under `AWS` dictionary with a configuration dictionary by name `ACSACSApisClient`.
	
	 @return The default service client.
	 */ 
	 
	public class func defaultClient() -> ACSACSApisClient{
		var serviceConfiguration: AWSServiceConfiguration? = nil
		let serviceInfo = AWSInfo.defaultAWSInfo().defaultServiceInfo(AWSInfoClientKey)
		if let serviceInfo = serviceInfo {
			serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
		} else if (AWSServiceManager.defaultServiceManager().defaultServiceConfiguration != nil) {
			serviceConfiguration = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration
		} else {
			serviceConfiguration = AWSServiceConfiguration(region: .Unknown, credentialsProvider: nil)
		}
		
		dispatch_once(&token) {
			_defaultClient = ACSACSApisClient(configuration: serviceConfiguration!)
		}
        
		return _defaultClient!
	}

	/**
	 Creates a service client with the given service configuration and registers it for the key.
	
	 If you want to enable AWS Signature, set the default service configuration in `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)`
	
	     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
	         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
	         ACSACSApisClient.registerClientWithConfiguration(configuration, forKey: "USWest2ACSACSApisClient")
	
	         return true
	     }
	
	 Then call the following to get the service client:
	
	
	     let serviceClient = ACSACSApisClient.client(forKey: "USWest2ACSACSApisClient")
	
	 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
	
	 @param configuration A service configuration object.
	 @param key           A string to identify the service client.
	 */
	
	public class func registerClientWithConfiguration(configuration: AWSServiceConfiguration, forKey key: NSString){
		_serviceClients.setObject(ACSACSApisClient(configuration: configuration), forKey: key);
	}

	/**
	 Retrieves the service client associated with the key. You need to call `registerClientWithConfiguration(configuration, forKey:)` before invoking this method or alternatively, set the configuration in your application's `info.plist` file. If `registerClientWithConfiguration(configuration, forKey:)` has not been called in advance or if a configuration is not present in the `info.plist` file of the app, this method returns `nil`.
	
	 For example, set the default service configuration in `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) `
	
	     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
	         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
	         ACSACSApisClient.registerClientWithConfiguration(configuration, forKey: "USWest2ACSACSApisClient")
	
	         return true
	     }
	
	 Then call the following to get the service client:
	 
	 	let serviceClient = ACSACSApisClient.client(forKey: "USWest2ACSACSApisClient")
	 
	 @param key A string to identify the service client.
	 @return An instance of the service client.
	 */
	public class func client(forKey key: NSString) -> ACSACSApisClient {
		objc_sync_enter(self)
		if let client: ACSACSApisClient = _serviceClients.objectForKey(key) as? ACSACSApisClient {
			objc_sync_exit(self)
		    return client
		}

		let serviceInfo = AWSInfo.defaultAWSInfo().defaultServiceInfo(AWSInfoClientKey)
		if let serviceInfo = serviceInfo {
			let serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
			ACSACSApisClient.registerClientWithConfiguration(serviceConfiguration, forKey: key)
		}
		objc_sync_exit(self)
		return _serviceClients.objectForKey(key) as! ACSACSApisClient;
	}

	/**
	 Removes the service client associated with the key and release it.
	 
	 @warning Before calling this method, make sure no method is running on this client.
	 
	 @param key A string to identify the service client.
	 */
	public class func removeClient(forKey key: NSString) -> Void{
		_serviceClients.removeObjectForKey(key)
	}
	
	init(configuration: AWSServiceConfiguration) {
	    super.init()
	
	    self.configuration = configuration.copy() as! AWSServiceConfiguration
	    var URLString: String = "https://big2n6ay7g.execute-api.us-east-1.amazonaws.com/acs"
	    if URLString.hasSuffix("/") {
	        URLString = URLString.substringToIndex(URLString.startIndex.advancedBy(URLString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - 1))
	    }
	    self.configuration.endpoint = AWSEndpoint(region: configuration.regionType, service: .APIGateway, URL: NSURL(string: URLString)!)
	    let signer: AWSSignatureV4Signer = AWSSignatureV4Signer(credentialsProvider: configuration.credentialsProvider, endpoint: self.configuration.endpoint)
	    if let endpoint = self.configuration.endpoint {
	    	self.configuration.baseURL = endpoint.URL
	    }
	    self.configuration.requestInterceptors = [AWSNetworkingRequestInterceptor(), signer]
	}

	
    /*
     
     
     @param body 
     
     return type: ACSTokenResponse
     */
    public func getTokenPost(body: ACSTokenRequest) -> AWSTask {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json",
                   
	            ]
	    
	    let queryParameters:[String:AnyObject] = [:]
	    
	    let pathParameters:[String:AnyObject] = [:]

        return self.invokeHTTPRequest("POST", URLString: "/get_token", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: body, responseClass: ACSTokenResponse.self)
	}

	
    /*
     
     
     
     return type: Empty
     */
    public func getTokenOptions() -> AWSTask {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json",
                   
	            ]
	    
	    let queryParameters:[String:AnyObject] = [:]
	    
	    let pathParameters:[String:AnyObject] = [:]
	    
	    return self.invokeHTTPRequest("OPTIONS", URLString: "/get_token", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: Empty.self)
	}

	
    /*
     
     
     @param body 
     
     return type: ACSResponse
     */
    public func registerChannelPost(body: ACSChannelRequest) -> AWSTask {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json",
                   
	            ]
	    
	    let queryParameters:[String:AnyObject] = [:]
	    
	    let pathParameters:[String:AnyObject] = [:]
	    
	    return self.invokeHTTPRequest("POST", URLString: "/register_channel", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: body, responseClass: ACSResponse.self)
	}

	
    /*
     
     
     
     return type: Empty
     */
    public func registerChannelOptions() -> AWSTask {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json",
                   
	            ]
	    
	    let queryParameters:[String:AnyObject] = [:]
	    
	    let pathParameters:[String:AnyObject] = [:]
	    
	    return self.invokeHTTPRequest("OPTIONS", URLString: "/register_channel", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: Empty.self)
	}




}
