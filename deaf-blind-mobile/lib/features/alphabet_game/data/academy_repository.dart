import 'academy_remote_source.dart';

/// §2 Coordinates academy data + on-device gesture classification.
class AcademyRepository {
  AcademyRepository(this._remote);
  final AcademyRemoteSource _remote;

  Future<List<dynamic>> levels() => _remote.getLevels();
}
