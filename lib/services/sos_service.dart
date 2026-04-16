abstract class SOSService {
  Future<bool> sendAlert();
  Future<bool> cancelAlert();
}

class MockSOSService implements SOSService {
  bool _isActive = false;

  @override
  Future<bool> sendAlert() async {
    await Future.delayed(const Duration(seconds: 1));
    _isActive = true;
    return _isActive;
  }

  @override
  Future<bool> cancelAlert() async {
    await Future.delayed(const Duration(seconds: 1));
    _isActive = false;
    return true;
  }
}
