import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/todo/bindings/todo_binding.dart';
import '../modules/todo/views/todo_list_view.dart';
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
