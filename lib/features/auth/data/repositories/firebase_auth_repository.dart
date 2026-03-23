import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/models/app_user_model.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUser?> authState() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final snapshot = await _users.doc(firebaseUser.uid).get();
      if (!snapshot.exists) return null;
      return AppUserModel.fromMap(snapshot.data()!);
    });
  }

  @override
  Future<Result<AppUser?>> currentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Right<Failure, AppUser?>(null);
      }
      final snapshot = await _users.doc(user.uid).get();
      if (!snapshot.exists) {
        return const Right<Failure, AppUser?>(null);
      }
      return Right<Failure, AppUser?>(AppUserModel.fromMap(snapshot.data()!));
    } on FirebaseException catch (e) {
      return Left<Failure, AppUser?>(
        Failure(e.message ?? 'Error en Firestore'),
      );
    } catch (_) {
      return const Left<Failure, AppUser?>(Failure('Error inesperado'));
    }
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final snapshot = await _users.doc(uid).get();
      if (!snapshot.exists) {
        return const Left<Failure, AppUser>(
          Failure('Usuario no encontrado en base de datos'),
        );
      }
      return Right<Failure, AppUser>(AppUserModel.fromMap(snapshot.data()!));
    } on FirebaseAuthException catch (e) {
      return Left<Failure, AppUser>(Failure(_authError(e.code)));
    } on FirebaseException catch (e) {
      return Left<Failure, AppUser>(Failure(e.message ?? 'Error en Firestore'));
    } catch (_) {
      return const Left<Failure, AppUser>(
        Failure('Error inesperado al iniciar sesion'),
      );
    }
  }

  @override
  Future<Result<AppUser>> register({
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final appUser = AppUserModel(
        uid: user.uid,
        email: email.trim(),
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        rol: 'usuario',
        telefono: telefono?.trim().isEmpty == true ? null : telefono?.trim(),
        createdAt: DateTime.now(),
        deletedAt: null,
      );
      await _users.doc(user.uid).set(appUser.toMap());
      return Right<Failure, AppUser>(appUser);
    } on FirebaseAuthException catch (e) {
      return Left<Failure, AppUser>(Failure(_authError(e.code)));
    } on FirebaseException catch (e) {
      return Left<Failure, AppUser>(Failure(e.message ?? 'Error en Firestore'));
    } catch (_) {
      return const Left<Failure, AppUser>(
        Failure('Error inesperado al registrar'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right<Failure, void>(null);
    } on FirebaseAuthException catch (e) {
      return Left<Failure, void>(Failure(_authError(e.code)));
    } catch (_) {
      return const Left<Failure, void>(Failure('No se pudo cerrar sesion'));
    }
  }

  @override
  Future<Result<void>> softDeleteCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left<Failure, void>(Failure('No hay usuario autenticado'));
      }

      await _users.doc(user.uid).update({'deletedAt': Timestamp.now()});

      final pendingTurns = await _firestore
          .collectionGroup('turns')
          .where('userId', isEqualTo: user.uid)
          .where('estado', isEqualTo: 'en_espera')
          .get();

      const maxBatchSize = 500;
      final docs = pendingTurns.docs;
      for (var i = 0; i < docs.length; i += maxBatchSize) {
        final batch = _firestore.batch();
        final end = (i + maxBatchSize < docs.length)
            ? i + maxBatchSize
            : docs.length;

        for (var j = i; j < end; j++) {
          final doc = docs[j];
          batch.update(doc.reference, {
            'estado': 'cancelado',
            'canceladoEn': Timestamp.now(),
          });
        }

        await batch.commit();
      }

      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'Error al eliminar cuenta'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('No se pudo eliminar la cuenta'),
      );
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Credenciales incorrectas';
      case 'network-request-failed':
        return 'Sin conexion a internet';
      case 'email-already-in-use':
        return 'El correo ya esta en uso';
      case 'invalid-email':
        return 'Correo invalido';
      case 'weak-password':
        return 'La contrasena es demasiado debil';
      default:
        return 'Error de autenticacion';
    }
  }
}
