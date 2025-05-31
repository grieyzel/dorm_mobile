import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../components/contact_us_component.dart';
import '../components/faq_component.dart';

const APP_NAME = 'Scribblr';

// const String BaseUrl = 'http://192.168.1.2:8001';
const String BaseUrl = 'http://167.99.15.203:8001';

//AuthorName

class AuthorName {
  //female
  static const authEmma = 'Emma';
  static const authEliza = 'Eliza';
  static const authElina = 'Elina';
  static const authChristina = 'Christina';

  //male
  static const authStark = 'Allen';
  static const authChris = 'Allen';
  static const authNolan = 'Allen';
  static const authStuart = 'Allen';
  static const authGeorge = 'Allen';
  static const authMiller = 'Allen';
}

//ArticleTitle

class ArticleTitle {
  static const authEmma = 'Campus Music Festival';
  static const authEliza = 'campus day';
  static const authStark = 'Decoding the Future into Emerging Technologies';
  static const authElina = 'Elevate Your Home Cooking Experience';
  static const authChris = 'Unlocking the Secrets of Affordable Travel';
  static const authNolan = 'Embracing Green Steps Towards Sustainable Living';
  static const authChristina =
      'Strategic Business Management: A Comprehensive Overview';
  static const authStuart =
      'A Detailed Study on Advancements in Modern Education';
  static const authGeorge =
      'A Quantitative Assessment on Economic Policies and Their Impact';
  static const authMiller = 'The Revolutionary Future of Sports';
}

//ArticleContent
class ArticleContent {
  static const articleContent1 =
      ''' Traveling doesn’t always have to be expensive. With the right strategies, you can explore the world without breaking the bank. It all starts with planning ahead. Booking flights and accommodations well in advance can lead to significant savings, as airlines and hotels often offer discounts for early bookings. Choosing to travel during the off-peak season is another great way to save money. Not only will you avoid the crowds, but you’ll also benefit from lower prices. Opting for budget airlines and accommodations can further reduce your travel costs. While these options may not offer the luxury of their more expensive counterparts, they are more than sufficient for a comfortable journey. Packing light is another secret to affordable travel. By doing so, you can save on baggage fees and make your travel experience more convenient. When it comes to food, trying the local cuisine can be both a cultural experience and a way to save money, as it’s usually cheaper than dining at tourist-targeted restaurants.''';

