// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart' as weather_repository;

import '../../helpers/hydrated_bloc.dart';

const weatherLocation = 'London';
const weatherCondition = weather_repository.WeatherCondition.rainy;
const weatherTemperature = 9.8;

class MockWeatherRepository extends Mock implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  group('WeatherCubit', () {
    late weather_repository.Weather weather;
    late weather_repository.WeatherRepository weatherRepository;

    setUpAll(initHydratedBloc);

    setUp(() {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(() => weatherRepository.getWeather(any())).thenAnswer((_) async => weather);
    });

    test('initial state is correct', () {
      final weatherCubit = WeatherCubit(weatherRepository: weatherRepository);

      expect(weatherCubit.state, WeatherState());
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        final weatherCubit = WeatherCubit(weatherRepository: weatherRepository);

        expect(weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)!), weatherCubit.state);
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => [],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => [],
      );

      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        verify: (cubit) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(() => weatherRepository.getWeather(any())).thenThrow(Exception('oops'));
        },
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => [
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (celsius)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => [
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>().having((weather) => weather.status, 'status', WeatherStatus.success).having(
                (weather) => weather.weather,
                'weather',
                isA<Weather>()
                    .having((weather) => weather.lastUpdated, 'lastUpdated', isNotNull)
                    .having((weather) => weather.condition, 'condition', weatherCondition)
                    .having((weather) => weather.temperature, 'temperature', Temperature(value: weatherTemperature))
                    .having((weather) => weather.location, 'location', weatherLocation),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (fahrenheit)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => [
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>().having((weather) => weather.status, 'status', WeatherStatus.success).having(
                (weather) => weather.weather,
                'weather',
                isA<Weather>()
                    .having((weather) => weather.lastUpdated, 'lastUpdated', isNotNull)
                    .having((weather) => weather.condition, 'condition', weatherCondition)
                    .having((weather) => weather.temperature, 'temperature', Temperature(value: weatherTemperature.toFahrenheit()))
                    .having((weather) => weather.location, 'location', weatherLocation),
              ),
        ],
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when status is not success',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [],
        verify: (cubit) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when location is null',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [],
        verify: (cubit) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'invokes getWeather with correct location',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        verify: (cubit) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when exception is thrown',
        setUp: () {
          when(() => weatherRepository.getWeather(any())).thenThrow(Exception('oops'));
        },
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (celsius)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: 0.0),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [
          isA<WeatherState>().having((weather) => weather.status, 'status', WeatherStatus.success).having(
                (weather) => weather.weather,
                'weather',
                isA<Weather>()
                    .having((weather) => weather.lastUpdated, 'lastUpdated', isNotNull)
                    .having((weather) => weather.condition, 'condition', weatherCondition)
                    .having((weather) => weather.temperature, 'temperature', Temperature(value: weatherTemperature))
                    .having((weather) => weather.location, 'location', weatherLocation),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (fahrenheit)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          temperatureUnits: TemperatureUnits.fahrenheit,
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: 0.0),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [
          isA<WeatherState>().having((weather) => weather.status, 'status', WeatherStatus.success).having(
                (weather) => weather.weather,
                'weather',
                isA<Weather>()
                    .having((weather) => weather.lastUpdated, 'lastUpdated', isNotNull)
                    .having((weather) => weather.condition, 'condition', weatherCondition)
                    .having((weather) => weather.temperature, 'temperature', Temperature(value: weatherTemperature.toFahrenheit()))
                    .having((weather) => weather.location, 'location', weatherLocation),
              ),
        ],
      );
    });

    group('toggleUnits', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits updated units when status is not success',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => [
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature when status is success (celsius)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: WeatherCondition.rainy,
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => [
          WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.celsius,
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature.toCelsius()),
              lastUpdated: DateTime(2020),
              condition: WeatherCondition.rainy,
            ),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature when status is success (fahrenheit)',
        build: () => WeatherCubit(weatherRepository: weatherRepository),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.celsius,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: WeatherCondition.rainy,
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => [
          WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.fahrenheit,
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature.toFahrenheit()),
              lastUpdated: DateTime(2020),
              condition: WeatherCondition.rainy,
            ),
          ),
        ],
      );
    });
  });
}
