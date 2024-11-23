import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_order/src/utils/toast_utils.dart';

/// Lấy vị trí hiện tại, nếu người dùng chưa cấp quyền truy cập
/// vị trí, sẽ yêu cầu cấp quyền. Nếu người dùng từ chối quyền,
/// sẽ hiển thị thông báo và trả về null.
///
/// Nếu người dùng đã cấp quyền, sẽ kiểm tra dịch vụ định
/// vị và trả về vị trí hiện tại. Nếu dịch vụ định vị chưa
/// được bật, sẽ hiển thị thông báo và trả về null.
///
/// Trả về `null` nếu có lỗi xảy ra.
Future<Position?> getCurrentLocation() async {
  PermissionStatus permission = await Permission.location.request();
  if (permission.isDenied || permission.isPermanentlyDenied) {
    // Quyền bị từ chối
    showToast('Người dùng từ chối quyền truy cập vị trí');
    return null;
  }

  if (permission.isGranted) {
    // Quyền được cấp, kiểm tra dịch vụ định vị
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      showToast('Dịch vụ định vị chưa được bật');
      return null;
    }

    try {
      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      showToast('Lỗi khi lấy vị trí: $e');
      return null;
    }
  }
  return null;
}
