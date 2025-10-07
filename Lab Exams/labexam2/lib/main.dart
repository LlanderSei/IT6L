import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/student_list_page.dart';
import 'pages/course_list_page.dart';
import 'pages/enrolled_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Exam 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade100,
          primary: Colors.pink.shade300,
          secondary: Colors.pink.shade300,
          surface: Colors.pink.shade50,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFAF5), // Soft warm white

        textTheme: GoogleFonts.tiltNeonTextTheme().copyWith(
          headlineLarge: GoogleFonts.tiltNeon(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.tiltNeon(fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.tiltNeon(),
          bodyMedium: GoogleFonts.tiltNeon(),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade200,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 2,
            shadowColor: Colors.pink.shade100.withValues(alpha: .25),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.pink.shade50,
            side: BorderSide(color: Colors.pink.shade300, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: .1),
          color: Colors.white,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade100,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.pink, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        iconTheme: IconThemeData(color: Colors.pink.shade300),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _mainAppBarTitle = 'Enrolled';
  final List<Widget> _pages = [
    const EnrolledPage(),
    const StudentListPage(),
    const CourseListPage(),
  ];

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Lab Exam 2', style: TextStyle(fontSize: 10)),
            Text(
              _mainAppBarTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.pink.shade100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Very Simple CRUD App',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            ListTile(
              title: const Text('Enrolled Courses'),
              selected: _selectedIndex == 0,
              onTap: () => {
                setState(() => _mainAppBarTitle = 'Enrolled Courses'),
                _changePage(0),
              },
            ),
            ListTile(
              title: const Text('Students'),
              selected: _selectedIndex == 1,
              onTap: () => {
                _changePage(1),
                setState(() => _mainAppBarTitle = 'Students'),
              },
            ),
            ListTile(
              title: const Text('Courses'),
              selected: _selectedIndex == 2,
              onTap: () => {
                setState(() => _mainAppBarTitle = 'Courses'),
                _changePage(2),
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
