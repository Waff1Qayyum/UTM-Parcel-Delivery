import 'package:cpplink/customer_pages/customer_updateProfile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_pages/admin_homepage.dart';
import 'customer_pages/customer_changeName.dart';
import 'customer_pages/customer_changePassword.dart';
import 'customer_pages/customer_changePhoneNumber.dart';
import 'customer_pages/customer_changeProfilePicture.dart';
import 'customer_pages/customer_hompage.dart';
import 'customer_pages/customer_register.dart';
import 'login_page.dart';
import 'otpVerification.dart';
import 'rider_pages/rider_changeName.dart';
import 'rider_pages/rider_changePassword.dart';
import 'rider_pages/rider_changePhoneNumber.dart';
import 'rider_pages/rider_homepage.dart';
import 'rider_pages/rider_updateProfile.dart';
import 'splash.dart';
import 'resetPassword.dart';
import 'forgotPassword.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://bzscuwrolzmocdshaemx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6c2N1d3JvbHptb2Nkc2hhZW14Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkzNTE3MDksImV4cCI6MjAxNDkyNzcwOX0.iGlxlb_WNLjh2apj3u9DDkvfl7d8hChLgd2qrIj6JJk');
  runApp(MyApp());
}

void clearUserSession() {
  supabase.auth.signOut();
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    clearUserSession();

    return MaterialApp(
      title: 'CPP Link',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', //used for changing between pages
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/register': (_) => const CustomerRegisterPage(),
        '/login': (_) => const LoginPage(), //login_page

////////////////////users homepage////////////////

        //admin
        '/admin_home': (_) => const AdminHomePage(),

        // rider
        // '/': (_) => const RiderHomePage(), //temporary
        '/rider_changeName': (_) => const RiderChangeName(),
        '/rider_changePw': (_) => const RiderChangePassword(),
        '/rider_changePFP': (_) => const RiderChangeProfile(),
        '/rider_changePhone': (_) => const RiderChangePhone(),
        // '/rider_changeVehicle': (_) => const RiderChangeVehicle(),

        //customer
        '/customer_home': (_) => const CustomerHomepage(),
        '/customer_update': (_) => const CustomerProfile(), //placeholder
        '/changeName': (_) => const CustomerChangeName(), //placeholder
        '/changePw': (_) => const CustomerChangePassword(), //placeholder
        '/changePFP': (_) => const CustomerChangePicture(),
        '/changePhone': (_) => const CustomerChangePhone(),

//////////////////forgot password//////////////////
        '/forgotPassword': (_) => const ForgotPassword(),
        '/otpVerification': (_) => const OTPVerification(),
        '/resetPassword': (_) => const ResetPassword(),

//////////////////user_updateProfile//////////////////
        '/customer_profile': (_) => const CustomerProfile(),
      },
    );
  }
}
