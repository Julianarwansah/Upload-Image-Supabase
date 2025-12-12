import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

const supabaseUrl = 'https://vcyqsylxyzturvjfnlau.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjeXFzeWx4eXp0dXJ2amZubGF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1NDc1NDksImV4cCI6MjA4MTEyMzU0OX0.H0Q8CiSp1_doIhFr8IZj6Wd7I2sfSQF71XrZqPOK9eE';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'supabase foto', home: MyHomePage());
  }
}
