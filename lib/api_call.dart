import 'dart:convert';
import 'package:http/http.dart' as http;

//Auth token we will use to generate a meeting and connect to it
String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI5NzY3YzI1ZC03MTBjLTQyZDctYjI3OS0wM2MyNGQ0ZmRjODIiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTY4NDMyODg5OCwiZXhwIjoxNjg0OTMzNjk4fQ.-UbtxxrNyK8hQfxrmQwhBGd3AHtc4OYQLdlPr_smExM";

// API call to create meeting
Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token},
  );

//Destructuring the roomId from the response
  return json.decode(httpResponse.body)['roomId'];
}