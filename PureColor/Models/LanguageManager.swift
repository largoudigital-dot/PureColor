import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case englishUK = "en-GB"
    case arabic = "ar"
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case spanishMexico = "es-MX"
    case chinese = "zh-Hans"
    case japanese = "ja"
    case korean = "ko"
    case portuguese = "pt-BR"
    case russian = "ru"
    case turkish = "tr"
    case dutch = "nl"
    case swedish = "sv"
    case danish = "da"
    case norwegian = "nb"
    case finnish = "fi"
    case polish = "pl"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"
    case hindi = "hi"
    case italian = "it"
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .englishUK: return "English (UK)"
        case .arabic: return "العربية"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        case .spanishMexico: return "Español (México)"
        case .chinese: return "简体中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .portuguese: return "Português"
        case .italian: return "Italiano"
        case .russian: return "Русский"
        case .turkish: return "Türkçe"
        case .dutch: return "Nederlands"
        case .swedish: return "Svenska"
        case .danish: return "Dansk"
        case .norwegian: return "Norsk"
        case .finnish: return "Suomi"
        case .polish: return "Polski"
        case .thai: return "ไทย"
        case .vietnamese: return "Tiếng Việt"
        case .indonesian: return "Bahasa Indonesia"
        case .hindi: return "हिन्दी"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selected_language")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "selected_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.selectedLanguage = lang
        } else {
            // Default to device language or English
            self.selectedLanguage = .english
        }
    }
    
    var locale: Locale {
        Locale(identifier: selectedLanguage.rawValue)
    }
}
