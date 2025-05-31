import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/utils/colors.dart';

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  TextEditingController _inputController = TextEditingController();
  String? _selectedLanguage;
  String _translatedText = '';
  bool _isTranslating = false;

  // **Language codes used by Google Translate**
  final Map<String, String> _languages = {
    'Afrikaans': 'af',
    'Albanian': 'sq',
    'Arabic': 'ar',
    'Armenian': 'hy',
    'Bengali': 'bn',
    'Bulgarian': 'bg',
    'Catalan': 'ca',
    'Chinese (Simplified)': 'zh-CN',
    'Chinese (Traditional)': 'zh-TW',
    'Croatian': 'hr',
    'Czech': 'cs',
    'Danish': 'da',
    'Dutch': 'nl',
    'English': 'en',
    'Estonian': 'et',
    'Filipino': 'tl',
    'Finnish': 'fi',
    'French': 'fr',
    'German': 'de',
    'Greek': 'el',
    'Gujarati': 'gu',
    'Hebrew': 'he',
    'Hindi': 'hi',
    'Hungarian': 'hu',
    'Icelandic': 'is',
    'Indonesian': 'id',
    'Italian': 'it',
    'Japanese': 'ja',
    'Kannada': 'kn',
    'Korean': 'ko',
    'Latvian': 'lv',
    'Lithuanian': 'lt',
    'Malay': 'ms',
    'Malayalam': 'ml',
    'Marathi': 'mr',
    'Norwegian': 'no',
    'Persian': 'fa',
    'Polish': 'pl',
    'Portuguese': 'pt',
    'Punjabi': 'pa',
    'Romanian': 'ro',
    'Russian': 'ru',
    'Serbian': 'sr',
    'Slovak': 'sk',
    'Slovenian': 'sl',
    'Spanish': 'es',
    'Swahili': 'sw',
    'Swedish': 'sv',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Thai': 'th',
    'Turkish': 'tr',
    'Ukrainian': 'uk',
    'Urdu': 'ur',
    'Vietnamese': 'vi',
    'Welsh': 'cy',
  };

  /// **Uses Google Translate Web Scraping**
  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0][0][0]; // Extract translated text
      } else {
        print('Translation failed: ${response.body}');
        return 'Translation failed!';
      }
    } catch (e) {
      print('Error: $e');
      return 'Network error!';
    }
  }

  Future<void> _translate() async {
    if (_selectedLanguage == null || _inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter text & select a language!')),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    String targetLanguage = _languages[_selectedLanguage!]!;
    String? translation =
        await translateText(_inputController.text, targetLanguage);

    setState(() {
      _translatedText = translation ?? 'Translation failed!';
      _isTranslating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Translation Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: scribblrPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Enter text to translate',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select language'),
              value: _selectedLanguage,
              items: _languages.keys.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isTranslating ? null : _translate,
              child: _isTranslating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Translate'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: scribblrPrimaryColor),
            ),
            SizedBox(height: 24),
            _translatedText.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child:
                        Text(_translatedText, style: TextStyle(fontSize: 18)),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
