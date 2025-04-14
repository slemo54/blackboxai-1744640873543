import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentEpisode: Episode?
    private var episodes: [Episode] = []
    private var currentValue = ""
    
    private var inItem = false
    private var inEnclosure = false
    
    func parse(data: Data) -> [Episode] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return episodes
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            inItem = true
            currentEpisode = Episode(title: "", description: "", pubDate: Date(), duration: "", imageURL: nil, audioURL: nil)
        } else if elementName == "enclosure" && inItem {
            inEnclosure = true
            if let urlString = attributeDict["url"], let url = URL(string: urlString) {
                currentEpisode?.audioURL = url
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard inItem, let episode = currentEpisode else { return }
        
        switch elementName {
        case "title":
            currentEpisode?.title = currentValue
        case "description":
            currentEpisode?.description = currentValue
        case "pubDate":
            if let date = parseDate(currentValue) {
                currentEpisode?.pubDate = date
            }
        case "itunes:duration":
            currentEpisode?.duration = formatDuration(currentValue)
        case "itunes:image":
            if let url = URL(string: currentValue) {
                currentEpisode?.imageURL = url
            }
        case "item":
            episodes.append(episode)
            inItem = false
            currentEpisode = nil
        case "enclosure":
            inEnclosure = false
        default:
            break
        }
        
        currentValue = ""
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateString)
    }
    
    private func formatDuration(_ duration: String) -> String {
        // Convert "HH:MM:SS" or "MM:SS" to "HHh MMm" or "MMm SSs"
        let components = duration.components(separatedBy: ":")
        if components.count == 3 {
            return "\(components[0])h \(components[1])m"
        } else if components.count == 2 {
            return "\(components[0])m \(components[1])s"
        }
        return duration
    }
}
