import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino icons
import 'package:ibrahima_s_application_seter/core/app_export.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../wolof_assistant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}
class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position,
      double velocity,
      ) {
    final tolerance = this.tolerance;
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final simulation = ScrollSpringSimulation(spring, position.pixels, position.maxScrollExtent, velocity,
        tolerance: tolerance);
    return simulation;
  }
}



class HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  late WolofAssistant assistant;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000);
    _startTimer();
    _initializeSpeech();
    assistant = WolofAssistant();
  }

  void _initializeSpeech() async {
    _speechEnabled = await speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    bool available = await speech.initialize();
    if (available) {
      await speech.listen(
        onResult: (result) {
          setState(() {
            _wordsSpoken = result.recognizedWords;
            _confidenceLevel = result.confidence;
            _checkKeywords(_wordsSpoken);
          });
        },
      );
      setState(() {
        _confidenceLevel = 0;
      });
    } else {
      print("Speech recognition not available");
    }
  }

  void _checkKeywords(String words) async {
    final detectedLanguage = await assistant.detectLanguage(words);
    final translatedText = await assistant.translateText(words, detectedLanguage);
    if (translatedText.toLowerCase().contains('train')) {
      onTapTrain(context);
    } else if (translatedText.toLowerCase().contains('station')) {
      onTapStations(context);
    } else if (translatedText.toLowerCase().contains('abonnement')) {
      onTapAbonnement(context);
    } else if (translatedText.toLowerCase().contains('bagages')) {
      onTapBagages(context);
    } else if (translatedText.toLowerCase().contains('ticket')) {
      onTapTrainTicket(context);
    } else if (translatedText.toLowerCase().contains('horaires')) {
      onTapHoraires(context);
    }
  }


  void _stopListening() async {
    await speech.stop();
    setState(() {});
  }

  @override
  void dispose() {
    assistant.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _currentPage = (_currentPage + 1) % 6; // Assuming you have 6 images
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 480.v,
                  width: double.maxFinite,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      PageView(
                        controller: _pageController,
                        physics: CustomScrollPhysics(),
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgPa3,
                            height: 620.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPa4,
                            height: 485.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPa5,
                            height: 620.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPa6,
                            height: 620.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPa7,
                            height: 620.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgPa8,
                            height: 620.v,
                            width: screenWidth,
                            alignment: Alignment.center,
                          ),
                        ],
                      ),
                      _buildMenuRow(context),
                    ],
                  ),
                ),
                _buildNextStack(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context) {
    return SizedBox(
      height: 47.adaptSize,
      width: double.infinity,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          if (details.localPosition.dx < MediaQuery.of(context).size.width / 3 &&
              details.localPosition.dy < MediaQuery.of(context).padding.top + kToolbarHeight) {
            onTapMenu(context);
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remove the menu logo
              SizedBox(),
              // Remove the search icon
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStack(BuildContext context) {
    return SizedBox(
      height: 407.v,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 99.v),
              child: Text(
                "lbl_next".tr,
                style: CustomTextStyles.titleLargeBlack90001,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 57.v),
              decoration: BoxDecoration(
                color: Colors.white, // Change to white color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.tram_fill,
                        label: "lbl_stations".tr,
                        onTap: onTapStations,
                      ),
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.bag_fill,
                        label: "lbl_bagages".tr,
                        onTap: onTapBagages,
                      ),
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.square_grid_2x2_fill,
                        label: "lbl_abonnement".tr,
                        onTap: onTapAbonnement,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.ticket_fill,
                        label: "lbl_tickets".tr,
                        onTap: onTapTrainTicket,
                      ),
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.tram_fill,
                        label: "lbl_trains".tr,
                        onTap: onTapTrain,
                      ),
                      _buildIcon(
                        context,
                        iconData: CupertinoIcons.clock_fill,
                        label: "lbl_horaires".tr,
                        onTap: onTapHoraires,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _startListening,
                tooltip: 'Start Listening',
                child: Icon(Icons.mic),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _wordsSpoken, // Display recognized words here
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
      BuildContext context, {
        required IconData iconData,
        required String label,
        required Function onTap,
      }) {
    return GestureDetector(
      onTap: () {
        onTap(context);
      },
      child: Column(
        children: [
          Container(
            height: 72.adaptSize,
            width: 72.adaptSize,
            margin: EdgeInsets.only(left: 2.h),
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: Color(0x2280542B), // 14% opacity
              borderRadius: BorderRadius.circular(36.0),
            ),
            child: Icon(
              iconData,
              size: 48.adaptSize,
              color: Color(0xFF6C4B26), // Brown color
            ),
          ),
          SizedBox(height: 9.v),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0, // Adjust as needed
            ),
          ),
        ],
      ),
    );
  }

  void onTapStations(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.stationsScreen,
    );
  }

  void onTapBagages(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.bagagesScreen,
    );
  }

  void onTapHoraires(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.horaire1DarkScreen,
    );
  }

  void onTapAbonnement(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.abonnementScreen,
    );
  }

  void onTapTrainTicket(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.ticketsScreen,
    );
  }

  void onTapTrain(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.trainsThreeScreen,
    );
  }

  void onTapMenu(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.menuDarkDraw,
    );
  }

  /// Navigates to the search screen when the search icon is tapped.
  void onTapImgFeSearch(BuildContext context) {
    // Add your navigation logic here
  }
}
