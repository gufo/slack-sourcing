import Foundation
import OAuth

public typealias SourcingCallback<T> = (T?, Error?) -> Void

public protocol SourcingClient {
    func numberOfOpenCases(completion: @escaping SourcingCallback<Int>)
    func getProspectiveClientsForUser(_ email: String, completion: @escaping SourcingCallback<[String]>)
}

public enum SourcingErrors: Error {
    case consultantNotFound
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

    public func getConsultant(email: String, completion: @escaping SourcingCallback<SourcingConsultant>) {
        self.getAllConsultants { consultants, error in
            let consultant = consultants?.first { $0.email == email }
            completion(consultant, error)
        }
    }

    public func getProspectiveClientsForUser(_ email: String, completion: @escaping SourcingCallback<[String]>) {
        self.getConsultant(email: email) { consultant, error in
            guard let consultant = consultant else {
                return completion(nil, error ?? SourcingErrors.consultantNotFound)
            }

            self.getAllCases { cases, error in
                let myActiveCases = cases?.filter { !$0.isArchived && $0.containsConsultant(consultant) }
                let myClients = myActiveCases?.map { $0.customer }
                completion(myClients, error)
            }
        }
    }

    private func getAllCases(completion: @escaping SourcingCallback<[SourcingCase]>) {
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

    private func getAllConsultants(completion: @escaping SourcingCallback<[SourcingConsultant]>) {
        let request = oauthClient.urlRequest(url: baseURL.appendingPathComponent("api/consultant"), method: .get)
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return completion(nil, error)
            }

            do {
                let consultants = try JSONDecoder().decode([SourcingConsultant].self, from: data)
                completion(consultants, nil)
            } catch let e {
                completion(nil, e)
            }
        }
        task.resume()
    }
}
