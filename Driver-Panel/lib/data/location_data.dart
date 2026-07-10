/// Country / state / city options for registration address fields.
class LocationData {
  LocationData._();

  static const String defaultCountry = 'India';

  static const List<String> countries = [
    'Afghanistan',
    'Australia',
    'Bangladesh',
    'Bhutan',
    'Canada',
    'China',
    'France',
    'Germany',
    'India',
    'Indonesia',
    'Italy',
    'Japan',
    'Malaysia',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Pakistan',
    'Philippines',
    'Qatar',
    'Saudi Arabia',
    'Singapore',
    'South Africa',
    'Sri Lanka',
    'Thailand',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
  ];

  static const Map<String, List<String>> _statesByCountry = {
    'India': [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Andaman and Nicobar Islands',
      'Chandigarh',
      'Dadra and Nagar Haveli and Daman and Diu',
      'Delhi',
      'Jammu and Kashmir',
      'Ladakh',
      'Lakshadweep',
      'Puducherry',
    ],
    'United States': [
      'California',
      'Florida',
      'Illinois',
      'New York',
      'Texas',
      'Washington',
    ],
    'United Kingdom': [
      'England',
      'Northern Ireland',
      'Scotland',
      'Wales',
    ],
    'United Arab Emirates': [
      'Abu Dhabi',
      'Ajman',
      'Dubai',
      'Fujairah',
      'Ras Al Khaimah',
      'Sharjah',
      'Umm Al Quwain',
    ],
    'Canada': [
      'Alberta',
      'British Columbia',
      'Manitoba',
      'Ontario',
      'Quebec',
    ],
    'Australia': [
      'New South Wales',
      'Queensland',
      'South Australia',
      'Victoria',
      'Western Australia',
    ],
  };