  static const articleContent2 =
      '''Time management is a crucial skill that can significantly enhance productivity. By implementing effective time management strategies, one can optimize their work process, reduce stress, and ultimately achieve more in less time.Time management is the process of organizing and planning how to divide your time between specific activities. Good time management enables you to work smarter, not harder, so that you get more done in less time, even when time is tight and pressures are high.One of the key strategies in effective time management is prioritization. Prioritizing tasks based on their importance and urgency is a key strategy. The Eisenhower Matrix, which categorizes tasks into four quadrants based on their urgency and importance, can be a useful tool for this.Setting clear and achievable goals is another important strategy. SMART (Specific, Measurable, Achievable, Relevant, Time-bound) goals can provide a clear direction and make it easier to manage time effectively.Time blocking is another effective strategy. This involves dedicating specific time slots for different tasks or activities throughout the day. It can help ensure that sufficient time is allocated for important tasks.Contrary to popular belief, multitasking can reduce productivity. Focusing on one task at a time can lead to increased efficiency. Therefore, avoiding multitasking is another strategy that can enhance productivity.Regular breaks can help maintain a high level of productivity and creativity. Techniques like the Pomodoro Technique, which involves taking a short break after every 25 minutes of work, can be very effective.Implementing effective time management strategies can lead to significant improvements in productivity. It can help individuals achieve more, reduce stress, and lead to greater career success. Remember, time management skills are a journey, shaped by experiences and refinement of techniques. Start small, stay consistent, and gradually you’ll become adept at managing your time effectively.''';
  static const articleContent3 =
      '''As we venture into the future, emerging technologies are becoming the new norm, shaping our lives in unprecedented ways. Artificial Intelligence, Blockchain, and Quantum Computing are no longer concepts of science fiction, but realities that are transforming industries, from healthcare to finance. These technologies are decoding the future, enabling us to solve complex problems, enhance productivity, and create a more connected world.The advent of these technologies has also brought about a paradigm shift in the way we work and interact. Automation and AI have streamlined processes, reducing human error and increasing efficiency. Blockchain technology, with its decentralized and transparent nature, is revolutionizing sectors like finance and supply chain management, fostering trust and accountability.However, as we decode the future with these emerging technologies, it’s crucial to address the challenges they pose. Issues like data privacy, ethical use of AI, and the digital divide need to be tackled to ensure these technologies benefit all of humanity. As we move forward, it’s essential to foster an environment of learning and adaptability, equipping individuals with the skills to navigate this technological revolution.
''';
  static const articleContent4 =
      '''The art of home cooking has evolved significantly with the advent of modern kitchen appliances. Tools like air fryers, instant pots, and smart ovens have revolutionized the way we prepare meals, making cooking more efficient and enjoyable. By exploring new recipes, experimenting with global cuisines, and using fresh, local ingredients, we can elevate our home cooking experience, turning everyday meals into gourmet delights.In addition to using modern appliances, elevating your home cooking experience also involves understanding the science behind cooking. Knowing how different ingredients interact, the impact of temperature on food, and the importance of timing can transform your cooking process. It’s not just about following recipes, but also about experimenting and discovering what works best for you.Furthermore, cooking at home also provides an opportunity to make healthier choices. You have control over the ingredients and can opt for organic, whole foods over processed ones. By incorporating a variety of foods and focusing on balanced meals, home cooking can contribute significantly to a healthier lifestyle.''';
  static const articleContent5 =
      '''Sustainable living is more than a trend; it’s a necessary shift towards preserving our planet for future generations. Embracing green steps can start with small changes in our daily routines, such as reducing waste, conserving water, and opting for renewable energy sources. By making conscious choices, like supporting local businesses and adopting a plant-based diet, we contribute to a sustainable future, proving that every step, no matter how small, counts towards making a big difference.Adopting a sustainable lifestyle also involves rethinking our consumption patterns. This includes opting for products with minimal packaging, choosing second-hand or recycled items, and reducing the use of single-use plastics. It’s about making choices that are not only good for us but also for the environment.Lastly, sustainable living extends to our communities as well. By participating in local clean-up drives, advocating for green policies, and educating others about sustainability, we can help foster a culture of environmental responsibility. After all, sustainable living is not just an individual effort, but a collective one, and every step we take towards it is a step towards a better future.''';
  static const articleContent6 = '''Music Is Life''';
}

//Article List Type

const String recent_article = 'recent_article';
const String your_article = 'your_article';
const bookmark_article = 'bookmark_article';
const String most_popular = 'most_popular';
const String explore_by_topics = 'explore_by_topics';
const String top_writers = 'top_writers';
const String recommendation = 'recommendation';
const String new_article = 'new_article';

//Article Category
class ArticleCategory {
  static const authEliza = 'Productivity';
  static const authStark = 'Technology';
  static const authElina = 'Food';
  static const authChris = 'Travel';
  static const authNolan = 'Nature';
  static const authEmma = 'Music';
  static const authGeorge = 'Economy';
  static const authChristina = 'Business';
  static const authStuart = 'Education';
  static const authMiller = 'Sports';
}

//User Comments

class UserComment {
  static const authElina =
      'I feel empowered to plan my next adventure without breaking the bank.😄';
  static const authNolan =
      'The insights have truly demystified the art of economical globetrotting for me.';
  static const authEliza =
      'This article is a treasure trove of practical tips and strategies for budget-conscious explorers.';
  static const authChris =
      'This article provides a comprehensive overview of time management strategies.';
  static const authStark =
      'The emphasis on avoiding multitasking and taking regular breaks is particularly insightful';
}

List<String> labels = [
  'Science & Technology',
  'Design',
  'Politics',
  'Health',
  'Economy',
  'Sports',
  'Music',
  'Art & Entertainment',
  'Music',
  'Lifestyle',
  'Education',
  'Social',
  'Cultural',
  'AI',
  'Energy',
  'Business',
  'Environment',
  '3D',
  'Crime',
  'Video',
  'Government',
  'Cosmic',
  'Nature',
  'Religious',
  'Astronomy',
  'Fashion',
  'Food & Beverage',
  'Travel',
  'Literature',
  'Philosophy',
  'Photography',
  'Psychology',
  'Theatre',
  'Virtual Reality',
  'Wildlife',
  'Yoga',
];

