import 'package:get/get.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/todo/todo_binding.dart';
import '../modules/todo/todo_list_view.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.todos,
      page: () => const TodoListView(),
      binding: TodoBinding(),
    ),
  ];
}
