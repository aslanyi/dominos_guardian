import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/employee.dart';
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
  final users = await _firebaseHelper.getUsers();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(users)),
        ChangeNotifierProvider(
          create: (_) => AppProvider(firebaseApp),
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
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {'/login': (ctx) => Login()},
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Employee> ruFrontendDevelopers = [];
  List<Employee> ruBackendDevelopers = [];
  List<Employee> trFrontendDevelopers = [];
  List<Employee> trBackendDevelopers = [];

  /*
  [
    {
      20-07-2020: [
        {
          name: 'Zerrin'
        },
        {
          name: 'Zerrin'
        },
        {
          name: 'Zerrin'
        },
        {
          name: 'Zerrin'
        }
      ]
    }
  ]

  */

  List<Map<String, List<Employee>>> _employeesWithDate = [];

  List<DateTime> calculateDaysInterval(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  List<Employee> getEmployeesByFilteringOptions(Team team, Role role) {
    List<Employee> employees =
        Provider.of<UserProvider>(context, listen: false).employeeList.where((element) {
      if (element.team == team && element.role == role) {
        return true;
      }
      return false;
    }).toList();

    return employees;
  }

  void handleLastDateEmployee() {}

  generateGuardianDateList() {
    DateTime startDate = DateTime.now();
    DateTime lastDate = DateTime(2020, 07, 28);
    Function format = DateFormat('dd-MM-yyyy').format;

    List<DateTime> dates = calculateDaysInterval(startDate, lastDate);
    String lastDateTime;
    List<Employee> lastDevelopers;

    dates.forEach((element) {
      String date = format(element);
      if (lastDateTime != null) {
        _employeesWithDate.forEach((employeWithDateItem) {
          employeWithDateItem.forEach((key, value) {
            // find dateItem which equals to lastdatetiem
            if (key == lastDateTime) {
              lastDevelopers.forEach((element) {
                Employee lastDeveloper = value.firstWhere(
                    (item) => item.phoneNumber == element.phoneNumber,
                    orElse: () => null);
                if (lastDeveloper != null) {}
              });
            }
          });
        });
      }

      ruFrontendDevelopers.shuffle();
      trFrontendDevelopers.shuffle();
      ruBackendDevelopers.shuffle();
      trBackendDevelopers.shuffle();

      Employee ruFrontEnd = ruFrontendDevelopers.first;
      Employee trFrontEnd = trFrontendDevelopers.first;
      Employee ruBackend = ruBackendDevelopers.first;
      Employee trBackend = trBackendDevelopers.first;

      _employeesWithDate.add({
        date: [
          ruFrontEnd,
          trFrontEnd,
          ruBackend,
          trBackend,
        ]
      });

      lastDateTime = date;
      lastDevelopers = [
        ruFrontEnd,
        trFrontEnd,
        ruBackend,
        trBackend,
      ];
    });
  }

  Employee getNewGuard(Employee e, List<Employee> developers) {
    List<Employee> tempEmpList = developers.toList();
    tempEmpList.removeWhere((element) => element.phoneNumber == e.phoneNumber);
    tempEmpList.shuffle();
    return tempEmpList.first;
  }

  bool isMount = false;

  @override
  void initState() {
    super.initState();
    ruFrontendDevelopers = getEmployeesByFilteringOptions(Team.RU, Role.Frontend);
    ruBackendDevelopers = getEmployeesByFilteringOptions(Team.RU, Role.Backend);
    trFrontendDevelopers = getEmployeesByFilteringOptions(Team.TR, Role.Frontend);
    trBackendDevelopers = getEmployeesByFilteringOptions(Team.TR, Role.Backend);
    if (!isMount) {
      generateGuardianDateList();
      isMount = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final currentUser = context.select((UserProvider userProvider) => userProvider.currentUser);

    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Hoşgeldin ${currentUser?.name}',
                          style: TextStyle(
                            fontSize: media.width / 15,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    currentUser != null ? UserCard(currentUser) : Container()
                  ],
                ))));
  }
}
