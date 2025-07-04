import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  // first you need to create an instance of firebase to allow to login , and create a passwrod
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // To have acces to the current user at all time
  User? get currentUser => firebaseAuth.currentUser;
  // Return the necessary information to know if the user is connected
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Create a login
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create an account , same layout as the create login
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //sing out function
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  //Reset password function
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  //Upadate username , for that you need "User? get currentUser => firebaseAuth.currentUser;""
  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }

  // Now delete , its different from the others because its a sensitive security operation
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    // needs to authenticate the user before delete the account
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  //Reset the password from the current password. It's a sensitve security operation as well
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
