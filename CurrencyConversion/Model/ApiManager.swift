//
//  ApiManager.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 24/08/2023.
//

import Foundation
import RxSwift

protocol fetchData{
    func getData<T: Decodable>(modelDTO: T.Type ,_ endpoint: Endpoints, attributes: [String: String]?) -> Observable<T>
}

enum Endpoints {
    case getExchangeRate
    case getAllCurrencies
    case getAllCurrenciesData
    case convertCurrency
    case compareCurrencies
    
    
    var stringUrl: URL {
        switch self {
        case .getExchangeRate:
            return URL(string: "https://v6.exchangerate-api.com/v6/ecf10bab01b34bf0de9636e1/latest/USD")!
        case .getAllCurrencies:
            return URL(string: "http://16.171.161.38/api/v1")!
        case .getAllCurrenciesData:
            return URL(string: Constants.Links.baseURL + "v1")!
        case .convertCurrency:
            return URL(string: Constants.Links.baseURL + "v2/conversion?")!
        case .compareCurrencies:
            return URL(string: Constants.Links.baseURL + "v2/conversion?")!
            
        }
    }
}

class ApiClient: fetchData {
    
    private static let sharedInstance = ApiClient()

        static func shared() -> ApiClient {
            return ApiClient.sharedInstance
        }
        private init() {}
    
    func getData<T>(modelDTO: T.Type ,_ endpoint: Endpoints, attributes: [String: String]? = nil) -> Observable<T> where T : Decodable {
        
        var request = URLRequest(url: endpoint.stringUrl)
        if let attributes = attributes {
            for (key, value) in attributes {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: endpoint.stringUrl) { data, response, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data {
                    do {
                        let exchangeRate = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(exchangeRate)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
