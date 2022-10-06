// ignore: implementation_imports
import 'package:awesome_notifications/src/models/model.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../fcm_definitions.dart';

class FcmSilentData extends Model {
  int? _id;
  Map<String, String?>? _data;
  DateTime? _createdDate;
  NotificationSource? _createdSource;
  NotificationLifeCycle? _createdLifeCycle;

  int? get id => _id;
  Map<String, String?>? get data => _data;
  DateTime? get createdDate => _createdDate;
  NotificationSource? get createdSource => _createdSource;
  NotificationLifeCycle? get createdLifeCycle => _createdLifeCycle;

  @override
  FcmSilentData? fromMap(Map<String, dynamic> dataMap) {
    _id = dataMap[NOTIFICATION_ID];

    if (data != null)
      _data?.clear();
    else
      _data = {};

    for (String key in dataMap.keys) {
      switch (key) {
        case NOTIFICATION_CREATED_DATE:
          _createdDate = AwesomeAssertUtils.extractValue(
              NOTIFICATION_CREATED_DATE, dataMap, DateTime);
          break;

        case NOTIFICATION_CREATED_SOURCE:
          _createdSource = AwesomeAssertUtils.extractEnum(
              NOTIFICATION_CREATED_SOURCE, dataMap, NotificationSource.values);
          break;

        case NOTIFICATION_CREATED_LIFECYCLE:
          _createdLifeCycle = AwesomeAssertUtils.extractEnum(
              NOTIFICATION_CREATED_LIFECYCLE,
              dataMap,
              NotificationLifeCycle.values);
          continue;

        case SILENT_HANDLE:
          break;

        default:
          _data![key] = dataMap[key]?.toString();
          break;
      }
    }

    return data?.isEmpty ?? true ? null : this;
  }

  @override
  Map<String, dynamic> toMap() {
    _data ??= {};
    _data!.addAll({
      NOTIFICATION_ID: _id?.toString(),
      NOTIFICATION_CREATED_DATE: _createdDate.toString(),
      NOTIFICATION_CREATED_SOURCE:
          AwesomeAssertUtils.toSimpleEnumString(_createdSource),
      NOTIFICATION_CREATED_LIFECYCLE:
          AwesomeAssertUtils.toSimpleEnumString(_createdLifeCycle),
    });

    return _data!;
  }

  @override
  void validate() {}
}
