import 'package:flutter/material.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({super.key, required this.postId});
  final int postId;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState ();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(
        child: Text('Detail Post Screen'),
      ),
    );
  }
}
