import Foundation
import Cocoa

// Port information structure
struct PortInfoMenuBar {
    let port: Int
    let processName: String
    let processID: Int
    let `protocol`: String
    let state: String
    let localAddress: String
    let foreignAddress: String
}

// Port manager class
class PortManagerMenuBar {
    func getOpenPorts() -> [PortInfoMenuBar] {
        // Use lsof to get detailed port information
        let task = Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-i", "-P", "-n"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            
            // Set a timeout to prevent hanging
            let timeout = DispatchTime.now() + .seconds(3)
            let semaphore = DispatchSemaphore(value: 0)
            
            DispatchQueue.global().async {
                task.waitUntilExit()
                semaphore.signal()
            }
            
            // Wait for completion or timeout
            if semaphore.wait(timeout: timeout) == .timedOut {
                task.terminate()
                return []
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return [] }
            return parseLsofOutput(output)
        } catch {
            return []
        }
    }
    
    private func parseLsofOutput(_ output: String) -> [PortInfoMenuBar] {
        var portInfos: [PortInfoMenuBar] = []
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            guard !line.isEmpty && !line.hasPrefix("COMMAND") else { continue }
            
            let components = line.split(separator: " ", omittingEmptySubsequences: true)
            guard components.count >= 10,
                  let processID = Int(components[1]) else { continue }
            
            let processName = String(components[0])
            let name = String(components[8]) // NAME column: *:5000
            let state = String(components[9]) // STATE column: (LISTEN)
            
            if let portInfo = parsePortFromName(name, state: state, processName: processName, processID: processID) {
                portInfos.append(portInfo)
            }
        }
        
        // Remove duplicates and sort by port number
        let uniquePorts = Dictionary(grouping: portInfos, by: { $0.port })
            .compactMapValues { $0.first }
            .values
            .sorted { $0.port < $1.port }
        
        return Array(uniquePorts)
    }
    
    private func parsePortFromName(_ name: String, state: String, processName: String, processID: Int) -> PortInfoMenuBar? {
        // Parse name like "*:5000" with separate state like "(LISTEN)"
        let listenPattern = #"^(\*|[\d\.]+):(\d+)$"#
        let establishedPattern = #"^([\d\.]+):(\d+)->([\d\.]+):(\d+)$"#
        
        // Try LISTEN pattern first (simple port binding)
        if let match = try? NSRegularExpression(pattern: listenPattern).firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let localAddress = String(name[Range(match.range(at: 1), in: name)!])
            let portString = String(name[Range(match.range(at: 2), in: name)!])
            
            if let port = Int(portString) {
                return PortInfoMenuBar(
                    port: port,
                    processName: processName,
                    processID: processID,
                    protocol: "TCP",
                    state: state,
                    localAddress: localAddress,
                    foreignAddress: "*"
                )
            }
        }
        
        // Try ESTABLISHED pattern (connection)
        if let match = try? NSRegularExpression(pattern: establishedPattern).firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let localAddress = String(name[Range(match.range(at: 1), in: name)!])
            let portString = String(name[Range(match.range(at: 2), in: name)!])
            let foreignAddress = String(name[Range(match.range(at: 3), in: name)!])
            let foreignPort = String(name[Range(match.range(at: 4), in: name)!])
            
            if let port = Int(portString) {
                return PortInfoMenuBar(
                    port: port,
                    processName: processName,
                    processID: processID,
                    protocol: "TCP",
                    state: state,
                    localAddress: localAddress,
                    foreignAddress: "\(foreignAddress):\(foreignPort)"
                )
            }
        }
        
        return nil
    }
    
    func killProcess(portInfo: PortInfoMenuBar) -> Bool {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(portInfo.processID)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            
            // Set a timeout to prevent hanging
            let timeout = DispatchTime.now() + .seconds(3)
            let semaphore = DispatchSemaphore(value: 0)
            
            DispatchQueue.global().async {
                task.waitUntilExit()
                semaphore.signal()
            }
            
            // Wait for completion or timeout
            if semaphore.wait(timeout: timeout) == .timedOut {
                task.terminate()
                print("Kill process timed out after 3 seconds")
                return false
            }
            
            if task.terminationStatus == 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Error killing process: \(error.localizedDescription)")
            return false
        }
    }
}

