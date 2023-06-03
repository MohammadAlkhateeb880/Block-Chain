class Block {
  final int index;
  final String timestamp;
   dynamic data;
  final String previousHash;
  String hash;
  int nonce;
  bool valid;

  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
    required this.hash,
    required this.nonce,
    required this.valid,
  });
}