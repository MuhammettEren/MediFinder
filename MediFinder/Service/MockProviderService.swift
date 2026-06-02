import Foundation

/// Mock provider service with deterministic data, delay simulation, and error injection.
final class MockProviderService: ProviderServiceProtocol, Sendable {
    private let shouldFail: Bool
    private let delay: Duration

    /// Creates a mock provider service.
    /// - Parameters:
    ///   - shouldFail: Indicates whether requests should throw a network-like error.
    ///   - delay: Artificial async delay used to surface loading states.
    init(shouldFail: Bool = false, delay: Duration = .milliseconds(650)) {
        self.shouldFail = shouldFail
        self.delay = delay
    }

    /// Fetches all mock providers.
    func fetchProviders() async throws -> [Provider] {
        try await simulateRequest()
        return Self.providers
    }

    /// Fetches a single provider by identifier.
    /// - Parameter id: Stable provider identifier.
    func fetchProvider(by id: String) async throws -> Provider {
        try await simulateRequest()

        guard let provider = Self.providers.first(where: { $0.id == id }) else {
            throw ProviderServiceError.providerNotFound
        }

        return provider
    }

    /// Returns available country filters.
    func availableCountries() async throws -> [Country] {
        try await simulateRequest()
        return Country.allCases
    }

    /// Returns available city filters for a country.
    /// - Parameter country: Country to read cities for.
    func availableCities(for country: Country) async throws -> [String] {
        try await simulateRequest()
        return Self.citiesByCountry[country, default: []]
    }

    private func simulateRequest() async throws {
        try await Task.sleep(for: delay)

        if Task.isCancelled {
            throw CancellationError()
        }

        if shouldFail {
            throw ProviderServiceError.networkUnavailable
        }
    }
}

extension MockProviderService {
    private static let citiesByCountry: [Country: [String]] = [
        .turkey: ["Istanbul", "Ankara", "Izmir", "Bursa", "Antalya", "Mugla", "Manisa"],
        .germany: ["Berlin", "Munich"],
        .unitedKingdom: ["London", "Manchester"],
        .unitedStates: ["New York", "Los Angeles", "Chicago"],
        .austria: ["Vienna"],
        .ireland: ["Dublin"],
        .portugal: ["Lisbon"],
        .poland: ["Poznan"],
        .afghanistan: ["Bamyan"]
    ]

