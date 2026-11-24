import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egy/core/constants/api_constants.dart';
import 'package:egy/core/network/api_client.dart';
import 'package:egy/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:egy/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:egy/features/authentication/domain/repositories/auth_repository.dart';
import 'package:egy/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:egy/features/authentication/presentation/cubit/session_cubit.dart';
import 'package:egy/features/home/presentation/cubit/home_cubit.dart';
import 'package:egy/features/properties/data/repositories/catalog_repository_impl.dart';
import 'package:egy/features/properties/domain/repositories/catalog_repository.dart';
import 'package:egy/features/favorites/data/repositories/firestore_favorites_repository.dart';
import 'package:egy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:egy/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:egy/features/price_prediction/data/datasources/prediction_remote_datasource.dart';
import 'package:egy/features/price_prediction/data/repositories/prediction_repository_impl.dart';
import 'package:egy/features/price_prediction/domain/repositories/prediction_repository.dart';
import 'package:egy/features/price_prediction/presentation/cubit/prediction_cubit.dart';
import 'package:egy/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:egy/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:egy/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:egy/features/ai_chat/data/datasources/chat_remote_datasource.dart';
import 'package:egy/features/ai_chat/data/repositories/chat_repository_impl.dart';
import 'package:egy/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:egy/features/recommendations/presentation/cubit/recommendations_cubit.dart';

/// Global service locator instance.
///
/// Access registered services via `sl<Type>()`.
/// Registration is explicit and manual — no code generation.
///
/// Registration order convention:
///   1. External (SharedPreferences, Dio, FirebaseAuth, Firestore)
///   2. Data sources (remote, local)
///   3. Repositories (implementations bound to abstract interfaces)
///   4. Cubits — registered as *factories* (new instance per screen)
final GetIt sl = GetIt.instance;

/// Initialises all registered dependencies.
///
/// Must be called in [main] before [runApp].
Future<void> setupDependencies() async {
  // ── External ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<SessionCubit>(
    () => SessionCubit(sl()),
    dispose: (session) => session.close(),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl(), session: sl()));
  sl.registerFactory<HomeCubit>(HomeCubit.new);
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FirestoreFavoritesRepository(sl(), sl()),
  );
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(sl(), sl()),
    dispose: (favorites) => favorites.close(),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: ApiConstants.baseUrl,
      idToken: () async => sl<FirebaseAuth>().currentUser?.getIdToken(),
    ),
  );
  sl.registerLazySingleton<PredictionRemoteDatasource>(
    () => PredictionRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(sl()),
  );
  sl.registerFactory<PredictionCubit>(() => PredictionCubit(sl()));
  sl.registerLazySingleton<RecommendationRemoteDatasource>(
    () => RecommendationRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDatasource>(
    () => ChatRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerFactory<RecommendationsCubit>(() => RecommendationsCubit(sl()));
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl()));

  // ── Phase 4+ ───────────────────────────────────────────────────────────────
  // Authentication, Firestore, repositories, and feature cubits will be
  // registered here as features are introduced.
  //
  // Example:
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(datasource: sl()),
  // );
}
