import 'package:drivers_app/AllScreens/carInfoScreen.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers_app/AllScreens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivers_app/AllScreens/mainScreen.dart';
import 'package:drivers_app/AllWidgets/progressDialog.dart';
import 'package:drivers_app/main.dart';


class RegisterationScreen extends StatelessWidget
{
  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 45.0,),
              Image(
                image: AssetImage("images/logo.png"),
                width:390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),

              SizedBox(height: 15.0,),
              Text(
                "Register as a Driver",
                style: TextStyle(fontSize:30.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding:EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 1.0,),
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0,
                        ),
                        hintStyle: TextStyle(
                          color:Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0),
                    ),


                    SizedBox(height: 1.0,),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0,
                        ),
                        hintStyle: TextStyle(
                          color:Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0),
                    ),


                    SizedBox(height: 1.0,),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0,
                        ),
                        hintStyle: TextStyle(
                          color:Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0),
                    ),

                    SizedBox(height: 1.0,),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0,
                        ),
                        hintStyle: TextStyle(
                          color:Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 24.0),
                    ),

                    SizedBox(height: 10.0,),
                    OutlinedButton(
                      onPressed: () {
                        if(nameTextEditingController.text.length<3)
                        {
                         displayToastMessage("name must be 4 characters.", context);
                        }
                        else if(!emailTextEditingController.text.contains("@"))
                          {
                            displayToastMessage("Email adress is not valid", context);
                          }
                        else if(phoneTextEditingController.text.isEmpty)
                        {
                          displayToastMessage("Phone Number is mandatory", context);
                        }
                        else if(passwordTextEditingController.text.length<6)
                        {
                          displayToastMessage("Pasword must be atleast 6 characters.", context);
                        }
                        else
                          {
                            registerNewUser(context);
                          }

                      },
                      child: Column(
                        children: [
                          SizedBox(height: 8), // Buton ile üstteki eleman arasına boşluk bırakma
                          Text('Create Account'),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(400, 60),
                        primary: Colors.white, // Butonun metin rengi
                        backgroundColor: Colors.deepPurpleAccent, // Butonun arkaplan rengi
                        side: BorderSide(color: Colors.white, width: 4), // Kenarlık rengi ve kalınlığı
                        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8), // Butonun iç içeriğine uygulanacak boşluklar
                        textStyle: TextStyle( fontFamily: "Brand Bold",
                            fontSize: 22), // Buton metninin stilini belirleme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24), // Kenarlık yuvarlaklık
                        ),
                      ),
                    ),




                  ],
                ),
              ),
              SizedBox(height: 0.1,),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: Text('Already have an Account? Login Here.'),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, // Buton metni font boyutu
                    fontFamily: "Brand Bold", // Font ailesi
                  ),

                ),
              ),


            ],
          ),
        ),
      ),

    );
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async
  {
    showDialog(
      context:context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return ProgressDialog(message: "Registering, Please wait...",);
      }
    );

final User? firebaseUser= (await FirebaseAuth.instance
    .createUserWithEmailAndPassword(

    email: emailTextEditingController.text,
    password: passwordTextEditingController.text,
).catchError((errMsg){
  Navigator.pop(context);
  displayToastMessage("Error:" + errMsg.toString(), context);
})).user;

if (firebaseUser != null) //user created
{


  Map userDataMap = {
    "name": nameTextEditingController.text.trim(),
    "email":emailTextEditingController.text.trim(),
    "phone": phoneTextEditingController.text.trim(),
  };

  driversRef.child(firebaseUser.uid).set(userDataMap);

  currentfirebaseUser=firebaseUser;

  displayToastMessage("Congralutaions, your account has been created.", context);

  Navigator.pushNamed(context,CarInfoScreen.idScreen );
  //save user info to database
}
else
  {
    Navigator.pop(context);
    //error occured
    displayToastMessage("New user account has not been created.", context);
  }
  }

}
displayToastMessage(String message, BuildContext context)
{
  Fluttertoast.showToast(msg: message);
}
