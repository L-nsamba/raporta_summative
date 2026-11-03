import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/models/user_model.dart';

// This file actually communicates with the Firebase and defines the logic for the operations within auth_remote_datasource.dart

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Stream<AppUserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final userDocument = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDocument.exists) {
        return null;
      }

      return AppUserModel.fromFirestore(userDocument);
    });
  }

  @override
  Future<AppUserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String areaId,
  }) async {
    // Creation of the firebase authentication account
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('User registration failed.');
    }

    // Creation of timestamps
    final now = DateTime.now();

    // Creation of the user profile model
    final user = AppUserModel(
      userId: firebaseUser.uid,
      name: name,
      email: email,
      role: UserRole.citizen,
      areaId: areaId,
      createdAt: now,
      updatedAt: now,
    );

    // Saving of the profile in Firestore
    await firestore.collection('users').doc(firebaseUser.uid).set({
      ...user.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Returning created user
    return user;
  }

  @override
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // User authentication
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Sign in failed.');
    }

    // Retrieving the user's firestore profile
    final userDocument = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    // Checking whether the profile exists
    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    // Converting Firestore document into AppUserModel
    return AppUserModel.fromFirestore(userDocument);
  }

  @override
  Future<AppUserModel> signInWithGoogle({required String areaId}) async {
    // Starting the Google Sign-in
    final googleUser = await googleSignIn.authenticate();

    // Retrieving the google authentication details
    final googleAuth = googleUser.authentication;

    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Google ID token is unavailable.');
    }

    // Creation of Firebase credential
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    // Authentication with Firebase
    final userCredential = await firebaseAuth.signInWithCredential(credential);

    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception('Google sign-in failed.');
    }

    // Checking whether a Firestore profile already exists
    final userDocument = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (userDocument.exists) {
      // Returning user: retrieve existing profile
      return AppUserModel.fromFirestore(userDocument);
    }

    // First time user: create their profile
    final now = DateTime.now();

    final newUser = AppUserModel(
      userId: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Citizen',
      email: firebaseUser.email ?? '',
      role: UserRole.citizen,
      areaId: areaId,
      createdAt: now,
      updatedAt: now,
    );

    await firestore.collection('users').doc(firebaseUser.uid).set({
      ...newUser.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newUser;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Get the currently authenticated user
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    // Send verification email
    await user.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    // Getting the currently authenticated Firebase user
    final firebaseUser = firebaseAuth.currentUser;

    // Return null if nobody is signed in
    if (firebaseUser == null) {
      return null;
    }

    // Retrieving their Firebase profile
    final userDocument = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    // Returning null if the profile does not exist
    if (!userDocument.exists) {
      return null;
    }

    // Converting and returning the profile
    return AppUserModel.fromFirestore(userDocument);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
