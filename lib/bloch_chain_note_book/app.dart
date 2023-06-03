import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'bloc.dart';
import 'bloch_chain.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();
    _createGenesisBlock();
  }

  // Create the genesis block of the blockchain
  void _createGenesisBlock() async {
    final timestamp = DateTime.now().toIso8601String();
    final hash = _calculateHash(
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
    await blockchain.mineBlock(block);
    setState(() {});
  }

  // Calculate the SHA256 hash of a block's data
  String _calculateHash(
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

  // Add a new block to the blockchain
  Future<void> _addBlock(String data) async {
    final previousBlock = blockchain.chain.last;
    final index = previousBlock.index + 1;
    final timestamp = DateTime.now().toIso8601String();
    final nonce = 0;
    final previousHash = previousBlock.hash;
    final hash = _calculateHash(
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
    await blockchain.mineBlock(newBlock);
    setState(() {});
  }

  // Invalidate a block and all subsequent blocks
  void _notValid(Block block) {
    blockchain.chain[block.index].data = block.data;
    for (var i = block.index; i < blockchain.chain.length; i++) {
      blockchain.chain[i].valid = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: blockchain.chain.length,
          itemBuilder: (BuildContext context, int index) {
            final block = blockchain.chain[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Block $index'),
                  TextFormField(
                    initialValue: block.data,
                    onChanged: (value) {
                      setState(() {
                        block.data = value;
                        block.valid = false;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data',
                    ),
                  ),
                  Text('Nonce: ${block.nonce}'),
                  const Divider(),
                  const Text('Hash:'),
                  Text(block.hash),
                  const Divider(),
                  const Text('Previous Hash:'),
                  Text(block.previousHash),
                  const Divider(),
                  Text('Timestamp: ${block.timestamp}'),
                  if (!block.valid)
                    const Text(
                      'Block is not valid',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await blockchain.mineBlock(block);
                          setState(() {});
                        },
                        child: const Text('Mine'),
                      ),
                      TextButton(
                        onPressed: () {
                          _notValid(block);
                        },
                        child: const Text('Invalidate'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: const Text('Add a new block'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Data',
                      ),
                      onFieldSubmitted: (value) async {
                        final value1 = await _addBlock('sfhd');
                        Navigator.pop(context,value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          print('***********************');
                          Navigator.pop(context, null);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {

                          final value = await _addBlock('fdhhfgs');
                          await blockchain.addBlock('jhgf');

                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              );
            },
          );
          if (data != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Block added'),
              duration: Duration(seconds: 2),
            ));
          }
        },
        tooltip: 'Add block',
        child: const Icon(Icons.add),
      ),
    );
  }
}