List<Map<String, dynamic>> contactUsData = [
  {'text': 'Contact Us', 'icon': Icons.headphones},
  {'text': 'Whatsapp', 'icon': Ionicons.logo_whatsapp},
  {'text': 'Instagram', 'icon': Ionicons.logo_instagram},
  {'text': 'Facebook', 'icon': Icons.facebook},
  {'text': 'Twitter', 'icon': Ionicons.logo_twitter},
  {'text': 'Website', 'icon': Icons.language},
];

List<Widget> contactUsWidgets = List.generate(
  contactUsData.length,
  (index) => ContactusWidget(
    text: contactUsData[index]['text'],
    icon: contactUsData[index]['icon'],
  ),
);

List<Map<String, dynamic>> aboutUsData = [
  {'text': 'Job Vacancy'},
  {'text': 'Developer'},
  {'text': 'Partner'},
  {'text': 'Accessibility'},
  {'text': 'Privacy Policy'},
  {'text': 'Feedback'},
  {'text': 'Rate Us'},
  {'text': 'Visit Our Website'},
  {'text': 'Follow us on Social Media'},
];

List<Widget> aboutUsWidgets = List.generate(
  contactUsData.length,
  (index) => ContactusWidget(
    text: aboutUsData[index]['text'],
  ),
);

//List  of FAQs

List<FaqTileWidget> faqTileWidgets = [
  FaqTileWidget(
      title: 'What is Scirbblr?',
      childrenText:
          'Scribblr is a article based app which is available globally for all users to connect.'),
  FaqTileWidget(
      title: 'Is the Scribblr app free?',
      childrenText: 'Yes, it is absolutely free.'),
  FaqTileWidget(
      title: 'How do I publish an article?',
      childrenText: 'Yes, it is absolutely free.'),
  FaqTileWidget(
      title: 'How do I logout from Scribblr?',
      childrenText: 'Yes, it is absolutely free.'),
];

class PrivacyPolicyrules {
  static const InformationCollection =
      "Adoptify collects user-provided information during account creation and adoption applications.";
  static const InformationUsage =
      "User data is used for adoption processes, notifications, and improving Adoptify services.";
  static const InformationSharing =
      "Limited information is shared with shelters during adoption applications.";
  static const SecurityMeasures =
      "Adoptify employs security measures to protect user data.";
  static const Cookies =
      "Adoptify uses cookies for a better user experience. Users can manage cookie preferences";
}

class TermsofServicerule {
  static const AcceptanceofTerms =
      "By using Adoptify, users accept and agree to these Terms of Service. ";
  static const Eligibility =
      "Users must be at least 18 years old or have parental consent to use Adoptify. ";
  static const UserAccounts =
      " Users are responsible for maintaining the confidentiality of their account information.";
  static const AdoptionProcess =
      " Adoption applications are subject to review and approval by shelters.";
  static const UserConduct =
      " Users agree not to engage in harmful activities, including unauthorized access or data manipulation.";
  static const IntellectualProperty =
      " Adoptify retains ownership of its intellectual property. ";
}

class AdoptionPolicy {
  static const HappyTailAnimalRescuse =
      "At Happy Tails Animal Rescue, our primary goal is to ensure the well-being and happiness of every pet in our care. Our adoption process is designed to match each animal with a loving and responsible forever home. Please review our adoption policy below:";
  static const AdoptionApplication =
      " Prospective adopters must complete a comprehensive adoption application. This helps us understand your lifestyle, preferences, and experience with pets to ensure a good match.The application includes questions about your living situation, other pets in the home, and your daily schedule";
  static const HomeVisit =
      "A home visit is required to ensure the environment is safe and suitable for the pet. This also provides an opportunity for us to discuss any specific needs the pet might have.Home visits help us verify that the pet will have adequate space, a secure environment, and that all family members are on board with the adoption.";
  static const MeetandGreet =
      "After the application is approved, a meet-and-greet session with the pet is scheduled. This allows both the adopter and the pet to interact and ensures compatibility.If you have other pets, we encourage bringing them along to the meet-and-greet to observe how they interact with the potential new family member.";
  static const AdoptionFee =
      "An adoption fee is required to cover the cost of vaccinations, spaying/neutering, microchipping, and other veterinary care the pet has received.The fee helps us continue our rescue efforts and care for more animals in need";
  static const TrialPeriod =
      "We offer a trial adoption period (usually two weeks) to ensure the pet is a good fit for your home. During this time, you can see how the pet adapts to your household.If, for any reason, the adoption does not work out during the trial period, you can return the pet, and we will assist in finding a better match.";
  static const PostAdoptionSupport =
      "Happy Tails Animal Rescue provides ongoing support and resources to ensure a smooth transition for both the pet and the adopter.We offer guidance on pet care, training, and addressing any behavioral issues that may arise.";
}

