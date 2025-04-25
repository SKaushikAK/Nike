import 'package:flutter/material.dart';

void main() => runApp(MyPortfolioApp());

class MyPortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/about':
            return _createRoute(AboutPage());
          case '/projects':
            return _createRoute(ProjectPage());
          case '/contact':
            return _createRoute(ContactPage());
          case '/blog':
            return _createRoute(BlogPage());
          default:
            return null;
        }
      },
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class HomePage extends StatelessWidget {
  Widget _navButton(BuildContext context, String label, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Portfolio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navButton(context, 'About Me', '/about'),
            _navButton(context, 'Projects', '/projects'),
            _navButton(context, 'Contact', '/contact'),
            _navButton(context, 'Blog', '/blog'),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _basicPage(context, 'About Me',
        'I am a Flutter developer passionate about building UI.');
  }
}

class ProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _basicPage(context, 'Projects',
        'Here are some cool projects I built using Flutter.');
  }
}

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _basicPage(
        context, 'Contact', 'Email me at flutter.dev@example.com');
  }
}

class BlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _basicPage(
        context, 'Blog', 'Welcome to my tech blog about mobile development.');
  }
}

// Shared layout for all pages
Widget _basicPage(BuildContext context, String title, String content) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(content, style: TextStyle(fontSize: 18))),
  );
}
