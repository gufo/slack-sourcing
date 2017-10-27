import Foundation
import OAuth

public typealias SourcingCallback<T> = (T?, Error?) -> Void

public protocol SourcingClient {
    func numberOfOpenCases(completion: @escaping SourcingCallback<Int>)
}

public class ProductionSourcingClient: SourcingClient {
    public static var shared: ProductionSourcingClient!

    public static let productionURL = URL(string: "https://sourcing.valtech.se/")!
    public static let stagingURL = URL(string: "https://stage-sourcing.valtech.se/")!

    let urlSession: URLSession
    let oauthClient: OAuthClient
    let baseURL: URL

    public init(url: URL, oauthClient: OAuthClient, urlSession: URLSession) {
        self.baseURL = url
        self.oauthClient = oauthClient
        self.urlSession = urlSession
    }

    public func numberOfOpenCases(completion: @escaping SourcingCallback<Int>) {
        self.getAllCases { cases, error in
            completion(cases?.filter { !$0.isArchived }.count, error)
        }
    }

    func getAllCases(completion: @escaping SourcingCallback<[SourcingCase]>) {
        let request = oauthClient.urlRequest(url: baseURL.appendingPathComponent("api/case"), method: .get)
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return completion(nil, error)
            }

            do {
                let cases = try JSONDecoder().decode([SourcingCase].self, from: data)
                completion(cases, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
