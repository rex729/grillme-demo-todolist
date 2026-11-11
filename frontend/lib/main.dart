import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/providers/api_provider.dart';
import 'app/modules/auth/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 註冊全域服務與控制器
  Get.put<ApiProvider>(ApiProvider(), permanent: true);
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
