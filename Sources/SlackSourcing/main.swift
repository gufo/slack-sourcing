import Foundation
import SlackSourcingCore

let tool = SlackSourcingCommandLineTool()

do {
    try tool.run()
    RunLoop.main.run()
} catch {
    print("FATAL: \(error)")
}
