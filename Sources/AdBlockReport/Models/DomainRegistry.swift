import Foundation

/// Independently curated list of well-known ad, analytics, and tracking domains.
/// These are all publicly documented advertising and analytics endpoints.
enum DomainRegistry {

    static let allDomains: [TestDomain] = {
        var domains: [TestDomain] = []

        // MARK: - Ads

        for host in [
            "adtago.s3.amazonaws.com",
            "analyticsengine.s3.amazonaws.com",
            "advice-ads.s3.amazonaws.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Amazon", category: .ads))
        }

        for host in [
            "pagead2.googlesyndication.com",
            "adservice.google.com",
            "pagead2.googleadservices.com",
            "afs.googlesyndication.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Google Ads", category: .ads))
        }

        for host in [
            "stats.g.doubleclick.net",
            "ad.doubleclick.net",
            "static.doubleclick.net",
            "m.doubleclick.net",
            "mediavisor.doubleclick.net",
        ] {
            domains.append(TestDomain(hostname: host, provider: "DoubleClick", category: .ads))
        }

        for host in [
            "ads30.adcolony.com",
            "adc3-launch.adcolony.com",
            "events3alt.adcolony.com",
            "wd.adcolony.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "AdColony", category: .ads))
        }

        for host in [
            "static.media.net",
            "media.net",
            "adservetx.media.net",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Media.net", category: .ads))
        }

        // MARK: - Analytics

        for host in [
            "analytics.google.com",
            "click.googleanalytics.com",
            "google-analytics.com",
            "ssl.google-analytics.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Google Analytics", category: .analytics))
        }

        for host in [
            "adm.hotjar.com",
            "identify.hotjar.com",
            "insights.hotjar.com",
            "script.hotjar.com",
            "surveys.hotjar.com",
            "careers.hotjar.com",
            "events.hotjar.io",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Hotjar", category: .analytics))
        }

        for host in [
            "mouseflow.com",
            "cdn.mouseflow.com",
            "o2.mouseflow.com",
            "gtm.mouseflow.com",
            "api.mouseflow.com",
            "tools.mouseflow.com",
            "cdn-test.mouseflow.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "MouseFlow", category: .analytics))
        }

        for host in [
            "freshmarketer.com",
            "claritybt.freshmarketer.com",
            "fwtracks.freshmarketer.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "FreshWorks", category: .analytics))
        }

        for host in [
            "luckyorange.com",
            "api.luckyorange.com",
            "realtime.luckyorange.com",
            "cdn.luckyorange.com",
            "w1.luckyorange.com",
            "upload.luckyorange.net",
            "cs.luckyorange.net",
            "settings.luckyorange.net",
        ] {
            domains.append(TestDomain(hostname: host, provider: "LuckyOrange", category: .analytics))
        }

        domains.append(TestDomain(hostname: "stats.wp.com", provider: "WordPress Stats", category: .analytics))

        // MARK: - Error Trackers

        for host in [
            "notify.bugsnag.com",
            "sessions.bugsnag.com",
            "api.bugsnag.com",
            "app.bugsnag.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Bugsnag", category: .errorTrackers))
        }

        for host in [
            "browser.sentry-cdn.com",
            "app.getsentry.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Sentry", category: .errorTrackers))
        }

        // MARK: - Social Trackers

        for host in [
            "pixel.facebook.com",
            "an.facebook.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Facebook", category: .socialTrackers))
        }

        for host in [
            "static.ads-twitter.com",
            "ads-api.twitter.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Twitter", category: .socialTrackers))
        }

        for host in [
            "ads.linkedin.com",
            "analytics.pointdrive.linkedin.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "LinkedIn", category: .socialTrackers))
        }

        for host in [
            "ads.pinterest.com",
            "log.pinterest.com",
            "trk.pinterest.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Pinterest", category: .socialTrackers))
        }

        for host in [
            "events.reddit.com",
            "events.redditmedia.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Reddit", category: .socialTrackers))
        }

        domains.append(TestDomain(hostname: "ads.youtube.com", provider: "YouTube", category: .socialTrackers))

        for host in [
            "ads-api.tiktok.com",
            "analytics.tiktok.com",
            "ads-sg.tiktok.com",
            "analytics-sg.tiktok.com",
            "business-api.tiktok.com",
            "ads.tiktok.com",
            "log.byteoversea.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "TikTok", category: .socialTrackers))
        }

        // MARK: - Mix

        for host in [
            "ads.yahoo.com",
            "analytics.yahoo.com",
            "geo.yahoo.com",
            "udcm.yahoo.com",
            "analytics.query.yahoo.com",
            "partnerads.ysm.yahoo.com",
            "log.fc.yahoo.com",
            "gemini.yahoo.com",
            "adtech.yahooinc.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Yahoo", category: .mix))
        }

        for host in [
            "extmaps-api.yandex.net",
            "appmetrica.yandex.ru",
            "adfstat.yandex.ru",
            "metrika.yandex.ru",
            "offerwall.yandex.net",
            "adfox.yandex.ru",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Yandex", category: .mix))
        }

        for host in [
            "auction.unityads.unity3d.com",
            "webview.unityads.unity3d.com",
            "config.unityads.unity3d.com",
            "adserver.unityads.unity3d.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Unity", category: .mix))
        }

        // MARK: - OEMs

        for host in [
            "iot-eu-logser.realme.com",
            "iot-logser.realme.com",
            "bdapi-ads.realmemobile.com",
            "bdapi-in-ads.realmemobile.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Realme", category: .oems))
        }

        for host in [
            "api.ad.xiaomi.com",
            "data.mistat.xiaomi.com",
            "data.mistat.india.xiaomi.com",
            "data.mistat.rus.xiaomi.com",
            "sdkconfig.ad.xiaomi.com",
            "sdkconfig.ad.intl.xiaomi.com",
            "tracking.rus.miui.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Xiaomi", category: .oems))
        }

        for host in [
            "adsfs.oppomobile.com",
            "adx.ads.oppomobile.com",
            "ck.ads.oppomobile.com",
            "data.ads.oppomobile.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Oppo", category: .oems))
        }

        for host in [
            "metrics.data.hicloud.com",
            "metrics2.data.hicloud.com",
            "grs.hicloud.com",
            "logservice.hicloud.com",
            "logservice1.hicloud.com",
            "logbak.hicloud.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Huawei", category: .oems))
        }

        for host in [
            "click.oneplus.cn",
            "open.oneplus.net",
        ] {
            domains.append(TestDomain(hostname: host, provider: "OnePlus", category: .oems))
        }

        for host in [
            "samsungads.com",
            "smetrics.samsung.com",
            "nmetrics.samsung.com",
            "samsung-com.112.2o7.net",
            "analytics-api.samsunghealthcn.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Samsung", category: .oems))
        }

        for host in [
            "iadsdk.apple.com",
            "metrics.icloud.com",
            "metrics.mzstatic.com",
            "api-adservices.apple.com",
            "books-analytics-events.apple.com",
            "weather-analytics-events.apple.com",
            "notes-analytics-events.apple.com",
        ] {
            domains.append(TestDomain(hostname: host, provider: "Apple", category: .oems))
        }

        return domains
    }()

    static func domains(for category: TestCategory) -> [TestDomain] {
        allDomains.filter { $0.category == category }
    }

    static var providers: [String: [TestDomain]] {
        Dictionary(grouping: allDomains, by: \.provider)
    }
}
