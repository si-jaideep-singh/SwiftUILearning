//
//  ServiceInteractor.swift
//  SIListing
//
//  Created by Siddharth Daga on 4/10/19.
//  Copyright © 2019 Sportz Interactive. All rights reserved.
//

import Foundation

public struct SIFeedsServiceInteractor {

    static public var shared = SIFeedsServiceInteractor()
    public var enableLogs: Bool = false
    fileprivate var paginationDict: [String: Int] = [:]

    public func getLayoutBuilderData(urlString: String, completion: ((_ response: SILayoutBuilderModel?, _ success: Bool, _ error: Error?) -> Void)?) {

        self.performNetworkOperation(urlString: urlString, object: SILayoutBuilderModel()) { (response, error) in

            if let response = response as? SILayoutBuilderModel {
                completion?(response, false, error)
            } else {
                completion?(nil, false, error)
            }
        }
    }

    public func getFeedsData(urlString: String,
                             parameters: [String: String],
                             paginationKey: String?,
                             startNew: Bool,
                             needCachedData: Bool = false,
                             completion: ((_ response: SIFeedsListingModel?, _ pageNo: Int, _ isCached: Bool, _ error: Error?) -> Void)?) {

        if let paginationKey = paginationKey {
            if needCachedData && startNew && SIFeedsStorage.fileExists(paginationKey, in: .documents) {
                if let feedsListing = SIFeedsStorage.retrieve(paginationKey, from: .documents, as: SIFeedsListingModel.self) {
                    completion?(feedsListing, 1, true, nil)
                }
            }
        }

        self.getListingData(urlString: urlString, object: SIFeedsListingModel(), parameters: parameters, paginationKey: paginationKey, startNew: startNew) { (response, pageNo, _, error) in
            if let response = response as? SIFeedsListingModel {
                if let paginationKey = paginationKey {
                    if needCachedData && startNew {
                        SIFeedsStorage.store(response, to: .documents, as: paginationKey)
                    }
                }
                completion?(response, pageNo, false, error)
            }
        }
    }

    public func getFeedsDetailData(urlString: String,
                                   parameters: [String: String],
                                   needCachedData: Bool = false,
                                   cachekey: String? = nil,
                                   completion: ((_ response: SIFeedsDetailModel?,
                                                 _ isCached: Bool,
                                                 _ error: Error?) -> Void)?) {

        var urlStr = urlString
        for parameter in parameters {
            urlStr = urlStr.replacingOccurrences(of: parameter.key, with: parameter.value)
        }

        if let cachekey = cachekey {
            if needCachedData && SIFeedsStorage.fileExists(cachekey, in: .documents) {
                if let response = SIFeedsStorage.retrieve(cachekey, from: .documents, as: SIFeedsDetailModel.self) {
                    completion?(response, true, nil)
                }
            }
        }

        self.performNetworkOperation(urlString: urlStr, object: SIFeedsDetailModel()) { (response, _) in
            if let response = response as? SIFeedsDetailModel {
                completion?(response, false, nil)
                if let cachekey = cachekey, needCachedData {
                    SIFeedsStorage.store(response, to: .documents, as: cachekey)
                }
            } else {
                completion?(nil, false, nil)
            }
        }
    }

    public func getFeedsPodcastData(urlString: String,
                                    parameters: [String: String],
                                    paginationKey: String?, startNew: Bool,
                                    needCachedData: Bool = false,
                                    completion: ((_ response: SIFeedsPodcastListing?,
                                                  _ pageNo: Int,
                                                  _ isCached: Bool,
                                                  _ error: Error?) -> Void)?) {

        if let paginationKey = paginationKey {
            if needCachedData && startNew && SIFeedsStorage.fileExists(paginationKey, in: .documents) {
                if let podcastListing = SIFeedsStorage.retrieve(paginationKey, from: .documents, as: SIFeedsPodcastListing.self) {
                    completion?(podcastListing, 1, true, nil)
                }
            }
        }

        self.getListingData(urlString: urlString, object: SIFeedsPodcastListing(), parameters: parameters, paginationKey: paginationKey, startNew: startNew) { (response, pageNo, _, error) in
            if let response = response as? SIFeedsPodcastListing {
                if let paginationKey = paginationKey {
                    if needCachedData && startNew {
                        SIFeedsStorage.store(response, to: .documents, as: paginationKey)
                    }
                }
                completion?(response, pageNo, false, error)
            } else {
                completion?(nil, pageNo, false, error)
            }
        }
    }

