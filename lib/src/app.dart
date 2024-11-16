import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_order/src/views/auth_view/login_page_view.dart';
import 'package:table_order/src/views/NavigationRailPage.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_page_view.dart';
import 'package:table_order/src/views/owner_view/restaurant_registration.dart';
import 'package:table_order/src/views/owner_view/search_restaurant.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_list_view.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';
import 'views/auth_view/sign_up_page_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  //auth
                  case LoginPageView.routeName:
                    return const LoginPageView();
                  case SignUpPageView.routeName:
                    return const SignUpPageView();
                  //settings
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  //restaurant
                  case RestaurantReviewView.routeName:
                    return const RestaurantReviewView();
                  case RestaurantItemDetailsView.routeName:
                    return const RestaurantItemDetailsView();
                  case RestaurantOwnerPageView.routeName:
                    return const RestaurantOwnerPageView();
                  case SearchRestaurant.routeName:
                    return const SearchRestaurant();
                  case RestaurantRegistration.routeName:
                    return const RestaurantRegistration();
                  case RestaurantItemListView.routeName:
                  default:
                    return const NavigationRailPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
