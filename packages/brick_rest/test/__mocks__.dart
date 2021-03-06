import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:brick_rest/rest.dart';

class DemoRestModel extends RestModel {
  DemoRestModel(this.name);

  final String name;
}

/// Create [DemoRestModel] from json
Future<DemoRestModel> _$DemoRestModelFromRest(Map<String, dynamic> json) async {
  return DemoRestModel(json['name'] as String);
}

/// Create json from [DemoRestModel]
Future<Map<String, dynamic>> _$DemoRestModelToRest(DemoRestModel instance) async {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  return val;
}

/// Construct a [DemoRestModel] for the [RestRepository]
class DemoRestModelAdapter extends RestAdapter<DemoRestModel> {
  Future<DemoRestModel> fromRest(data, {provider, repository}) => _$DemoRestModelFromRest(data);
  Future<Map<String, dynamic>> toRest(instance, {provider, repository}) async =>
      await _$DemoRestModelToRest(instance);

  restEndpoint({query, instance}) {
    if (query != null && query?.params['limit'] != null && query.params['limit'] > 1) {
      return "/people";
    }

    return "/person";
  }

  final fromKey = null;
  final toKey = null;
}

final Map<Type, RestAdapter<RestModel>> _restMappings = {
  DemoRestModel: DemoRestModelAdapter(),
};
final restModelDictionary = RestModelDictionary(_restMappings);

class MockClient extends Mock implements http.Client {}
