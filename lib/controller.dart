import 'package:flutter/material.dart';

import 'main.dart';

/////////////////
// final currentUser =  supabase.auth.currentUser;
// final currentID = currentUser!.id;
// final currentUName =  supabase.from('user').select('name').eq('user_id',currentID);

/////////////////////////
//////////////////////// for otp
var email; // for otp
void setEmail(String _email) {
  email = _email;
}

String getEmail() {
  return email;
}

/////////////////////////
//////////////////////// for register rider
var RegisterUserType;
var registerEmail;
var registerPassword;
var registerName;
var registerPhone;

Future<dynamic> signupRider() async {
  try {
    final user = await supabase.auth.signUp(
        email: registerEmail,
        password: registerPassword,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/');
    await supabase.from('user').insert({
      'user_id': user.user!.id,
      'email': registerEmail,
      'phone': registerPhone,
      'name': registerName,
    });

    await supabase.from('rider').insert({'user_id': user.user!.id});
    final rider = await supabase
        .from('rider')
        .select('rider_id')
        .eq('user_id', user.user!.id)
        .single();
    final riderId = rider['rider_id'];
    await supabase
        .from('user')
        .update({'rider_id': riderId}).eq('user_id', user.user!.id);

    return user.user?.id;
  } catch (e) {
    return;
  }
}

//Validation

//phone validation
bool _phoneValid(String phone) {
  if (!RegExp(r'^01\d{8,9}$').hasMatch(phone)) {
    return false;
  } else {
    return true;
  }
}

//name validation

//email validation

//formatting

//format phone
String formatPhone(String phone) {
  return phone.replaceAll(RegExp(r'\s+'), '').trim();
}

//format name
String formatName(String name) {
  return name.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
}

//format email
String formatEmail(String email) {
  return email.trim();
}

//store information(user)
String getID() {
  return supabase.auth.currentUser!.id;
}

var user_name;
var user_phone;
var user_email;
var user_picture;
var picture;
var vehicle_url;
var vehicle_picture;
Future<void> getData(dynamic id) async {
  final data = await supabase
      .from('user')
      .select('name, phone, email, picture_url')
      .eq('user_id', id)
      .single();

  user_name = data['name'];
  user_phone = data['phone'];
  user_email = data['email'];
  user_picture = data['picture_url'];

  if (user_picture != null) {
    picture = Image.network(
      user_picture!,
      fit: BoxFit.cover,
      width: 70,
      height: 70,
    );
  }

  final rider =
      await supabase.from('user').select('rider_id').eq('user_id', id).single();

  if (rider['rider_id'] != null) {
    getVehiclePicture(id);
  }
}

void getVehiclePicture(dynamic id) async {
  final data = await supabase
      .from('rider')
      .select('picture_url')
      .eq('user_id', id)
      .single();

  vehicle_url = data['picture_url'];

  if (vehicle_picture != null) {
    vehicle_picture = Image.network(
      vehicle_url!,
      fit: BoxFit.cover,
      width: 70,
      height: 70,
    );
  }
}

//store information(admin)
var admin_name;
var admin_phone;
var admin_email;
var admin_picture;
var picture_url;
Future<void> getAdminData(dynamic id) async {
  final data = await supabase
      .from('admin')
      .select('name, phone, email, picture_url')
      .eq('user_id', id)
      .single();

  admin_name = data['name'];
  admin_phone = data['phone'];
  admin_email = data['email'];
  picture_url = data['picture_url'];

  if (picture_url != null) {
    admin_picture = Image.network(
      picture_url!,
      fit: BoxFit.cover,
      width: 70,
      height: 70,
    );
  }
}
