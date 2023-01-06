import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../component/custom_video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  Widget renderVideo(){
    return Center(
        child: CustomVideoPlayer
          (
          video: video!,
          onNewVideoPressed: onNewVideoPressed,
        ),
    );
    // 이 함수가 실행되는 경우는 video가 널이 아닌경우기 때문에 !를 붙임
  }

  BoxDecoration getBoxDecoration() {
    return BoxDecoration(
        //LinearGradient 시작부터 끝까지 천천히 색이 바뀜
        gradient: LinearGradient(
      begin: Alignment.topCenter, // 어디서부터 색을 시작할 것인지
      end: Alignment.bottomCenter, //어디서 끝낼 것 인지
      colors: [
        Colors.blue,
        Colors.black,
      ],
    ));
  }

  Widget renderEmpty() {
    return Container(
      width: MediaQuery.of(context).size.width,
      // decoration과 color는 둘중 하나만 써야한다
      decoration: getBoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _logo(
            onTap: onNewVideoPressed,
          ),
          SizedBox(height: 30),
          _logoText(),
        ],
      ),
    );
  }

  void onNewVideoPressed() async {
    print(1111);
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if(video != null){
      setState(() {
        this.video = video;
      });
    }
  }
}

class _logo extends StatelessWidget {
  final VoidCallback onTap;

  const _logo({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        'asset/image/logo1.jpg',
      ),
    );
  }
}

class _logoText extends StatelessWidget {
  const _logoText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.w300);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('VIDEO', style: textStyle),
        Text(
          'PLAYER',
          style: textStyle.copyWith(fontWeight: FontWeight.w700),
          // copyWith: 이 값들은 유지를 하고 추가하고 싶을때
        ),
      ],
    );
  }
}
