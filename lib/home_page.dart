import 'package:ai_spoken_partner/openai_service.dart';
import 'package:ai_spoken_partner/pallete.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImage;
  bool hasApiCallHappened = false;

  @override
  void initState() {
    initSpeechToText();
    initTextToSpeech();
    initEnglishSpokenTutorEnvironment();
    super.initState();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initEnglishSpokenTutorEnvironment() async {
    await openAIService.chatGPTAPI(
        "Imagine you are Nancy Jewel McDonie from Momoland. Please respond as if you were Nancy, like a native English speaker having a casual chat. Keep it simple and natural. Feel free to share your thoughts and experiences, and I'll ask questions related to you. When you get 'reply shortly.' keep your reply within a maximum of 3 lines, 1 is appreciated.");
    print("English spoken tutor environment initialized.");
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    print("Start listening called.*****************************");
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  callApiIfNotCall(){
    Future.delayed(const Duration(seconds: 22),(){
      if(hasApiCallHappened==false && lastWords!=''){
        connectToAIPartner(yourSpeech: "$lastWords.reply shortly.");
      }
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    print("On speech result called.*****************************");
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  connectToAIPartner({required String yourSpeech}) async {
    hasApiCallHappened = true;
    final speech = await openAIService.chatGPTAPI("$yourSpeech");
    generatedContent = speech;
    generatedImage = null;
    setState(() {});
    await systemSpeak(speech);
    hasApiCallHappened = false;
    lastWords = '';
    await stopListening();
  }

  Future<void> systemSpeak(String content) async {
    print("System speak called.*****************************");
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    print("Dispose called.*****************************");
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Spoken Partner'),
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Generate Report'),
                  content: Text('Do you want to get feedback on your overall conversation?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Handle the case where the user selects "No"
                      },
                    ),
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        connectToAIPartner(yourSpeech: "Thank you for our chat! I'm eager to enhance my English skills. Could you kindly provide feedback? Are there any grammar errors I should be aware of, or any suggestions to make my language sound more natural?");
                        Navigator.of(context).pop(); // Close the dialog
                        // Handle the case where the user selects "Yes" (e.g., initiate report generation)
                      },
                    ),
                  ],
                );
              },
            );
          }, icon: Icon(Icons.recommend_outlined))
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            //virtual assistant image
            generatedContent==null?Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/virtualAssistant.png'))),
                )
              ],
            ):AvatarGlow(
    glowColor: Colors.blue,
    endRadius: 90.0,
    duration: Duration(milliseconds: 2000),
    repeat: true,
    showTwoGlows: true,
    repeatPauseDuration: Duration(milliseconds: 100),
    child:Stack(
      children: [
        Center(
          child: Container(
            height: 120,
            width: 120,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
                color: Pallete.assistantCircleColor,
                shape: BoxShape.circle),
          ),
        ),
        Container(
          height: 123,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(
                      'assets/images/virtualAssistant.png'))),
        )
      ],
    ),
    ),
            Visibility(
              visible: generatedImage == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                  border: Border.all(color: Pallete.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    (generatedContent == null)
                        ? "Hi there! Would you like to have a conversation and practice English together?"
                        : generatedContent!,
                    style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: (generatedContent == null) ? 25 : 18,
                        fontFamily: 'Cera Pro'),
                  ),
                ),
              ),
            ),
            if (generatedImage != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImage!)),
              ),
            //suggestions list
            // Visibility(
            //   visible: generatedContent == null && generatedImage == null,
            //   child: Container(
            //     padding: const EdgeInsets.all(10),
            //     margin: const EdgeInsets.only(top: 10, left: 22),
            //     alignment: Alignment.centerLeft,
            //     child: const Text(
            //       "Here are a few features",
            //       style: TextStyle(
            //           color: Pallete.mainFontColor,
            //           fontSize: 20,
            //           fontFamily: 'Cera Pro',
            //           fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),

            //features list
            // Visibility(
            //   visible: generatedContent == null && generatedImage == null,
            //   child:  Column(
            //     children: [
            //       // FeatureBox(
            //       //   color: Pallete.firstSuggestionBoxColor,
            //       //   headerText: "AI Spoken Partner",
            //       //   descriptionText:
            //       //       "Improve your English speaking with me.",
            //       // ),
            //       // FeatureBox(
            //       //   color: Pallete.secondSuggestionBoxColor,
            //       //   headerText: "Dall-E",
            //       //   descriptionText:
            //       //       "Get inspired and stay creative with your personal assistant powered by Dall-E",
            //       // ),
            //       // FeatureBox(
            //       //   color: Pallete.thirdSuggestionBoxColor,
            //       //   headerText: "Smart Voice Assistant",
            //       //   descriptionText:
            //       //       "Get the best of both worlds witha voice assistant powered by Dall-E and ChatGPT",
            //       // ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 30,),
            // InkWell(
            //   onTap: () async {
            //     print("FAB pressed.*********************************");
            //     if (await speechToText.hasPermission && speechToText.isNotListening) {
            //       await startListening();
            //       callApiIfNotCall();
            //     } else if (speechToText.isListening) {
            //       print(
            //           "ChatGPT api call is initiated from FAB.Lastwords:$lastWords");
            //       // final speech =
            //       //     await openAIService.chatGPTAPI("$lastWords.Reply shortly.");
            //       // // if (speech.contains('https')) {
            //       // //   print("Image url:$speech");
            //       // //   generatedImage = speech;
            //       // //   generatedContent = null;
            //       // //   setState(() {});
            //       // // } else {
            //       // //   generatedContent = speech;
            //       // //   generatedImage = null;
            //       // //   setState(() {});
            //       // //   await systemSpeak(speech);
            //       // // }
            //       // generatedContent = speech;
            //       // generatedImage = null;
            //       // setState(() {});
            //       // await systemSpeak(speech);
            //       //await stopListening();
            //       hasApiCallHappened = true;
            //       await connectToAIPartner(yourSpeech: lastWords);
            //     } else {
            //       initSpeechToText();
            //     }
            //   },
            //   //backgroundColor: Pallete.firstSuggestionBoxColor,
            //   //child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
            //   child: speechToText.isListening? AvatarGlow(
            //     glowColor: Colors.blue,
            //     endRadius: 80.0,
            //     duration: Duration(milliseconds: 2000),
            //     repeat: true,
            //     showTwoGlows: true,
            //     repeatPauseDuration: Duration(milliseconds: 100),
            //     child: Material(     // Replace this child with your own
            //       elevation: 8.0,
            //       shape: const CircleBorder(),
            //       child: CircleAvatar(
            //         backgroundColor: Pallete.assistantCircleColor,
            //         radius: 40.0,
            //         child: const Icon(Icons.stop,color: Colors.black,),
            //       ),
            //     ),
            //   ): CircleAvatar(
            //     radius: 80,
            //     backgroundColor: Colors.transparent,
            //     foregroundColor: Colors.transparent,
            //     child: CircleAvatar(
            //     backgroundColor: Pallete.assistantCircleColor,
            //     radius: 40.0,
            //     child: const Icon(Icons.mic,color: Colors.black,),
            //     ),
            //   ),
            // ),
            SizedBox(height: 100,)
          ],
        ),
      ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () async {
          print("FAB pressed.*********************************");
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
            callApiIfNotCall();
          } else if (speechToText.isListening) {
            print(
                "ChatGPT api call is initiated from FAB.Lastwords:$lastWords");
            // final speech =
            //     await openAIService.chatGPTAPI("$lastWords.Reply shortly.");
            // // if (speech.contains('https')) {
            // //   print("Image url:$speech");
            // //   generatedImage = speech;
            // //   generatedContent = null;
            // //   setState(() {});
            // // } else {
            // //   generatedContent = speech;
            // //   generatedImage = null;
            // //   setState(() {});
            // //   await systemSpeak(speech);
            // // }
            // generatedContent = speech;
            // generatedImage = null;
            // setState(() {});
            // await systemSpeak(speech);
            //await stopListening();
            hasApiCallHappened = true;
            await connectToAIPartner(yourSpeech: "$lastWords.reply shortly.");
          } else {
            initSpeechToText();
          }
        },
        //backgroundColor: Pallete.firstSuggestionBoxColor,
        //child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        child: speechToText.isListening? AvatarGlow(
          glowColor: Colors.blue,
          endRadius: 80.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: Material(     // Replace this child with your own
            elevation: 8.0,
            shape: const CircleBorder(),
            child: CircleAvatar(
              backgroundColor: Pallete.assistantCircleColor,
              radius: 40.0,
              child: const Icon(Icons.stop,color: Colors.black,),
            ),
          ),
        ): CircleAvatar(
          radius: 80,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          child: CircleAvatar(
            backgroundColor: Pallete.assistantCircleColor,
            radius: 40.0,
            child: const Icon(Icons.mic,color: Colors.black,),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     print("FAB pressed.*********************************");
      //     if (await speechToText.hasPermission && speechToText.isNotListening) {
      //       await startListening();
      //       callApiIfNotCall();
      //     } else if (speechToText.isListening) {
      //       print(
      //           "ChatGPT api call is initiated from FAB.Lastwords:$lastWords");
      //       // final speech =
      //       //     await openAIService.chatGPTAPI("$lastWords.Reply shortly.");
      //       // // if (speech.contains('https')) {
      //       // //   print("Image url:$speech");
      //       // //   generatedImage = speech;
      //       // //   generatedContent = null;
      //       // //   setState(() {});
      //       // // } else {
      //       // //   generatedContent = speech;
      //       // //   generatedImage = null;
      //       // //   setState(() {});
      //       // //   await systemSpeak(speech);
      //       // // }
      //       // generatedContent = speech;
      //       // generatedImage = null;
      //       // setState(() {});
      //       // await systemSpeak(speech);
      //       //await stopListening();
      //       hasApiCallHappened = true;
      //       await connectToAIPartner(yourSpeech: lastWords);
      //     } else {
      //       initSpeechToText();
      //     }
      //   },
      //   backgroundColor: Pallete.firstSuggestionBoxColor,
      //   //child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      //   child: speechToText.isListening? AvatarGlow(
      //     glowColor: Colors.blue,
      //     endRadius: 300.0,
      //     duration: Duration(milliseconds: 2000),
      //     repeat: true,
      //     showTwoGlows: true,
      //     repeatPauseDuration: Duration(milliseconds: 100),
      //     child: Material(     // Replace this child with your own
      //       elevation: 8.0,
      //       shape: const CircleBorder(),
      //       child: CircleAvatar(
      //         backgroundColor: Colors.grey[100],
      //         radius: 40.0,
      //         child: const Icon(Icons.stop),
      //       ),
      //     ),
      //   ):const Icon(Icons.mic),
      // ),
    );
  }
}