// ✅ Language List
final Map<String, String> languages = {
  'Afrikaans (Hallo, hoe gaan dit?)': 'af',
  'Albanian (Përshëndetje, si jeni?)': 'sq',
  'Arabic (مرحبًا، كيف حالك؟)': 'ar',
  'Armenian (Բարև, ինչպես ես?)': 'hy',
  'Bengali (হ্যালো, আপনি কেমন আছেন?)': 'bn',
  'Bulgarian (Здравей, как си?)': 'bg',
  'Catalan (Hola, com estàs?)': 'ca',
  'Chinese (Simplified) (你好，你好吗？)': 'zh-CN',
  'Chinese (Traditional) (你好，你好嗎？)': 'zh-TW',
  'Croatian (Bok, kako si?)': 'hr',
  'Czech (Ahoj, jak se máš?)': 'cs',
  'Danish (Hej, hvordan har du det?)': 'da',
  'Dutch (Hallo, hoe gaat het?)': 'nl',
  'English (Hello, how are you?)': 'en',
  'Estonian (Tere, kuidas läheb?)': 'et',
  'Filipino (Kumusta ka?)': 'tl',
  'Finnish (Hei, miten voit?)': 'fi',
  'French (Bonjour, comment ça va?)': 'fr',
  'German (Hallo, wie geht es dir?)': 'de',
  'Greek (Γεια σου, πώς είσαι?)': 'el',
  'Gujarati (હેલો, તમે કેમ છો?)': 'gu',
  'Hebrew (שלום, מה שלומך?)': 'he',
  'Hindi (नमस्ते, आप कैसे हैं?)': 'hi',
  'Hungarian (Helló, hogy vagy?)': 'hu',
  'Icelandic (Halló, hvernig hefurðu það?)': 'is',
  'Indonesian (Halo, bagaimana kabarmu?)': 'id',
  'Italian (Ciao, come stai?)': 'it',
  'Japanese (こんにちは、お元気ですか？)': 'ja',
  'Kannada (ಹಲೋ, ನೀವು ಹೇಗಿದ್ದೀರಾ?)': 'kn',
  'Korean (안녕하세요, 어떻게 지내세요?)': 'ko',
  'Latvian (Sveiki, kā jums klājas?)': 'lv',
  'Lithuanian (Sveiki, kaip laikotės?)': 'lt',
  'Malay (Hello, apa khabar?)': 'ms',
  'Malayalam (ഹലോ, നിങ്ങൾക്ക് സുഖമാണോ?)': 'ml',
  'Marathi (नमस्कार, तुम्ही कसे आहात?)': 'mr',
  'Norwegian (Hei, hvordan har du det?)': 'no',
  'Persian (سلام، حال شما چطور است؟)': 'fa',
  'Polish (Cześć, jak się masz?)': 'pl',
  'Portuguese (Olá, como você está?)': 'pt',
  'Punjabi (ਹੈਲੋ, ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?)': 'pa',
  'Romanian (Bună, cum ești?)': 'ro',
  'Russian (Привет, как ты?)': 'ru',
  'Serbian (Здраво, како си?)': 'sr',
  'Slovak (Ahoj, ako sa máš?)': 'sk',
  'Slovenian (Živjo, kako si?)': 'sl',
  'Spanish (Hola, ¿cómo estás?)': 'es',
  'Swahili (Habari, ukoje?)': 'sw',
  'Swedish (Hej, hur mår du?)': 'sv',
  'Tamil (வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?)': 'ta',
  'Telugu (హలో, మీరు ఎలా ఉన్నారు?)': 'te',
  'Thai (สวัสดี, คุณเป็นอย่างไรบ้าง?)': 'th',
  'Turkish (Merhaba, nasılsın?)': 'tr',
  'Ukrainian (Привіт, як справи?)': 'uk',
  'Urdu (ہیلو، آپ کیسے ہیں؟)': 'ur',
  'Vietnamese (Xin chào, bạn khỏe không?)': 'vi',
  'Welsh (Helo, sut wyt ti?)': 'cy',
};
