enum TransferState { queued, inProgress, completed, failed }

class TransferJob {
  TransferJob({
    required this.id,
    required this.fileName,
    required this.receiverId,
    required this.totalBytes,
    required this.sentBytes,
    required this.state,
  });

  final String id;
  final String fileName;
  final String receiverId;
  final int totalBytes;
  final int sentBytes;
  final TransferState state;

  double get progress => totalBytes == 0 ? 0 : sentBytes / totalBytes;

  TransferJob copyWith({
    int? sentBytes,
    TransferState? state,
  }) {
    return TransferJob(
      id: id,
      fileName: fileName,
      receiverId: receiverId,
      totalBytes: totalBytes,
      sentBytes: sentBytes ?? this.sentBytes,
      state: state ?? this.state,
    );
  }
}
