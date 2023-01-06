import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer(
      {required this.video, required this.onNewVideoPressed, Key? key})
      : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  Duration currentPosition = Duration();
  bool showControls = false;

  @override
  void initState() {
    // 딱 한번만 불림 = 첫 비디오만 됨 -> 새로운 비디오가 재생이 안됨
    // 그래서 didUpdateWidget을 만들어줘야함
    super.initState();
    initializeController();
  }
  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.video.path != widget.video.path){
      // 방금 실행한 영상의 경로가 현재 틀고있는 영상 경로와 다를 경우
      // 다른 영상을 실행하면 다시 이니셜라이즈컨트롤러를 실행해라!

      initializeController();
    }
  }
  initializeController() async {
    currentPosition = Duration();
    videoPlayerController = VideoPlayerController.file(
      File(widget.video.path),
      // dart:io만 씀
    );

    await videoPlayerController!.initialize();
    videoPlayerController!.addListener(() async {
      final currentPosition = videoPlayerController!.value.position;
      setState(() {
        this.currentPosition = currentPosition;
      });

      //비디오컨트롤러에서 현재위치(currentPostion)이 변경 될때마다 새로 슬라이더 위치를
      //업데이트 시킴
    });
  }

  Widget build(BuildContext context) {
    if (videoPlayerController == null) {
      return CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: videoPlayerController!.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          //Stack = 영상이나 사진위에 무언가를 놓고 싶을 때
          children: [
            SizedBox(
              height: 50,
            ),
            VideoPlayer(videoPlayerController!),
            if (showControls)
              _controls(
                onReversePressed: onReversedPressed,
                onForwardPressed: onForwardPressed,
                onPlayPressed: onPlayPressed,
                isPlaying: videoPlayerController!.value.isPlaying,
              ),
            if (showControls)
              _newVideo(
                onPressed: widget.onNewVideoPressed,
              ),
            _bottomSlide(
                currentPosition: currentPosition,
                maxPosition: videoPlayerController!.value.duration,
                onSliderChanged: onSliderChanged)
          ],
        ),
      ),
    );
  }

  void onSliderChanged(double val) {
    videoPlayerController!.seekTo(
      Duration(
        seconds: val.toInt(),
      ),
    );
  }

  void onReversedPressed() {
    final currentPosition = videoPlayerController!.value.position;
    // position : 재생하고 있는 현재 위치(Duration이 초로 관리함)
    Duration position = Duration(); // 3초미만이면 0초로 이동함.
    //position = currentPosition - Duration(seconds: 3); <- 이걸 그대로 쓰면
    //1초 일때도 3초를 뒤로 가기 때문에 오류가 생김
    if (currentPosition.inSeconds > 3) {
      // 현재 위치가 3초보다 초과면
      position = currentPosition - Duration(seconds: 3);
    }
    videoPlayerController!.seekTo(position);
  }

  void onForwardPressed() {
    final maxPosition = videoPlayerController!.value.duration;
    final currentPosition = videoPlayerController!.value.position;
    Duration position = maxPosition; // 3초미만이면 0초로 이동함.
    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    } // 전체 영상길이의 3초를 뺀 것보다 현재 포지션이 길다면 현재 포지션에서 3을 더해줌,
    // 아닐 경우에는 최대 영상길이로 이동함
    videoPlayerController!.seekTo(position);
  }

  void onPlayPressed() {
    // 이미 실행중이면 중지
    // 실행 중이 아니면 실행
    setState(() {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.play();
      }
    });
  }
}

class _newVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _newVideo({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
        onPressed: onPressed,
        color: Colors.white,
        iconSize: 30.0,
        icon: Icon(Icons.photo_camera_back),
      ),
    );
  }
}

class _controls extends StatelessWidget {
  //onpressed 기능들을 파라미터로 구현
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _controls(
      {required this.onForwardPressed,
      required this.onReversePressed,
      required this.onPlayPressed,
      required this.isPlaying,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onReversePressed,
            iconData: Icons.rotate_left,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwardPressed,
            iconData: Icons.rotate_right,
          ),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
    // 다른 부분인 icon과 onpressed만 따로 관리
  }) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      color: Colors.white,
      icon: Icon(
        iconData,
      ),
    );
  }
}

class _bottomSlide extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _bottomSlide(
      {required this.currentPosition,
      required this.maxPosition,
      required this.onSliderChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      // 왼쪽과 오른쪽 끝 둘다 붙이고 싶으면 둘다 0을 주면 됨
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60)
                  // 60초가 넘으면 61초가 아닌 1초로 바뀌게
                  .toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
                max: maxPosition.inSeconds.toDouble(),
                min: 0,
              ),
            ),
            Text(
              '${maxPosition.inMinutes}:'
              '${(maxPosition.inSeconds % 60)
                  // 60초가 넘으면 61초가 아닌 1초로 바뀌게
                  .toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