    public func getFeedsShowcaseData(urlString: String,
                                     parameters: [String: String],
                                     paginationKey: String?,
                                     startNew: Bool,
                                     needCachedData: Bool = false,
                                     completion: ((_ response: SIFeedsShowcaseListing?,
                                                   _ pageNo: Int,
                                                   _ isCached: Bool,
                                                   _ error: Error?) -> Void)?) {

        if let paginationKey = paginationKey {
            if needCachedData && startNew && SIFeedsStorage.fileExists(paginationKey, in: .documents) {
                if let showcaseListing = SIFeedsStorage.retrieve(paginationKey, from: .documents, as: SIFeedsShowcaseListing.self) {
                    completion?(showcaseListing, 1, true, nil)
                }
            }
        }

        self.getListingData(urlString: urlString, object: SIFeedsShowcaseListing(), parameters: parameters, paginationKey: paginationKey, startNew: startNew) { (response, pageNo, _, error) in
            if let response = response as? SIFeedsShowcaseListing {
                if let paginationKey = paginationKey {
                    if needCachedData && startNew {
                        SIFeedsStorage.store(response, to: .documents, as: paginationKey)
                    }
                }
                completion?(response, pageNo, false, error)
            } else {
                completion?(nil, pageNo, false, error)
            }
        }
    }

    fileprivate func getListingData<U: Codable>(urlString: String,
                                                object: U,
                                                parameters: [String: String],
                                                paginationKey: String?,
                                                startNew: Bool,
                                                completion: ((_ response: Codable?,
                                                              _ pageNo: Int,
                                                              _ isCached: Bool,
                                                              _ error: Error?) -> Void)?) {
        var urlStr = urlString

        for parameter in parameters {
            urlStr = urlStr.replacingOccurrences(of: parameter.key, with: parameter.value)
        }

        if let paginationKey = paginationKey, paginationKey.count > 0 {

            if startNew {
                SIFeedsServiceInteractor.shared.paginationDict.updateValue(1, forKey: paginationKey)
            }

            var pageNo = 1

            if let dictPageNo = SIFeedsServiceInteractor.shared.paginationDict[paginationKey] {
                pageNo = dictPageNo
            }

            urlStr = urlStr.replacingOccurrences(of: "{{page_no}}", with: "\(pageNo)")

            self.performNetworkOperation(urlString: urlStr, object: object) { (response, error) in
                if response != nil {
                    SIFeedsServiceInteractor.shared.paginationDict.updateValue(pageNo + 1, forKey: paginationKey)
                }

                completion?(response, pageNo, false, error)
            }
        } else {
            completion?(nil, 1, false, nil)
        }
    }

    fileprivate func performNetworkOperation<U: Codable>(urlString: String,
                                                         object: U,
                                                         completion: ((_ response: Codable?,
                                                                       _ error: Error?) -> Void)?) {
        guard let url = URL(string: urlString) else {
            completion?(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringCacheData
        URLCache.shared.removeAllCachedResponses()

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            var parsedResponse:U?
            var parseError: Error?

            guard let dataResponse = data,
                  error == nil else {
                parseError = error
                self.printLogs(request: request, responseData: nil, error: parseError)
                completion?(nil, parseError)
                return
            }
            do {
                let decoder = JSONDecoder()
                parsedResponse = try decoder.decode(U.self, from: dataResponse)
            } catch let parsingError {
                parseError = parsingError
                parsedResponse = nil
            }

            DispatchQueue.main.async {
                self.printLogs(request: request, responseData: dataResponse, error: parseError)
                completion?(parsedResponse, parseError)
            }
        }
        task.resume()
    }

    fileprivate func printLogs(request:URLRequest, responseData: Data?, error: Error?) {
        if SIFeedsServiceInteractor.shared.enableLogs {
            print("\n====================================\n")
            print("REQUEST: \n\(request)")
            print("\n\n")

            if let responseData = responseData {
                print("RESPONSE: \n\(responseData.prettyPrintedJSONString ?? "")")
                print("\n\n")
            }

            if let error = error {
                print("ERROR: \n\(error)")
                print("\n====================================\n")
            }
        }
    }
}

extension Data {
    /// NSString gives us a nice sanitized debugDescription
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
