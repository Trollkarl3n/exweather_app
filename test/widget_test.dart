import 'package:exweather_app/pages/widgets/city_information_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('City Information widget has a city, sunrise, sunset',
          (WidgetTester tester) async {
        await tester.pumpWidget(CityInformationWidget(
          city: 'London',
          sunrise: '7:24 AM',
          sunset: '6:07 PM',
          isFavourite: false,
        ));

        final cityFinder = find.text('London');
        final sunriseFinder = find.text('7:24 AM');
        final sunsetFinder = find.text('6:07 PM');

        expect(cityFinder, findsOneWidget);
        expect(sunriseFinder, findsOneWidget);
        expect(sunsetFinder, findsOneWidget);
      });
}