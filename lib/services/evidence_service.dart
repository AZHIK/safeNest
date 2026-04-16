abstract class EvidenceService {
  Future<bool> submitEvidence(String filePath, String description);
}

class MockEvidenceService implements EvidenceService {
  @override
  Future<bool> submitEvidence(String filePath, String description) async {
    await Future.delayed(const Duration(seconds: 2));
    // Pretend successful encryption and upload
    return true;
  }
}
