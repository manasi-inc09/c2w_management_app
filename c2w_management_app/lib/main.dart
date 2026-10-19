import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/repositories/teamlead_expense_repository_impl.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(
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
    // 1. Cloudinary data source
    final cloudinaryDataSource = CloudinaryDataSource();

    // 2. Expense remote data source
    final expenseRemoteDataSource = ExpenseRemoteDataSource(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      cloudinaryDataSource: cloudinaryDataSource,
    );

    // 3. Repository implementation
    final expenseRepository = ExpenseRepositoryImpl(
      remoteDataSource: expenseRemoteDataSource,
    );

    // 4. Use case
    final createExpenseUseCase = CreateExpenseUseCase(
      expenseRepository,
    );

    // 5. Provide BLoCs to the application
    return MultiBlocProvider(
      providers: [
        BlocProvider<Loginsignupbloc>(
          create: (context) => Loginsignupbloc(),
        ),
        BlocProvider<CreateExpenseBloc>(
          create: (context) => CreateExpenseBloc(
            createExpenseUseCase: createExpenseUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
