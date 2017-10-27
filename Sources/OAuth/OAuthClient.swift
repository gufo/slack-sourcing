import Foundation
import SwiftSoup

public typealias OAuthCallback = (_: Error?) -> Void

public enum OAuthErrors: Error {
    case authenticationFailed
    case invalidResponse
    case invalidUsernameOrPassword
    case unexpectedMarkup
}

struct LoginFormData {
    public let action: URL
    public let method: String
    public let parameters: [(String, String)]

    public init(html: String, baseURL: URL) throws {
        let doc = try SwiftSoup.parse(html)
        guard let form = try doc.select("form").first() else {
            throw OAuthErrors.unexpectedMarkup
        }
        let inputs = try form.select("input[type=hidden]")

        self.action = URL(string: try form.attr("action")) ?? baseURL
        self.method = try form.attr("method")
        self.parameters = try inputs.map { (try $0.attr("name"), try $0.attr("value")) }
    }
}

public class OAuthClient {
    public static var shared: OAuthClient!

    public enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }

    let baseURL: URL
    let session: URLSession
    var token: String = ""

    private var callback: OAuthCallback!
    
    public init(url: URL, session: URLSession) {
        self.baseURL = url
        self.session = session
    }

    public func authenticate(username: String, password: String, _ callback: @escaping OAuthCallback) {
        self.callback = callback
        startSignInFlow() { formData in
            self.postUserCredentials(formData, username: username, password: password) {
                self.callback(nil) // No error. Proceed.
            }
        }
    }

    public func urlRequest(url: URL, method: RequestMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func startSignInFlow(next: @escaping (LoginFormData) -> Void) {
        let signInUrl = baseURL.appendingPathComponent("api/idp/signIn")
        let task = session.dataTask(with: signInUrl) { data, response, error in
            guard error == nil else { return self.error(error!) }
            guard let data = data,
                let response = response as? HTTPURLResponse,
                let url = response.url else { return self.error(OAuthErrors.invalidResponse) }

            let html = String(data: data, encoding: .utf8)!

            do {
                let formData = try LoginFormData(html: html, baseURL: url)
                DispatchQueue.main.async { next(formData) }
            } catch {
                self.error(error)
            }

        }
        task.resume()
    }

    private func postUserCredentials(_ formData: LoginFormData, username: String, password: String, next: @escaping () -> Void) {
        let parameters = formData.parameters + [
            ("email", username),
            ("password", password)
        ]
        var request = URLRequest(url: formData.action)
        request.httpMethod = formData.method.uppercased()
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = encodeParameters(parameters)

        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else { return self.error(error!) }
            guard let currentURL = response?.url else {
                return self.error(OAuthErrors.invalidResponse)
            }

            guard currentURL.host == self.baseURL.host else {
                return self.error(OAuthErrors.invalidUsernameOrPassword)
            }

            self.token = currentURL.pathComponents.last!
            next()
        }
        task.resume()
    }

    private func encodeParameters(_ params: [(String, String)]) -> Data {
        let encodedParameters = params.map { param -> String in
            let (key, value) = param
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            return "\(encodedKey)=\(encodedValue)"
        }
        return encodedParameters.joined(separator: "&").data(using: .ascii)!
    }

    private func error(_ err: Error, _ description: String? = nil) {
        if let description = description {
            print("[error] \(description)")
        }
        self.callback(err)
    }
}
