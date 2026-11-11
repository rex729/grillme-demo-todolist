import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dtos/todo_dto.dart';

part 'todo_api_service.g.dart';

/// 使用 Retrofit 宣告式定義 Todo RESTful API Endpoints
@RestApi()
abstract class TodoApiService {
  factory TodoApiService(Dio dio, {String baseUrl}) = _TodoApiService;

  @GET('/api/v1/todos')
  Future<TodoListResponseDto> getTodos();

  @POST('/api/v1/todos')
  Future<TodoSingleResponseDto> createTodo(
    @Body() UpsertTodoRequestDto body,
  );

  @PUT('/api/v1/todos/{id}')
  Future<TodoSingleResponseDto> updateTodo(
    @Path('id') String id,
    @Body() UpsertTodoRequestDto body,
  );

  @DELETE('/api/v1/todos/{id}')
  Future<void> deleteTodo(@Path('id') String id);
}
