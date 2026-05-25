class PermissionManifestItem {
  const PermissionManifestItem({
    required this.name,
    required this.purpose,
    required this.requiredForMvp,
  });

  final String name;
  final String purpose;
  final bool requiredForMvp;
}

class PermissionManifest {
  static const items = <PermissionManifestItem>[
    PermissionManifestItem(
      name: 'Accessibility Service',
      purpose: 'Cross-app task automation for approved plans',
      requiredForMvp: true,
    ),
    PermissionManifestItem(
      name: 'Microphone',
      purpose: 'Offline speech-to-text using local voice models',
      requiredForMvp: true,
    ),
    PermissionManifestItem(
      name: 'Notifications',
      purpose: 'On-device notification reading and reply assistance',
      requiredForMvp: false,
    ),
    PermissionManifestItem(
      name: 'Storage Access',
      purpose: 'Read local GGUF models and local documents for RAG',
      requiredForMvp: true,
    ),
    PermissionManifestItem(
      name: 'Overlay',
      purpose: 'Floating assistant bubble over apps',
      requiredForMvp: false,
    ),
  ];
}
