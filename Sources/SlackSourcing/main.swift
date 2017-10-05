import SlackSourcingCore

let tool = SlackSourcingCommandLineTool()

do {
    try tool.run()
} catch {
    print("FATAL: \(error)")
}
