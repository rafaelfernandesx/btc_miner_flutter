import 'package:btc_miner/btc_miner.dart' as btc_miner;
import 'package:btc_miner_example/miner.dart';
import 'package:btc_miner_example/utils.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // late Future<int> sumAsyncResult;

  bool mining = false;
  BlockTemplate? blockTemplate;
  List<String> logger = [];
  void startMiner() async {
    setState(() {
      mining = true;
      logger.add('Mineração iniciada');
    });

    final rpcClient = BitcoinRpcClient('address', 'user', 'pass');
    final miner = BitcoinMiner(rpcClient);

    blockTemplate = await rpcClient.getBlockTemplate();

    if (blockTemplate == null) {
      setState(() {
        logger.add('Failed to get block template');
        mining = false;
      });
      return;
    }
    const coinbaseMessage = 'Mined by RafaelFernandes';
    const address = '1rafaeLAdmgQhS2i4BR1tRst666qyr9ut';
    final headerHexAndTargetHex = miner.getBlockHeaderHex(blockTemplate!, coinbaseMessage.codeUnits, address);

    if (headerHexAndTargetHex == null) {
      setState(() {
        logger.add('Failed to get block header');
        mining = false;
      });
      // Future.delayed(const Duration(seconds: 0)).then((value) => startMiner());
      return;
    }
    final pointer = btc_miner.minerHeader(headerHexAndTargetHex['headerHex']!.toNativeUtf8().cast(), headerHexAndTargetHex['targetHex']!.toNativeUtf8().cast());

    String nonceAndHeaderHex = pointerCharToDartString(pointer);

    blockTemplate!.nonce = int.parse(nonceAndHeaderHex.split('-')[0]);
    blockTemplate!.blockHash = nonceAndHeaderHex.split('-')[1];
    final blockHeader = miner.buildBlock(blockTemplate!);
    final resultSubmit = await rpcClient.submitBlock(blockHeader);
    if (resultSubmit == null || resultSubmit['error'] != null) {
      setState(() {
        logger.add(resultSubmit.toString());
        mining = false;
      });
      // Future.delayed(const Duration(seconds: 0)).then((value) => startMiner());
      return;
    }
    setState(() {
      logger.add(nonceAndHeaderHex);
      mining = false;
    });
    // Future.delayed(const Duration(seconds: 0)).then((value) => startMiner());
  }

  void calculateHashPerSeconds() {
    setState(() {
      mining = true;
    });
    final pointer = btc_miner.calculateHashPerSeconds();
    final dartString = pointerCharToDartString(pointer);
    setState(() {
      logger.add('Hash/s $dartString');
      mining = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Miner C++/Dart FFI'),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // FutureBuilder<int>(
                //   future: sumAsyncResult,
                //   builder: (BuildContext context, AsyncSnapshot<int> value) {
                //     final displayValue = (value.hasData) ? value.data : 'loading';
                //     return Text(
                //       'await sumAsync(3, 4) = $displayValue',
                //       style: textStyle,
                //       textAlign: TextAlign.center,
                //     );
                //   },
                // ),
                const Text('Miner', style: textStyle),
                TextField(
                  controller: TextEditingController(text: logger.join('\n')),
                  readOnly: true,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Logger',
                  ),
                ),
                ElevatedButton(
                  onPressed: mining ? null : startMiner,
                  child: mining ? const Text('Stop Miner') : const Text('Start Miner'),
                ),
                ElevatedButton(
                  onPressed: mining ? null : calculateHashPerSeconds,
                  child: mining ? const Text('Calculando') : const Text('Calculater hash/s'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
