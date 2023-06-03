import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'bloc.dart';


class Blockchain {
  List<Block>? chain;
  int? difficulty;

  Blockchain(){
    chain = [];
    difficulty = 4;

  }

  // Create the genesis block of the blockchain
  Future<void> createGenesisBlock() async {
    final timestamp = DateTime.now().toIso8601String();
    final hash = calculateHash(
      0,
      timestamp,
      'Genesis Block',
      '0',
      0,
    );
    final block = Block(
      index: 0,
      timestamp: timestamp,
      data: 'Genesis Block',
      previousHash: '0',
      hash: hash,
      nonce: 0,
      valid: true,
    );
    // Mine the genesis block and add it to the chain
    await mineBlock(block);
    chain?.add(block);
  }

  // Calculate the SHA256 hash of a block's data
  String calculateHash(
      int index,
      String timestamp,
      dynamic data,
      String previousHash,
      int nonce,
      ) {
    final bytes = utf8.encode(
      '$index$timestamp${jsonEncode(data)}$previousHash$nonce',
    );
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Mine a block by finding a hash that meets the target difficulty
  Future<void> mineBlock(Block block) async {
    final target = '0' * difficulty!;
    var nonce = 0;

    while (true) {
      final hash = calculateHash(
        block.index,
        block.timestamp,
        block.data,
        block.previousHash,
        nonce,
      );
      print(hash);
      if (hash.startsWith(target)) {
        // If the hash meets the target difficulty, set the block's hash and nonce, mark it as valid, and add it to the chain
        block.hash = hash;
        block.nonce = nonce;
        block.valid = true;
        chain?[block.index] = block;
        break;
      }

      nonce++;
      // If the hash does not meet the target difficulty, mark the block as invalid and continue searching
      block.valid = false;
    }
  }

  // Add a new block to the blockchain
  Future<Block> addBlock(dynamic data) async {
    final previousBlock = chain?.last;
    final index = previousBlock!.index + 1;
    final timestamp = DateTime.now().toIso8601String();
    final nonce = 0;
    final previousHash = previousBlock.hash;
    final hash = calculateHash(
      index,
      timestamp,
      data,
      previousHash,
      nonce,
    );
print(hash);
    final newBlock = Block(
      index: index,
      timestamp: timestamp,
      data: data,
      previousHash: previousHash,
      hash: hash,
      nonce: nonce,
      valid: true,
    );

    // Mine the new block and add it to the chain
    await mineBlock(newBlock);
    chain?.add(newBlock);

    return newBlock;
  }

  // Get the current state of the blockchain
  List<Block>? getBlocks() {
    return chain;
  }

  // Invalidate a block and all subsequent blocks// Mark a block as invalid and set all subsequent blocks as invalid as well
  void notValid(Block block) {
    chain?[block.index].data = block.data;
    for (var i = block.index; i < chain!.length; i++) {
      chain?[i].valid = false;
    }
  }
}