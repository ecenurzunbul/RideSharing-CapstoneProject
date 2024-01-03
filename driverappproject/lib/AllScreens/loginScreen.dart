import 'package:drivers_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:drivers_app/AllScreens/mainScreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/AllWidgets/progressDialog.dart';
import 'package:drivers_app/main.dart';


class LoginScreen extends StatelessWidget
{
  static const String idScreen = "login";

  TextEditingController emailTextEditingController = TextEditingController();
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
              "Login as a Driver",
                style: TextStyle(fontSize:30.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding:EdgeInsets.all(20.0),
              child: Column(
                children: [
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
                      if(!emailTextEditingController.text.contains("@"))
                      {
                        displayToastMessage("Email adress is not valid", context);
                      }
                      else if(passwordTextEditingController.text.isEmpty)
                      {
                        displayToastMessage("Pasword is mandatory.", context);
                      }
                      else{
                        loginAndAuthenticateUser(context);
                      }

                    },
                    child: Column(
                      children: [
                        SizedBox(height: 8), // Buton ile üstteki eleman arasına boşluk bırakma
                        Text('Login'),
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
               Navigator.pushNamedAndRemoveUntil(context, RegisterationScreen.idScreen, (route) => false);
              },
              child: Text('Do not have an Account? Register Here.'),
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
void loginAndAuthenticateUser(BuildContext context) async
{
  showDialog(
      context:context,
      barrierDismissible: false,
      builder: (BuildContext context)
  {
    return ProgressDialog(message: "Authenticating, Please wait...",);
  }
  );

  final User? firebaseUser= (await FirebaseAuth.instance
      .signInWithEmailAndPassword(

    email: emailTextEditingController.text,
    password: passwordTextEditingController.text
  ).catchError((errMsg){
    Navigator.pop(context); //bu progress dialogu kapatmayı sağlayacak
    displayToastMessage("Error:" + errMsg.toString(), context);
  })).user;
  if (firebaseUser != null) //user created
      {

    driversRef.child(firebaseUser.uid).once().then((event){
      final snap=event.snapshot;
      if(snap.value != null)
      {
        currentfirebaseUser=firebaseUser;
        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
        displayToastMessage("you are logged in now.", context);
      }
      else
        {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("No record exists for this user.Please create new.", context);
        }
    });

    //save user info to database
  }
  else
  {
    Navigator.pop(context);
    //error occured
    displayToastMessage("Error occured, can not be signed-in.", context);
  }
}
}