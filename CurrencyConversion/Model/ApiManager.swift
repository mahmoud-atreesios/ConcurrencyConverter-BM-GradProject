//
//  ApiManager.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 24/08/2023.
//

import Foundation
import RxSwift

protocol fetchData{
    func getData<T: Decodable>(modelDTO: T.Type ,_ endpoint: Endpoints) -> Observable<T>
}

enum Endpoints {
    case getExchangeRate
    
    var stringUrl: URL {
        switch self {
        case .getExchangeRate:
            return URL(string: "https://v6.exchangerate-api.com/v6/ecf10bab01b34bf0de9636e1/latest/USD")!
        }
    }
}

struct ApiClient: fetchData {
    
    func getData<T>(modelDTO: T.Type ,_ endpoint: Endpoints) -> Observable<T> where T : Decodable {
        
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
