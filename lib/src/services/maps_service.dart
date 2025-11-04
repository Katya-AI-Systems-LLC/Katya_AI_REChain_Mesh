import 'dart:async';
import 'dart:math';

/// Сервис карт и геолокации
class MapsService {
  static final MapsService _instance = MapsService._internal();
  factory MapsService() => _instance;
  static MapsService get instance => _instance;
  MapsService._internal();

  final StreamController<LocationData> _onLocationUpdate =
      StreamController.broadcast();
  final StreamController<Place> _onPlaceFound = StreamController.broadcast();

  // Данные
  LocationData? _currentLocation;
  final List<Place> _nearbyPlaces = [];
  final List<Route> _routes = [];
  bool _isTracking = false;

  Stream<LocationData> get onLocationUpdate => _onLocationUpdate.stream;
  Stream<Place> get onPlaceFound => _onPlaceFound.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Maps Service...');

    // Симулируем получение текущей локации
    _currentLocation = LocationData(
      latitude: 55.7558,
      longitude: 37.6173,
      accuracy: 10.0,
      altitude: 0.0,
      speed: 0.0,
      heading: 0.0,
      timestamp: DateTime.now(),
    );

    print('Maps Service initialized');
  }

  /// Получение текущей локации
  Future<LocationData?> getCurrentLocation() async {
    if (_currentLocation == null) {
      await initialize();
    }
    return _currentLocation;
  }

  /// Поиск мест поблизости
  Future<List<Place>> searchNearby({
    required LocationData center,
    required double radiusKm,
    PlaceType? type,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final places = <Place>[];

    // Симулируем данные
    final mockPlaces = [
      Place(
        id: 'place_1',
        name: 'Ресторан Катя',
        address: 'Москва, Тверская, 10',
        location: LocationData(
          latitude: 55.7580,
          longitude: 37.6080,
          accuracy: 10.0,
          altitude: 0.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        ),
        type: PlaceType.restaurant,
        rating: 4.5,
        photos: [],
      ),
      Place(
        id: 'place_2',
        name: 'Парк Горького',
        address: 'Москва, Крымский Вал',
        location: LocationData(
          latitude: 55.7288,
          longitude: 37.6017,
          accuracy: 10.0,
          altitude: 0.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        ),
        type: PlaceType.park,
        rating: 4.8,
        photos: [],
      ),
      Place(
        id: 'place_3',
        name: 'ТЦ Европейский',
        address: 'Москва, Площадь Киевского Вокзала',
        location: LocationData(
          latitude: 55.7437,
          longitude: 37.5656,
          accuracy: 10.0,
          altitude: 0.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        ),
        type: PlaceType.shopping,
        rating: 4.3,
        photos: [],
      ),
    ];

    for (final place in mockPlaces) {
      final distance = _calculateDistance(
        center.latitude,
        center.longitude,
        place.location.latitude,
        place.location.longitude,
      );

      if (distance <= radiusKm) {
        if (type == null || place.type == type) {
          if (query == null ||
              place.name.toLowerCase().contains(query.toLowerCase()) ||
              place.address.toLowerCase().contains(query.toLowerCase())) {
            places.add(place);
          }
        }
      }
    }

    _nearbyPlaces.clear();
    _nearbyPlaces.addAll(places);

    return places;
  }

  /// Построение маршрута
  Future<Route> buildRoute({
    required LocationData origin,
    required LocationData destination,
    RouteMode mode = RouteMode.driving,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Вычисляем расстояние и время
    final distanceKm = _calculateDistance(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    final duration = Duration(
      minutes: (distanceKm / _getAverageSpeed(mode) * 60).round(),
    );

    final route = Route(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      origin: origin,
      destination: destination,
      mode: mode,
      distance: distanceKm,
      duration: duration,
      steps: _generateRouteSteps(origin, destination),
      polyline: _generatePolyline(origin, destination),
    );

    _routes.add(route);
    return route;
  }

  /// Геокодирование адреса
  Future<LocationData?> geocode(String address) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Симулируем геокодирование
    final mockGeocodes = {
      'Москва, Красная площадь': LocationData(
        latitude: 55.7539,
        longitude: 37.6208,
        accuracy: 10.0,
        altitude: 0.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      ),
      'Москва, Кремль': LocationData(
        latitude: 55.7520,
        longitude: 37.6173,
        accuracy: 10.0,
        altitude: 0.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      ),
    };

    return mockGeocodes[address] ?? _currentLocation;
  }

  /// Обратное геокодирование
  Future<String> reverseGeocode(LocationData location) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Симулируем обратное геокодирование
    return 'Москва, ул. Примерная, 123';
  }

  /// Запуск отслеживания локации
  Future<void> startTracking() async {
    if (_isTracking) return;

    _isTracking = true;
    print('Started location tracking');

    // Симулируем периодическое обновление локации
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      _updateLocation();
    });
  }

  /// Остановка отслеживания локации
  void stopTracking() {
    _isTracking = false;
    print('Stopped location tracking');
  }

  // Приватные методы

  void _updateLocation() {
    if (_currentLocation == null) return;

    // Симулируем небольшое движение
    final random = Random();
    final latDelta = (random.nextDouble() - 0.5) * 0.0001;
    final lonDelta = (random.nextDouble() - 0.5) * 0.0001;

    _currentLocation = LocationData(
      latitude: _currentLocation!.latitude + latDelta,
      longitude: _currentLocation!.longitude + lonDelta,
      accuracy: _currentLocation!.accuracy,
      altitude: _currentLocation!.altitude,
      speed: _currentLocation!.speed,
      heading: _currentLocation!.heading,
      timestamp: DateTime.now(),
    );

    _onLocationUpdate.add(_currentLocation!);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // км

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  double _getAverageSpeed(RouteMode mode) {
    switch (mode) {
      case RouteMode.walking:
        return 5.0; // км/ч
      case RouteMode.cycling:
        return 15.0; // км/ч
      case RouteMode.driving:
        return 50.0; // км/ч
      case RouteMode.transit:
        return 30.0; // км/ч
    }
  }

  List<RouteStep> _generateRouteSteps(
      LocationData origin, LocationData destination) {
    // Генерируем упрощенные шаги маршрута
    return [
      RouteStep(
        instruction: 'Начните движение от точки отправления',
        distance: 0,
        duration: Duration.zero,
        location: origin,
      ),
      RouteStep(
        instruction: 'Следуйте до места назначения',
        distance: _calculateDistance(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        ),
        duration: const Duration(minutes: 10),
        location: destination,
      ),
    ];
  }

  List<LocationData> _generatePolyline(
      LocationData origin, LocationData destination) {
    // Генерируем упрощенную полилинию
    final points = <LocationData>[];

    const steps = 10;
    for (int i = 0; i <= steps; i++) {
      final factor = i / steps;

      points.add(LocationData(
        latitude:
            origin.latitude + (destination.latitude - origin.latitude) * factor,
        longitude: origin.longitude +
            (destination.longitude - origin.longitude) * factor,
        accuracy: 10.0,
        altitude: 0.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      ));
    }

    return points;
  }

  void dispose() {
    stopTracking();
    _onLocationUpdate.close();
    _onPlaceFound.close();
  }
}

// Модели данных

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });
}

class Place {
  final String id;
  final String name;
  final String address;
  final LocationData location;
  final PlaceType type;
  final double rating;
  final List<String> photos;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.type,
    required this.rating,
    required this.photos,
  });
}

enum PlaceType {
  restaurant,
  cafe,
  hotel,
  shopping,
  park,
  museum,
  hospital,
  gasStation,
  atm,
  other,
}

class Route {
  final String id;
  final LocationData origin;
  final LocationData destination;
  final RouteMode mode;
  final double distance;
  final Duration duration;
  final List<RouteStep> steps;
  final List<LocationData> polyline;

  const Route({
    required this.id,
    required this.origin,
    required this.destination,
    required this.mode,
    required this.distance,
    required this.duration,
    required this.steps,
    required this.polyline,
  });
}

enum RouteMode {
  walking,
  cycling,
  driving,
  transit,
}

class RouteStep {
  final String instruction;
  final double distance;
  final Duration duration;
  final LocationData location;

  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.location,
  });
}
