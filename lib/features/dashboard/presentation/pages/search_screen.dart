import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController prinController = TextEditingController();

  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  double interest = 0;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(child: Padding(padding: const EdgeInsets.all(8.0))),
    );
  }
}
