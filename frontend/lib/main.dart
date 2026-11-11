import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/dio_client.dart';
import 'app/data/services/todo_api_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 註冊全域 Retrofit TodoApiService 與 AuthController
  final dio = DioClient.createDio();
  Get.put<TodoApiService>(TodoApiService(dio), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  final initialRoute = FirebaseAuth.instance.currentUser != null
      ? AppRoutes.todos
      : AppRoutes.login;

  runApp(CullioTodoApp(initialRoute: initialRoute));
}

class CullioTodoApp extends StatelessWidget {
  final String initialRoute;

  const CullioTodoApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cullio TodoList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
