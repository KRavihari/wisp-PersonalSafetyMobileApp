import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('lets chat'),
          backgroundColor: const Color(0XFFF7931E),
          elevation: 0,
        ),
        body: Tawk(
          directChatLink: 'https://tawk.to/chat/680c4238bb1753191a4ddc09/1ipnu5b7u',
          visitor: TawkVisitor(
            name: 'test',
            email: 'testmail@gmail.com',
          ),
          onLoad: () {
            print('Hello Tawk!');
          },
          onLinkTap: (String url) {
            print(url);
          },
          placeholder: const Center(
            child: Text('Loading...'),
          ),
        ),
      ),
    );
  }
}