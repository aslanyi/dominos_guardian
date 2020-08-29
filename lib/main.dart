// import 'package:dominos_guardian/helpers/generate_guardian_helper.dart';
import 'dart:io' show Platform;

import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/helpers/local_notifications_helper.dart';
import 'package:dominos_guardian/models/bottom_navigation_item.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/screens/admin_guard_delete.dart';
import 'package:dominos_guardian/screens/calendar.dart';
import 'package:dominos_guardian/screens/admin_guard.dart';
import 'package:dominos_guardian/screens/guards.dart';
import 'package:dominos_guardian/screens/home.dart';
import 'package:dominos_guardian/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/employee.dart';
import 'models/shared_preferences_helper.dart';
import 'screens/login.dart';

Future<FirebaseApp> initializeApp() async {
  FirebaseApp _firebaseApp;
  try {
    if (Platform.isIOS) {
      _firebaseApp = await Firebase.initializeApp(
          options: FirebaseOptions(
              appId: '1:16245276840:ios:0cb116f0faa5197920c29d',
              apiKey: 'AIzaSyBMTq8evWI5BB4t8X-8f_0OVfjue989sEg',
              projectId: 'dominos-guard',
              messagingSenderId: '16245276840',
              databaseURL: 'https://dominos-guard.firebaseio.com/'));
    } else {
      await DotEnv().load('.env');
      _firebaseApp = await Firebase.initializeApp(
          options: FirebaseOptions(
              appId: DotEnv().env['GOOGLE_ID'],
              apiKey: DotEnv().env['API_KEY'],
              projectId: 'dominos-guard',
              messagingSenderId: DotEnv().env['GCM_SENDER_ID'],
              databaseURL: DotEnv().env['DATABASE_URL']));
    }
  } catch (e) {
    print(e);
  }
  return _firebaseApp;
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseApp firebaseApp = await initializeApp();
    FirebaseHelper _firebaseHelper = new FirebaseHelper(firebaseApp);
    final users = await _firebaseHelper.getData('users');
    final dates = await _firebaseHelper.getData('dates');
    LocaLNotificationsHelper locaLNotificationsHelper = new LocaLNotificationsHelper();
    await locaLNotificationsHelper.sendScheduledNotification(
        'Nöbetçiler yerlerinize!', Time(21, 45, 0));
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider(users)),
          ChangeNotifierProvider(
            create: (_) => AppProvider(firebaseApp, dates),
          )
        ],
        child: DominosGuardian(),
      ),
    );
  } catch (e) {
    print(e);
  }
}

class DominosGuardian extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Domino\'s Guardian',
        theme: ThemeData(
          textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.blue,
          primaryTextTheme: TextTheme(
            bodyText1: TextStyle(color: Color.fromRGBO(157, 95, 222, 1)),
          ),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(157, 95, 222, 1),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/admin_guard': (_) => AdminGuard(),
          '/admin_guard_delete': (_) => AdminGuardDelete(),
        },
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Employee> guards = [];
  final SharedPreferencesHelper _sharedPreferencesHelper = new SharedPreferencesHelper();

  List<Widget> pages;

  int activePageIndex = 0;
  bool isLoggedIn = false;
  bool isLoading = true;

  Future<void> initialUser() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String phoneNumber = await _sharedPreferencesHelper.getStringData('phoneNumber');
    if (phoneNumber != null) {
      Employee _employee = userProvider.employeeList
          .firstWhere((element) => element.phoneNumber == phoneNumber, orElse: () => null);
      if (_employee != null) {
        userProvider.setCurrentUser(_employee);
        setState(() {
          isLoggedIn = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // GenerateGuardianHelper generateGuardianHelper =
    //     new GenerateGuardianHelper();
    // var employeeList =
    //     Provider.of<UserProvider>(context, listen: false).employeeList;
    // var firebaseApp =
    //     Provider.of<AppProvider>(context, listen: false).firebaseApp;

    // FirebaseHelper _firebaseHelper = new FirebaseHelper(firebaseApp);
    // _firebaseHelper.setData(
    //     'dates', generateGuardianHelper.generateGuardianDateList(employeeList));
    Future.delayed(Duration.zero, () async {
      await initialUser();
      setState(() {
        isLoading = false;
      });
    });
    pages = [Home(), Guards(), Calendar()];
  }

  BoxDecoration _background() {
    return BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
      const Color.fromRGBO(72, 71, 79, 0.3),
      const Color.fromRGBO(157, 95, 222, 0.3),
      const Color.fromRGBO(207, 98, 198, 0.3),
      const Color.fromRGBO(221, 225, 249, 0.3),
      const Color.fromRGBO(72, 169, 251, 0.3),
      const Color.fromRGBO(95, 91, 245, 0.3),
      const Color.fromRGBO(185, 167, 210, 0.3),
      const Color.fromRGBO(156, 147, 234, 0.6),
    ]));
  }

  Widget bottomNavigation() {
    return CustomBottomNavigation(
      activeIndex: activePageIndex,
      handleClick: (index) {
        setState(() {
          activePageIndex = index;
        });
      },
      itemList: [
        new BottomNavigationItem(Icons.home, 'Anasayfa'),
        new BottomNavigationItem(Icons.developer_board, 'Nöbetçiler'),
        new BottomNavigationItem(Icons.calendar_today, 'Takvim')
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;
    return isLoading
        ? Container()
        : currentUser != null
            ? Scaffold(
                appBar: currentUser.isAdmin
                    ? AppBar(
                        backgroundColor: Colors.white,
                        iconTheme:
                            IconTheme.of(context).copyWith(color: Color.fromRGBO(157, 95, 222, 1)))
                    : null,
                drawer: Drawer(
                  child: Column(
                    children: [
                      DrawerHeader(
                          curve: Curves.bounceIn,
                          child: UserAccountsDrawerHeader(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                              ),
                              accountName: Text('${currentUser.name} ${currentUser.surname}'),
                              accountEmail: Text('${currentUser.phoneNumber}'))),
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.person_add,
                                        color: Color.fromRGBO(157, 95, 222, 1)),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/admin_guard');
                                    },
                                    title: Text('Nöbetçi Ekle'),
                                  ),
                                  ListTile(
                                    leading:
                                        Icon(Icons.delete, color: Color.fromRGBO(157, 95, 222, 1)),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/admin_guard_delete');
                                    },
                                    title: Text('Nöbetçi Sil'),
                                  ),
                                ],
                              ),
                              ListTile(
                                title: Text(
                                  'made by flutter',
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: bottomNavigation(),
                body: SafeArea(
                    child: Container(decoration: _background(), child: pages[activePageIndex])))
            : Login();
  }
}
