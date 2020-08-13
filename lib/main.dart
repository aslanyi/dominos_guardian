import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/models/bottom_navigation_item.dart';
import 'package:dominos_guardian/models/employees_with_date.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/screens/admin_guard_delete.dart';
import 'package:dominos_guardian/screens/calendar.dart';
import 'package:dominos_guardian/screens/admin_guard.dart';
import 'package:dominos_guardian/screens/guards.dart';
import 'package:dominos_guardian/widgets/app_bar.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:dominos_guardian/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/employee.dart';
import 'models/shared_preferences_helper.dart';
import 'screens/login.dart';

Future<FirebaseApp> initializeApp() async {
  await DotEnv().load('.env');
  return await FirebaseApp.configure(
      name: 'dominos-guard',
      options: FirebaseOptions(
          googleAppID: DotEnv().env['GOOGLE_ID'],
          apiKey: DotEnv().env['API_KEY'],
          databaseURL: DotEnv().env['DATABASE_URL']));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await initializeApp();
  FirebaseHelper _firebaseHelper = new FirebaseHelper(firebaseApp);
  final users = await _firebaseHelper.getData('users');
  final dates = await _firebaseHelper.getData('dates');
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
  EmployeesWithDate todaysGuards;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferencesHelper _sharedPreferencesHelper = new SharedPreferencesHelper();

  List<Widget> pages;

  int activePageIndex = 0;
  bool isLoggedIn = false;
  bool isLoading = true;

  Future<void> initializeLocalNotification() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

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
        sendNotification('Hoşgeldin ${_employee.name}');
      }
    }
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future sendNotification(String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('1', 'a', 'b',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(0, 'Nöbetçi', message, platformChannelSpecifics);
  }

  Future sendScheduledNotification(String message) async {
    var scheduledNotificationDateTime = Time(23, 45, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id', 'your other channel name', 'your other channel description');
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, 'Nöbetçi', message, scheduledNotificationDateTime, platformChannelSpecifics);
  }

  List<Employee> getEmployeesByFilteringOptions(String team, String role) {
    List<Employee> employees =
        Provider.of<UserProvider>(context, listen: false).employeeList.where((element) {
      if (element.team == team && element.role == role) {
        return true;
      }
      return false;
    }).toList();

    return employees;
  }

  getEqualDates() {
    final dates = Provider.of<AppProvider>(context, listen: false).dates;
    final employees = Provider.of<UserProvider>(context, listen: false).employeeList;
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    List<Employee> guards = [];
    if (dates != null && dates.length > 0) {
      dates.forEach((element) {
        if (element != null) {
          element.forEach((key, value) {
            if (key == date) {
              value.forEach((val) {
                Employee _employee = employees.firstWhere((element) => element.phoneNumber == val,
                    orElse: () => null);
                if (_employee != null) {
                  guards.add(_employee);
                }
              });
            }
          });
        }
      });
    }
    todaysGuards = new EmployeesWithDate(date: date, employees: guards);
    setState(() {
      todaysGuards = todaysGuards;
    });
  }

  getGuardianListString() {
    String guardians = '';
    todaysGuards.employees.forEach((element) {
      guardians += ' ${element.name}';
    });
    return guardians;
  }

  @override
  void initState() {
    super.initState();
    getEqualDates();
    // generateGuardianDateList();
    Future.delayed(Duration.zero, () async {
      await initializeLocalNotification();
      await initialUser();
      await sendScheduledNotification('Bugün kim nöbetçi?');
      setState(() {
        isLoading = false;
      });
    });
    pages = [home(), Guards(todaysGuards), Calendar()];
  }

  Widget home() {
    return CustomScrollView(slivers: <Widget>[
      CustomAppBar('Bugünün Nöbetçileri'),
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
          child: Column(children: <Widget>[
            UserCard(date: todaysGuards.date, employee: todaysGuards.employees[index]),
            Padding(padding: const EdgeInsets.only(top: 30)),
          ]),
        );
      }, childCount: todaysGuards.employees.length))
    ]);
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
