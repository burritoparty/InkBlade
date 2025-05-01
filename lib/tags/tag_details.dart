import 'package:flutter/material.dart';
import 'package:flutter_manga_reader/widgets/widgets.dart';

class TagDetails extends StatefulWidget {
  final String tag;
  const TagDetails({Key? key, required this.tag}) : super(key: key);

  @override
  State<TagDetails> createState() => _TagDetailsState();
}

class _TagDetailsState extends State<TagDetails> {
  late TextEditingController _controller;
  late String _currentTag;
  final List<String> allTags = List.generate(15, (i) => 'tagname$i');

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    _controller = TextEditingController(text: _currentTag);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String newTag) {
    setState(() {
      _currentTag = newTag;
      _controller.text = newTag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentTag)),
      body: Center(
        child: TitleEditor(
          controller: _controller,
          onSubmitted: _onSubmitted,
        ),
      ),
    );
  }
}
