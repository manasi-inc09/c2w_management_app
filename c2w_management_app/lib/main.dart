import 'dart:developer';

import 'package:c2w_management_app/features/Profile/data/repository/GetUserdata.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileBloc.dart';
import 'package:c2w_management_app/features/Profile/presentation/screens/profile.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/repositories/teamlead_expense_repository_impl.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_history_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/mentor/data/datasources/mentor_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/mentor/data/repositories/mentor_expense_repository_impl.dart';
import 'package:c2w_management_app/features/expense/mentor/domain/usecases/create_mentor_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/mentor/presentation/bloc/mentor_expense_bloc.dart';
import 'package:c2w_management_app/features/expense/instructor/data/datasources/instructor_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/instructor/data/repositories/instructor_expense_repository_impl.dart';
import 'package:c2w_management_app/features/expense/instructor/domain/usecases/create_instructor_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/instructor/presentation/bloc/instructor_expense_bloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/splash_screen.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC31ncXICBwDavaVL7JkNYG4jegsCFXuNg",
      appId: "1:268875323461:android:605b45eb088fcefb682b2c",
      messagingSenderId: "268875323461",
      projectId: "c2w-erp",
    ),
  );
  log("firebase initiallized");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudinaryDataSource = CloudinaryDataSource();

    final expenseRemoteDataSource = ExpenseRemoteDataSource(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      cloudinaryDataSource: cloudinaryDataSource,
    );
    final expenseRepository = ExpenseRepositoryImpl(
      remoteDataSource: expenseRemoteDataSource,
    );

    final createExpenseUseCase = CreateExpenseUseCase(expenseRepository);
    final mentorExpenseDataSource = MentorExpenseRemoteDataSource(
      expenseDataSource: expenseRemoteDataSource,
    );
    final mentorExpenseUseCase = CreateMentorExpenseUseCase(
      MentorExpenseRepositoryImpl(remoteDataSource: mentorExpenseDataSource),
    );
    final instructorExpenseDataSource = InstructorExpenseRemoteDataSource(
      expenseDataSource: expenseRemoteDataSource,
    );
    final instructorExpenseUseCase = CreateInstructorExpenseUseCase(
      InstructorExpenseRepositoryImpl(
        remoteDataSource: instructorExpenseDataSource,
      ),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<Loginsignupbloc>(create: (context) => Loginsignupbloc()),
        BlocProvider<CreateExpenseBloc>(
          create: (context) {
            final authEmail =
                AuthRepository.authEmail ??
                FirebaseAuth.instance.currentUser?.email;
            if (authEmail?.startsWith('mentor_') ?? false) {
              return MentorExpenseBloc(
                createExpenseUseCase: mentorExpenseUseCase,
              );
            }
            if (authEmail?.startsWith('instructor_') ?? false) {
              return InstructorExpenseBloc(
                createExpenseUseCase: instructorExpenseUseCase,
              );
            }
            return CreateExpenseBloc(
              createExpenseUseCase: createExpenseUseCase,
            );
          },
        ),
        BlocProvider<ExpenseHistoryBloc>(
          create: (context) =>
              ExpenseHistoryBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<ExpenseManagerBloc>(
          create: (context) =>
              ExpenseManagerBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<MembersBloc>(
          create: (context) =>
              MembersBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<MemberDetailsBloc>(
          create: (context) =>
              MemberDetailsBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<ExpenseFilterBloc>(
          create: (context) =>
              ExpenseFilterBloc(expenseUseCase: createExpenseUseCase)
                ..add(LoadExpenseFilterOptions()),
        ),
        BlocProvider<ExpenseCategoryBloc>(
          create: (context) =>
              ExpenseCategoryBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(expenseUseCase: createExpenseUseCase),
        ),
        BlocProvider<CreateExpenseBloc>(
          create: (context) =>
              CreateExpenseBloc(createExpenseUseCase: createExpenseUseCase),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(GetUserData()),
          child: const ProfileScreen(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
