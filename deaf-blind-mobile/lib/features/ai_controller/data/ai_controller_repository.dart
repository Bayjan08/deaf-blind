import 'ai_controller_remote_source.dart';

class AiControllerRepository {
  AiControllerRepository(this._remote);
  final AiControllerRemoteSource _remote;

  Future<Map<String, dynamic>> dashboard() => _remote.getDashboard();
}
