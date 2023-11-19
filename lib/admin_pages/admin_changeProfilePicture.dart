import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AdminChangePicture extends StatefulWidget {
  const AdminChangePicture({super.key});

  @override
  State<AdminChangePicture> createState() => AdminChangePictureState();
}

class AdminChangePictureState extends State<AdminChangePicture> {
  dynamic image;
  XFile? fileImage;
  File? imageFile;
  bool isImageSelected = false;
  String? name;
  String? phone;
  String? email;
  bool? passMatch;
  bool isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    displayImage();
    getName();
    getEmail();
    getPhone();
  }

  Future<void> getName() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('admin')
        .select('name')
        .eq('user_id', userId)
        .single();
    if (mounted) {
      setState(() {
        name = data['name'];
      });
    }
  }

  Future<void> getPhone() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('admin')
        .select('phone')
        .eq('user_id', userId)
        .single();
    if (mounted) {
      setState(() {
        phone = data['phone'];
      });
    }
  }

  Future<void> getEmail() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('admin')
        .select('email')
        .eq('user_id', userId)
        .single();
    if (mounted) {
      setState(() {
        email = data['email'];
      });
    }
  }

  void dispose() {
    super.dispose();
  }

  Future<void> displayImage() async {
    final userId = supabase.auth.currentUser!.id;
    final res = await supabase
        .from('admin')
        .select('picture_url')
        .eq('user_id', userId)
        .single();

    if (res['picture_url'] == null) {
      return;
    }

    if (mounted) {
      setState(() {
        image = res['picture_url'];
      });
    }
  }

  Future<bool> checkPassword() async {
    bool? match;
    match = await supabase.rpc('check_password',
        params: {'password_input': _passwordController.text});
    if (match == true || match == 1) {
      return true;
    } else
      return false;
  }

  Future<void> uploadImage() async {
    final imageExtension = fileImage!.path.split('.').last.toLowerCase();
    final imageBytes = await fileImage!.readAsBytes();
    final userId = supabase.auth.currentUser!.id;
    final imagePath = '/$userId/profile';
    await supabase.storage.from('picture').uploadBinary(imagePath, imageBytes,
        fileOptions:
            FileOptions(upsert: true, contentType: 'image/$imageExtension'));

    image = supabase.storage.from('picture').getPublicUrl('/$userId/profile');
    image = Uri.parse(image).replace(queryParameters: {
      't': DateTime.now().millisecondsSinceEpoch.toString()
    }).toString();
    await supabase
        .from('admin')
        .update({'picture_url': image}).eq('user_id', userId);
  }

  void getImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        isImageSelected = true;
      });
    }
    setState(() {
      fileImage = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: Text(
          'Update Profile',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // You can replace this with your custom logo
            color: Colors.white, // Icon color
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/admin_profile', (route) => false);
          },
        ),
      ),
      body: Stack(children: [
        ListView(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset(
                        './images/cpp_logo.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
                    Text(
                      'CPP',
                      style: TextStyle(
                        color: Color(0xFF050505),
                        fontSize: 48,
                        fontFamily: 'Montagu Slab',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                    Text(
                      'Link',
                      style: TextStyle(
                        color: Color(0xFFFFD233),
                        fontSize: 32,
                        fontFamily: 'Montagu Slab',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFFFD233),
                                width: 1.0,
                              ),
                            ),
                            child: ClipOval(
                                child: image != null
                                    ? Image.network(
                                        image!,
                                        fit: BoxFit.cover,
                                        width: 70,
                                        height: 70,
                                      )
                                    : Container(
                                        color: Colors.grey,
                                      )),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name ?? 'Loading..',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 22,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.call,
                                    color: Color(0xFFFFD233),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    phone ?? 'Loading..',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w100,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Color(0xFFFFD233),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    email ?? 'Loading..',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w100,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  'Change Your Account\'s Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 17,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: isImageSelected == true
                                  ? Image(image: FileImage(imageFile!))
                                  : ((image != null)
                                      ? Image.network(
                                          image!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          child: const Center(
                                            child: Text('No image'),
                                          ),
                                        )),
                            ),
                            Container(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () async {
                                  getImage();
                                },
                                child: Text('Upload Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Enter your password for confirmation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 17,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 0.5,
                                  color: Color.fromARGB(56, 25, 25, 25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(164, 117, 117, 117),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter a password ",
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 249, 249, 249),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Color(0xFFFFD233),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  } else if (passMatch == false) {
                                    return 'Password does not match';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: isLoading == true
                                      ? null
                                      : () async {
                                          // Your code to handle the tap event
                                          print('clicked');
                                          setState(() {
                                            isLoading = true;
                                          });
                                          passMatch = await checkPassword();
                                          if (_formKey.currentState!
                                              .validate()) {
                                            print('process image');
                                            await uploadImage();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Profile Picture Updated Successfully')));
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/admin_profile',
                                                (route) => false);
                                          }

                                          setState(() {
                                            print('finish');
                                            isLoading = false;
                                          });
                                        },
                                  child: Container(
                                    width: 263,
                                    height: 53,
                                    alignment: Alignment.center,
                                    decoration: ShapeDecoration(
                                      color: const Color.fromARGB(
                                          255, 44, 174, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          width: 1.50,
                                          color: const Color.fromARGB(
                                              255, 44, 174, 48),
                                        ),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'confirm',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontSize: 15,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Loading indicator overlay
        if (isLoading)
          Container(
            color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LottieBuilder.asset('assets/yellow_loading.json'),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}