    static let providers: [Provider] = [
        Provider(
            id: "tr-001",
            name: "Nadiye Haciomeroglu",
            type: .doctor,
            specialty: .internalMedicine,
            location: Location(country: .turkey, city: "Istanbul", address: "Nisantasi, Tesvikiye Cad. No:45"),
            rating: 4.8,
            reviewCount: 234,
            bio: "Istanbul merkezli aile hekimligi ve koruyucu saglik deneyimiyle hastalarina butuncul takip sunar.",
            contactInfo: ContactInfo(phone: "+90 212 555 0001", email: "info@nadiyehealth.com", website: "www.nadiyehealth.com"),
            imageURL: nil,
            yearsOfExperience: 18,
            languages: ["TR", "EN"],
            isVerified: true
        ),
        Provider(
            id: "tr-002",
            name: "Hicran Ercan Diker",
            type: .doctor,
            specialty: .dermatology,
            location: Location(country: .turkey, city: "Istanbul", address: "Bagdat Cad. No:120"),
            rating: 4.6,
            reviewCount: 189,
            bio: "Dermatoloji ve kozmetik dermatoloji alaninda lazer tedavileri, akne ve cilt yenileme uygulamalarinda uzmanlasmistir.",
            contactInfo: ContactInfo(phone: "+90 216 555 0002", email: "info@hicranderm.com", website: "www.hicranderm.com"),
            imageURL: nil,
            yearsOfExperience: 12,
            languages: ["TR", "EN", "DE"],
            isVerified: true
        ),
        Provider(
            id: "tr-003",
            name: "Acibadem Ankara Hospital",
            type: .hospital,
            specialty: .generalSurgery,
            location: Location(country: .turkey, city: "Ankara", address: "Cankaya, Saglik Cad. No:14"),
            rating: 4.7,
            reviewCount: 567,
            bio: "Ankara'nin onde gelen ozel hastanelerinden biri. Cok disiplinli tani, tedavi ve 24/7 acil servis sunar.",
            contactInfo: ContactInfo(phone: "+90 312 555 0003", email: "info@acibademankara.com", website: "www.acibademankara.com"),
            imageURL: nil,
            yearsOfExperience: 25,
            languages: ["TR", "EN", "AR"],
            isVerified: true
        ),
        Provider(
            id: "tr-004",
            name: "Dentacare Clinic",
            type: .clinic,
            specialty: .dentistry,
            location: Location(country: .turkey, city: "Izmir", address: "123 Kordon Boyu, Alsancak"),
            rating: 4.3,
            reviewCount: 98,
            bio: "Modern dis hekimligi klinigi. Implant, ortodonti ve estetik dis tedavilerinde dijital tani altyapisi kullanir.",
            contactInfo: ContactInfo(phone: "+90 232 555 0004", email: nil, website: nil),
            imageURL: nil,
            yearsOfExperience: 8,
            languages: ["TR", "EN"],
            isVerified: false
        ),
        Provider(
            id: "tr-005",
            name: "Serkan Aygin",
            type: .specialist,
            specialty: .plasticSurgery,
            location: Location(country: .turkey, city: "Istanbul", address: "Sisli, Abide-i Hurriyet Cad. No:88"),
            rating: 4.9,
            reviewCount: 312,
            bio: "Estetik cerrahi ve sac restorasyonu alaninda uluslararasi hasta deneyimine sahip uzman.",
            contactInfo: ContactInfo(phone: "+90 212 555 0005", email: "info@serkanaygin.com", website: "www.serkanaygin.com"),
            imageURL: nil,
            yearsOfExperience: 22,
            languages: ["TR", "EN"],
            isVerified: true
        ),
        Provider(
            id: "de-006",
            name: "Dr. Hans Muller",
            type: .doctor,
            specialty: .orthopedics,
            location: Location(country: .germany, city: "Berlin", address: "Friedrichstrasse 110"),
            rating: 4.5,
            reviewCount: 156,
            bio: "Ortopedi ve travmatoloji uzmani. Spor yaralanmalari ve eklem protezi cerrahisinde uzmanlasmistir.",
            contactInfo: ContactInfo(phone: "+49 30 555 0006", email: "hans@ortho-berlin.de", website: "www.ortho-berlin.de"),
            imageURL: nil,
            yearsOfExperience: 15,
            languages: ["DE", "EN"],
            isVerified: true
        ),
        Provider(
            id: "de-007",
            name: "Charite Eye Center",
            type: .clinic,
            specialty: .ophthalmology,
            location: Location(country: .germany, city: "Berlin", address: "Chariteplatz 1"),
            rating: 4.8,
            reviewCount: 423,
            bio: "Avrupa'nin onde gelen goz merkezlerinden biri. Lazer goz ameliyati, katarakt ve retina cerrahisi sunar.",
            contactInfo: ContactInfo(phone: "+49 30 555 0007", email: "eye@charite.de", website: "www.charite-eye.de"),
            imageURL: nil,
            yearsOfExperience: 30,
            languages: ["DE", "EN", "FR"],
            isVerified: true
        ),
        Provider(
            id: "de-008",
            name: "Dr. Anna Schmidt",
            type: .doctor,
            specialty: .pediatrics,
            location: Location(country: .germany, city: "Munich", address: "Leopoldstrasse 45"),
            rating: 4.7,
            reviewCount: 201,
            bio: "Cocuk sagligi ve hastaliklari uzmani. Yenidogan bakimi ve cocuk alerji alaninda deneyimlidir.",
            contactInfo: ContactInfo(phone: "+49 89 555 0008", email: "anna@kids-munich.de", website: "www.kids-munich.de"),
            imageURL: nil,
            yearsOfExperience: 10,
            languages: ["DE", "EN", "TR"],
            isVerified: true
        ),
        Provider(
            id: "uk-009",
            name: "Dr. James Wilson",
            type: .doctor,
            specialty: .cardiology,
            location: Location(country: .unitedKingdom, city: "London", address: "Harley Street 21"),
            rating: 4.9,
            reviewCount: 445,
            bio: "Koroner bypass ve minimal invaziv kalp cerrahisi alaninda NHS ve ozel sektor deneyimine sahiptir.",
            contactInfo: ContactInfo(phone: "+44 20 555 0009", email: "james@cardio-london.co.uk", website: "www.cardio-london.co.uk"),
            imageURL: nil,
            yearsOfExperience: 25,
            languages: ["EN"],
            isVerified: true
        ),
        Provider(
            id: "uk-010",
            name: "Harley Street Clinic",
            type: .clinic,
            specialty: .dermatology,
            location: Location(country: .unitedKingdom, city: "London", address: "Harley Street 88"),
            rating: 4.6,
            reviewCount: 234,
            bio: "Londra'nin prestijli Harley Street bolgesinde medikal ve estetik dermatoloji hizmeti verir.",
            contactInfo: ContactInfo(phone: "+44 20 555 0010", email: "hello@harleyderm.co.uk", website: "www.harleyderm.co.uk"),
            imageURL: nil,
            yearsOfExperience: 15,
            languages: ["EN", "FR", "AR"],
            isVerified: true
        ),
        Provider(
            id: "us-011",
            name: "Dr. Michael Chen",
            type: .doctor,
            specialty: .orthopedics,
            location: Location(country: .unitedStates, city: "New York", address: "5th Avenue 456"),
            rating: 4.8,
            reviewCount: 389,
            bio: "Omurga cerrahisi ve spor tibbi uzmani. Profesyonel takim hekimligi deneyimine sahiptir.",
            contactInfo: ContactInfo(phone: "+1 212 555 0011", email: "chen@nyortho.com", website: "www.nyortho.com"),
            imageURL: nil,
            yearsOfExperience: 20,
            languages: ["EN", "ZH"],
            isVerified: true
        ),
        Provider(
            id: "us-012",
            name: "Mayo Clinic LA",
            type: .hospital,
            specialty: .internalMedicine,
            location: Location(country: .unitedStates, city: "Los Angeles", address: "Wilshire Blvd 300"),
            rating: 4.9,
            reviewCount: 678,
            bio: "Cok disiplinli tani ve tedavi merkezi. Global hasta deneyimi ve ileri tani altyapisi sunar.",
            contactInfo: ContactInfo(phone: "+1 310 555 0012", email: "la@mayoclinic.com", website: "www.mayoclinic.org"),
            imageURL: nil,
            yearsOfExperience: 35,
            languages: ["EN", "ES", "ZH", "KO"],
            isVerified: true
        ),
        Provider(
            id: "at-013",
            name: "Azzawi Zahnarzt",
            type: .doctor,
            specialty: .dentistry,
            location: Location(country: .austria, city: "Vienna", address: "Mariahilfer Strasse 52"),
            rating: 4.5,
            reviewCount: 141,
            bio: "Viyana merkezli dis hekimi. Estetik dis tedavileri, implant ve koruyucu dis sagligi uygulamalari sunar.",
            contactInfo: ContactInfo(phone: "+43 1 555 0013", email: "info@azzawi.at", website: "www.azzawi.at"),
            imageURL: nil,
            yearsOfExperience: 11,
            languages: ["DE", "EN", "AR"],
            isVerified: false
        ),
        Provider(
            id: "ie-014",
            name: "Laura Fee",
            type: .doctor,
            specialty: .dentistry,
            location: Location(country: .ireland, city: "Dublin", address: "Dawson Street 8"),
            rating: 4.7,
            reviewCount: 176,
            bio: "Dublin merkezli estetik ve restoratif dis hekimligi odakli klinik deneyimine sahiptir.",
            contactInfo: ContactInfo(phone: "+353 1 555 0014", email: "laura@dublinsmile.ie", website: "www.dublinsmile.ie"),
            imageURL: nil,
            yearsOfExperience: 13,
            languages: ["EN"],
            isVerified: true
        ),
        Provider(
            id: "pt-015",
            name: "Eduardo Bastos",
            type: .doctor,
            specialty: .dentistry,
            location: Location(country: .portugal, city: "Lisbon", address: nil),
            rating: 4.2,
            reviewCount: 86,
            bio: "Lizbon'da implantoloji ve estetik dis tedavilerine odaklanan hasta merkezli bir hekimdir.",
            contactInfo: ContactInfo(phone: "+351 21 555 0015", email: "eduardo@lisbonsmile.pt", website: nil),
            imageURL: nil,
            yearsOfExperience: 9,
            languages: ["PT", "EN"],
            isVerified: false
        ),
        Provider(
            id: "pl-016",
            name: "Michal Kukulski",
            type: .doctor,
            specialty: .plasticSurgery,
            location: Location(country: .poland, city: "Poznan", address: "Mickiewicza 18"),
            rating: 4.7,
            reviewCount: 204,
            bio: "Poznan merkezli plastik cerrahi uzmani. Rekonstruktif ve estetik uygulamalarda deneyimlidir.",
            contactInfo: ContactInfo(phone: "+48 61 555 0016", email: "michal@poznansurgery.pl", website: "www.poznansurgery.pl"),
            imageURL: nil,
            yearsOfExperience: 14,
            languages: ["PL", "EN"],
            isVerified: true
        ),
        Provider(
            id: "pl-017",
            name: "Julia Wisniewska",
            type: .doctor,
            specialty: .physiatry,
            location: Location(country: .poland, city: "Poznan", address: "Garbary 30"),
            rating: 4.6,
            reviewCount: 167,
            bio: "Fizik tedavi ve rehabilitasyon alaninda kas-iskelet sistemi sorunlari ve spor rehabilitasyonu uzerine calisir.",
            contactInfo: ContactInfo(phone: "+48 61 555 0017", email: "julia@rehabpoznan.pl", website: "www.rehabpoznan.pl"),
            imageURL: nil,
            yearsOfExperience: 10,
            languages: ["PL", "EN"],
            isVerified: true
        ),
        Provider(
            id: "tr-018",
            name: "Yasemin Savas Klinigi",
            type: .clinic,
            specialty: .gynecology,
            location: Location(country: .turkey, city: "Mugla", address: "Mentese, Cumhuriyet Cad. No:7"),
            rating: 4.4,
            reviewCount: 145,
            bio: "Kadin sagligi ve medikal estetik hizmetlerini tek merkezde sunan butik klinik.",
            contactInfo: ContactInfo(phone: "+90 252 555 0018", email: nil, website: "www.yaseminsavas.com"),
            imageURL: nil,
            yearsOfExperience: 7,
            languages: ["TR", "EN"],
            isVerified: true
        ),
        Provider(
            id: "tr-019",
            name: "Ozel Egeumut Hastanesi",
            type: .hospital,
            specialty: .ophthalmology,
            location: Location(country: .turkey, city: "Manisa", address: "Yunusemre, Hastane Cad. No:12"),
            rating: 4.1,
            reviewCount: 93,
            bio: "Manisa merkezli ozel hastane. Goz hastaliklari, dahiliye ve acil servis birimleriyle hizmet verir.",
            contactInfo: ContactInfo(phone: "+90 236 555 0019", email: "info@egeumut.com", website: "www.egeumut.com"),
            imageURL: nil,
            yearsOfExperience: 16,
            languages: ["TR"],
            isVerified: true
        ),
        Provider(
            id: "af-020",
            name: "test hospital",
            type: .hospital,
            specialty: .ophthalmology,
            location: Location(country: .afghanistan, city: "Bamyan", address: nil),
            rating: 3.9,
            reviewCount: 42,
            bio: "Bolgesel goz sagligi hizmetleri sunan hastane profili.",
            contactInfo: ContactInfo(phone: nil, email: "info@testhospital.af", website: nil),
            imageURL: nil,
            yearsOfExperience: 6,
            languages: ["FA", "EN"],
            isVerified: false
        )
    ]
}
