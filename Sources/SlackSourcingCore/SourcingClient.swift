import Foundation

public typealias SourcingCallback<T> = (T?, Error?) -> Void

public protocol SourcingClient {
    func numberOfOpenCases(completion: @escaping SourcingCallback<Int>)
}

public class ProductionSourcingClient: SourcingClient {
    public static let shared = ProductionSourcingClient(url: ProductionSourcingClient.stagingURL)

    public static let productionURL = URL(string: "https://sourcing.valtech.se/")!
    public static let stagingURL = URL(string: "https://stage-sourcing.valtech.se/")!

    var urlSession: URLSession!
    var baseURL: URL

    public init(url: URL) {
        baseURL = url
    }

    public func numberOfOpenCases(completion: @escaping SourcingCallback<Int>) {
        self.getAllCases { cases, error in
            completion(cases?.filter { !$0.isArchived }.count, error)
        }
    }

    func getAllCases(completion: @escaping SourcingCallback<[SourcingCase]>) {
        let url = baseURL.appendingPathComponent("api/case")
        let task = urlSession.dataTask(with: url) { data, response, error in
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
