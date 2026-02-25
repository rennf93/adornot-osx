import Foundation

enum BlocklistRegistry {

    static let allLists: [BlocklistEntry] = [
        BlocklistEntry(
            id: "easylist",
            name: "EasyList",
            author: "EasyList Authors",
            description: "The primary filter list that removes most adverts from international web pages.",
            websiteURL: URL(string: "https://easylist.to")!,
            category: .general,
            format: .adblockPlus
        ),
        BlocklistEntry(
            id: "easyprivacy",
            name: "EasyPrivacy",
            author: "EasyList Authors",
            description: "Supplementary filter list that removes all forms of tracking from the internet.",
            websiteURL: URL(string: "https://easylist.to")!,
            category: .privacy,
            format: .adblockPlus
        ),
        BlocklistEntry(
            id: "steven-black",
            name: "Steven Black Hosts",
            author: "Steven Black",
            description: "Unified hosts file consolidating several reputable hosts files with de-duplication.",
            websiteURL: URL(string: "https://github.com/StevenBlack/hosts")!,
            category: .general,
            format: .hosts
        ),
        BlocklistEntry(
            id: "oisd",
            name: "OISD",
            author: "sjhgvr",
            description: "Internet's #1 domain blocklist. Blocks ads, mobile ads, phishing, and telemetry.",
            websiteURL: URL(string: "https://oisd.nl")!,
            category: .general,
            format: .domainList
        ),
        BlocklistEntry(
            id: "peter-lowe",
            name: "Peter Lowe's List",
            author: "Peter Lowe",
            description: "A well-maintained list of ad-serving and tracking domains updated regularly.",
            websiteURL: URL(string: "https://pgl.yoyo.org/adservers")!,
            category: .general,
            format: .hosts
        ),
        BlocklistEntry(
            id: "adguard-dns",
            name: "AdGuard DNS Filter",
            author: "AdGuard",
            description: "Composite filter optimized for DNS-level blocking, combining multiple sources.",
            websiteURL: URL(string: "https://adguard.com/en/adguard-dns/overview.html")!,
            category: .general,
            format: .adblockPlus
        ),
        BlocklistEntry(
            id: "hagezi-pro",
            name: "HaGeZi Pro",
            author: "HaGeZi",
            description: "Multi-source DNS blocklist with aggressive blocking of ads, tracking, and telemetry.",
            websiteURL: URL(string: "https://github.com/hagezi/dns-blocklists")!,
            category: .general,
            format: .domainList
        ),
        BlocklistEntry(
            id: "1hosts-lite",
            name: "1Hosts Lite",
            author: "badmojr",
            description: "Lightweight, balanced blocklist minimizing false positives while blocking trackers.",
            websiteURL: URL(string: "https://github.com/badmojr/1Hosts")!,
            category: .privacy,
            format: .domainList
        ),
        BlocklistEntry(
            id: "disconnect-tracking",
            name: "Disconnect Tracking",
            author: "Disconnect",
            description: "Open-source list of trackers used by browsers like Firefox for tracking protection.",
            websiteURL: URL(string: "https://disconnect.me")!,
            category: .privacy,
            format: .domainList
        ),
        BlocklistEntry(
            id: "fanboy-annoyance",
            name: "Fanboy's Annoyance List",
            author: "Fanboy",
            description: "Blocks social media widgets, cookie notices, and other web page annoyances.",
            websiteURL: URL(string: "https://easylist.to")!,
            category: .general,
            format: .adblockPlus
        ),
        BlocklistEntry(
            id: "urlhaus",
            name: "URLhaus",
            author: "abuse.ch",
            description: "Database of malicious URLs used for malware distribution, updated frequently.",
            websiteURL: URL(string: "https://urlhaus.abuse.ch")!,
            category: .malware,
            format: .hosts
        ),
        BlocklistEntry(
            id: "phishing-army",
            name: "Phishing Army",
            author: "Phishing Army",
            description: "Blocklist of phishing-only domains sourced from multiple verified feeds.",
            websiteURL: URL(string: "https://phishing.army")!,
            category: .malware,
            format: .domainList
        ),
        BlocklistEntry(
            id: "dan-pollock",
            name: "Dan Pollock's Hosts",
            author: "Dan Pollock",
            description: "Long-running, conservative hosts file blocking ads and a few shock sites.",
            websiteURL: URL(string: "https://someonewhocares.org/hosts")!,
            category: .general,
            format: .hosts
        ),
        BlocklistEntry(
            id: "fanboy-social",
            name: "Fanboy's Social List",
            author: "Fanboy",
            description: "Removes social media integration widgets like share buttons and login prompts.",
            websiteURL: URL(string: "https://easylist.to")!,
            category: .social,
            format: .adblockPlus
        ),
        BlocklistEntry(
            id: "easylist-china",
            name: "EasyList China",
            author: "EasyList Authors",
            description: "Supplementary filter list targeting Chinese advertising and tracking domains.",
            websiteURL: URL(string: "https://easylist.to")!,
            category: .general,
            format: .adblockPlus
        ),
    ]

    static func lists(for category: BlocklistEntry.Category) -> [BlocklistEntry] {
        allLists.filter { $0.category == category }
    }
}
