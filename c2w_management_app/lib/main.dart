import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: FirebaseOptions(
    apiKey: "AIzaSyC31ncXICBwDavaVL7JkNYG4jegsCFXuNg", 
    appId: "1:268875323461:android:605b45eb088fcefb682b2c", 
    messagingSenderId:"268875323461", 
    projectId: "c2w-erp"));
    print("firebase initiallized");
    runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
      MultiBlocProvider(
        providers: [BlocProvider<Loginsignupbloc>(create: (context)=>Loginsignupbloc())],
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen()
            ),
      );
  }
}