// Main application class
@MainActor
class AppDelegateMenuBar: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var portManager: PortManagerMenuBar!
    var ports: [PortInfoMenuBar] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        portManager = PortManagerMenuBar()
        
        // Create status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set a simple text icon to save memory
        if let button = statusBarItem.button {
            button.title = "P"
            button.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            button.action = #selector(statusBarButtonClicked)
        }
        
        // Load initial data
        refreshPorts()
    }
    
    @objc func statusBarButtonClicked() {
        // The menu will be shown automatically when the status bar button is clicked
    }
    
    @objc func refreshPorts() {
        // Show loading state
        updateMenuWithLoading()
        
        // Run port scanning in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let newPorts = self.portManager.getOpenPorts()
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.ports = newPorts
                self.updateMenu()
            }
        }
    }
    
    func updateMenuWithLoading() {
        let menu = NSMenu()
        
        // Header
        let headerItem = NSMenuItem(title: "Port Manager", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Loading item
        let loadingItem = NSMenuItem(title: "Scanning ports...", action: nil, keyEquivalent: "")
        loadingItem.isEnabled = false
        menu.addItem(loadingItem)
        
        statusBarItem.menu = menu
    }
    
    func updateMenu() {
        let menu = NSMenu()
        
        // Header
        let headerItem = NSMenuItem(title: "Port Manager", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        if ports.isEmpty {
            let noPortsItem = NSMenuItem(title: "No open ports found", action: nil, keyEquivalent: "")
            noPortsItem.isEnabled = false
            menu.addItem(noPortsItem)
        } else {
            // Group ports by process name
            let groupedPorts = Dictionary(grouping: ports) { $0.processName }
            
            // Sort services: single port first, then multiple ports, then by port number
            let sortedProcessNames = groupedPorts.keys.sorted { processName1, processName2 in
                let ports1 = groupedPorts[processName1] ?? []
                let ports2 = groupedPorts[processName2] ?? []
                
                // Single port services come first
                if ports1.count == 1 && ports2.count > 1 {
                    return true
                } else if ports1.count > 1 && ports2.count == 1 {
                    return false
                }
                
                // Within same type (single or multiple), sort by lowest port number
                let minPort1 = ports1.map { $0.port }.min() ?? 0
                let minPort2 = ports2.map { $0.port }.min() ?? 0
                return minPort1 < minPort2
            }
            
            for processName in sortedProcessNames.prefix(10) { // Limit to 10 services to save memory
                guard let processPorts = groupedPorts[processName] else { continue }
                
                // All services get submenus - consistent alignment
                let serviceMenu = NSMenu()
                serviceMenu.title = processName
                
                // Sort ports by port number
                let sortedPorts = processPorts.sorted { $0.port < $1.port }
                
                for portInfo in sortedPorts {
                    let portTitle = createAlignedTitle(serviceName: processName, port: portInfo.port)
                    let portItem = NSMenuItem(title: portTitle, action: #selector(portItemClicked(_:)), keyEquivalent: "")
                    portItem.representedObject = portInfo
                    serviceMenu.addItem(portItem)
                }
                
                // Create main menu item with submenu
                let serviceItem = NSMenuItem(title: "\(processPorts.count) - \(processName)", action: nil, keyEquivalent: "")
                serviceItem.submenu = serviceMenu
                menu.addItem(serviceItem)
            }
            
            if groupedPorts.count > 10 {
                let moreItem = NSMenuItem(title: "... and \(groupedPorts.count - 10) more services", action: nil, keyEquivalent: "")
                moreItem.isEnabled = false
                menu.addItem(moreItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Refresh item
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshPorts), keyEquivalent: "r")
        menu.addItem(refreshItem)
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit Port Manager", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusBarItem.menu = menu
    }
    
    @objc func portItemClicked(_ sender: NSMenuItem) {
        guard let portInfo = sender.representedObject as? PortInfoMenuBar else { return }
        
        // Show loading state immediately
        updateMenuWithKilling(portInfo: portInfo)
        
        // Kill process in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            _ = self.portManager.killProcess(portInfo: portInfo)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Silent operation - no notifications to save memory
                
                // Refresh the ports
                self.refreshPorts()
            }
        }
    }
    
    
    func createAlignedTitle(serviceName: String, port: Int) -> String {
        // Use tab character for better alignment in macOS menus
        return "\(serviceName)\t\(port)"
    }
    
    
    func updateMenuWithKilling(portInfo: PortInfoMenuBar) {
        let menu = NSMenu()
        
        // Header
        let headerItem = NSMenuItem(title: "Port Manager", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Killing item
        let killingItem = NSMenuItem(title: "Killing \(portInfo.processName)...", action: nil, keyEquivalent: "")
        killingItem.isEnabled = false
        menu.addItem(killingItem)
        
        statusBarItem.menu = menu
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up lock file
        let lockFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PortManager.lock")
        try? FileManager.default.removeItem(at: lockFile)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

// Single instance check
func checkSingleInstance() -> Bool {
    let lockFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PortManager.lock")
    
    // Check if lock file exists
    if FileManager.default.fileExists(atPath: lockFile.path) {
        // Try to read PID from lock file
        if let data = try? Data(contentsOf: lockFile),
           let pidString = String(data: data, encoding: .utf8),
           let pid = Int(pidString) {
            
            // Check if process is still running
            let task = Process()
            task.launchPath = "/bin/ps"
            task.arguments = ["-p", "\(pid)"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            do {
                try task.run()
                task.waitUntilExit()
                
                if task.terminationStatus == 0 {
                    print("Port Manager is already running (PID: \(pid))")
                    return false
                }
            } catch {
                // Process not found, continue
            }
        }
        
        // Remove stale lock file
        try? FileManager.default.removeItem(at: lockFile)
    }
    
    // Create lock file with current PID
    let pid = ProcessInfo.processInfo.processIdentifier
    if let data = "\(pid)".data(using: .utf8) {
        try? data.write(to: lockFile)
    }
    
    return true
}

// Cleanup function
func cleanup() {
    let lockFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PortManager.lock")
    try? FileManager.default.removeItem(at: lockFile)
}

// Main function
func main() {
    // Check for single instance
    guard checkSingleInstance() else {
        print("Port Manager is already running. Exiting.")
        exit(1)
    }
    
    // Set up cleanup on exit
    atexit {
        cleanup()
    }
    
    Task { @MainActor in
        let app = NSApplication.shared
        let delegate = AppDelegateMenuBar()
        app.delegate = delegate
        app.run()
    }
    
    // Keep the main thread alive
    RunLoop.main.run()
}

main()