  static const Map<String, Map<String, List<String>>> _citiesByCountryState = {
    'India': {
      'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Tirupati'],
      'Arunachal Pradesh': ['Itanagar', 'Tawang', 'Pasighat'],
      'Assam': ['Guwahati', 'Dibrugarh', 'Silchar', 'Jorhat'],
      'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur'],
      'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Durg'],
      'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
      'Haryana': [
        'Ambala',
        'Assandh',
        'Bahadurgarh',
        'Ballabgarh',
        'Bawal',
        'Bhiwani',
        'Charkhi Dadri',
        'Dharuhera',
        'Ellenabad',
        'Faridabad',
        'Fatehabad',
        'Gohana',
        'Gurugram',
        'Hansi',
        'Hisar',
        'Hodal',
        'Jagadhri',
        'Jhajjar',
        'Jind',
        'Kaithal',
        'Karnal',
        'Kundli',
        'Kurukshetra',
        'Manesar',
        'Mahendragarh',
        'Narnaul',
        'Narwana',
        'Nuh',
        'Palwal',
        'Panchkula',
        'Panipat',
        'Pinjore',
        'Pundri',
        'Ratia',
        'Rewari',
        'Rohtak',
        'Samalkha',
        'Sirsa',
        'Sohna',
        'Sonipat',
        'Thanesar',
        'Tohana',
        'Yamunanagar',
      ],
      'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Manali', 'Solan'],
      'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro'],
      'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi', 'Belagavi'],
      'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
      'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain'],
      'Maharashtra': [
        'Mumbai',
        'Pune',
        'Nagpur',
        'Nashik',
        'Thane',
        'Aurangabad',
        'Akola',
        'Amravati',
        'Kolhapur',
        'Solapur',
      ],
      'Manipur': ['Imphal', 'Thoubal', 'Bishnupur'],
      'Meghalaya': ['Shillong', 'Tura', 'Jowai'],
      'Mizoram': ['Aizawl', 'Lunglei', 'Champhai'],
      'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
      'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri'],
      'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Mohali'],
      'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
      'Sikkim': ['Gangtok', 'Namchi', 'Gyalshing'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
      'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
      'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
      'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Noida', 'Ghaziabad', 'Varanasi', 'Agra'],
      'Uttarakhand': ['Dehradun', 'Haridwar', 'Haldwani', 'Rishikesh'],
      'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri', 'Asansol'],
      'Andaman and Nicobar Islands': ['Port Blair'],
      'Chandigarh': ['Chandigarh'],
      'Dadra and Nagar Haveli and Daman and Diu': ['Daman', 'Diu', 'Silvassa'],
      'Delhi': ['New Delhi', 'Delhi'],
      'Jammu and Kashmir': ['Srinagar', 'Jammu', 'Anantnag'],
      'Ladakh': ['Leh', 'Kargil'],
      'Lakshadweep': ['Kavaratti'],
      'Puducherry': ['Puducherry', 'Karaikal', 'Yanam'],
    },
    'United States': {
      'California': ['Los Angeles', 'San Francisco', 'San Diego', 'San Jose'],
      'Florida': ['Miami', 'Orlando', 'Tampa', 'Jacksonville'],
      'Illinois': ['Chicago', 'Springfield', 'Naperville'],
      'New York': ['New York City', 'Buffalo', 'Rochester', 'Albany'],
      'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio'],
      'Washington': ['Seattle', 'Spokane', 'Tacoma'],
    },
    'United Kingdom': {
      'England': ['London', 'Manchester', 'Birmingham', 'Liverpool', 'Leeds'],
      'Northern Ireland': ['Belfast', 'Derry'],
      'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen'],
      'Wales': ['Cardiff', 'Swansea', 'Newport'],
    },
    'United Arab Emirates': {
      'Abu Dhabi': ['Abu Dhabi', 'Al Ain'],
      'Ajman': ['Ajman'],
      'Dubai': ['Dubai'],
      'Fujairah': ['Fujairah'],
      'Ras Al Khaimah': ['Ras Al Khaimah'],
      'Sharjah': ['Sharjah'],
      'Umm Al Quwain': ['Umm Al Quwain'],
    },
    'Canada': {
      'Alberta': ['Calgary', 'Edmonton'],
      'British Columbia': ['Vancouver', 'Victoria', 'Surrey'],
      'Manitoba': ['Winnipeg'],
      'Ontario': ['Toronto', 'Ottawa', 'Mississauga', 'Hamilton'],
      'Quebec': ['Montreal', 'Quebec City'],
    },
    'Australia': {
      'New South Wales': ['Sydney', 'Newcastle', 'Wollongong'],
      'Queensland': ['Brisbane', 'Gold Coast', 'Cairns'],
      'South Australia': ['Adelaide'],
      'Victoria': ['Melbourne', 'Geelong'],
      'Western Australia': ['Perth', 'Fremantle'],
    },
  };

  static List<String> statesForCountry(String? country) {
    if (country == null || country.isEmpty) return [];
    return List<String>.from(_statesByCountry[country] ?? const []);
  }

  static List<String> citiesFor(String? country, String? state) {
    if (country == null ||
        country.isEmpty ||
        state == null ||
        state.isEmpty) {
      return [];
    }
    final countryMap = _citiesByCountryState[country];
    if (countryMap == null) return [];
    return List<String>.from(countryMap[state] ?? const []);
  }

  static bool hasStateData(String? country) =>
      statesForCountry(country).isNotEmpty;

  static bool hasCityData(String? country, String? state) =>
      citiesFor(country, state).isNotEmpty;

  static const String defaultServiceCity = 'Akola';

  /// Flat, sorted list of Indian cities available for captain registration.
  static List<String> get allServiceCities {
    final cities = <String>{};
    final india = _citiesByCountryState[defaultCountry];
    if (india != null) {
      for (final list in india.values) {
        cities.addAll(list);
      }
    }
    return cities.toList()..sort();
  }

  static String? stateForCity(
    String city, {
    String country = defaultCountry,
  }) {
    final states = _citiesByCountryState[country];
    if (states == null) return null;
    for (final entry in states.entries) {
      if (entry.value.contains(city)) return entry.key;
    }
    return null;
  }
}
