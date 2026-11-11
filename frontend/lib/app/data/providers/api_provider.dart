import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../models/todo_model.dart';

class ApiProvider extends GetConnect {
  /// 預設本地開發伺服器位址：
  /// Android 模擬器透過 10.0.2.2 存取主機的 :8080，iOS 模擬器使用 localhost:8080。
  /// 亦可透過 --dart-define=API_BASE_URL=http://your-ip:8080 覆寫。
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  @override
  void onInit() {
    httpClient.baseUrl = defaultBaseUrl;
    httpClient.timeout = const Duration(seconds: 15);

    // 請求攔截器：自動附加 Firebase ID Token 至 Authorization Bearer Header
    httpClient.addRequestModifier<dynamic>((request) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $idToken';
        }
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    // 回應攔截器：若收到 401 Unauthorized，自動登出並導回登入頁
    httpClient.addResponseModifier((request, response) async {
      if (response.statusCode == 401) {
        await FirebaseAuth.instance.signOut();
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      }
      return response;
    });

    super.onInit();
  }

  /// GET /api/v1/todos
  Future<List<TodoModel>> fetchTodos() async {
    final response = await get('/api/v1/todos');
    if (response.hasError) {
      throw Exception(_extractError(response, '無法載入待辦事項列表'));
    }
    final body = response.body;
    final List<dynamic> list = (body is Map && body['data'] is List)
        ? body['data'] as List<dynamic>
        : <dynamic>[];
    return list
        .map((item) => TodoModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// POST /api/v1/todos
  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await post('/api/v1/todos', todo.toRequestJson());
    if (response.hasError) {
      throw Exception(_extractError(response, '新增待辦事項失敗'));
    }
    final data = Map<String, dynamic>.from(response.body['data'] as Map);
    return TodoModel.fromJson(data);
  }

  /// PUT /api/v1/todos/:id
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final response = await put(
      '/api/v1/todos/${todo.id}',
      todo.toRequestJson(),
    );
    if (response.hasError) {
      throw Exception(_extractError(response, '更新待辦事項失敗'));
    }
    final data = Map<String, dynamic>.from(response.body['data'] as Map);
    return TodoModel.fromJson(data);
  }

  /// DELETE /api/v1/todos/:id
  Future<void> deleteTodo(String id) async {
    final response = await delete('/api/v1/todos/$id');
    if (response.hasError) {
      throw Exception(_extractError(response, '刪除待辦事項失敗'));
    }
  }

  String _extractError(Response<dynamic> response, String fallback) {
    final body = response.body;
    if (body is Map && body['error'] != null) {
      return body['error'].toString();
    }
    return response.statusText ?? fallback;
  }
}
