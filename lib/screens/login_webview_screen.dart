import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';

/// WebView-based login screen for Manus OAuth authentication
class LoginWebViewScreen extends StatefulWidget {
  const LoginWebViewScreen({super.key});

  @override
  State<LoginWebViewScreen> createState() => _LoginWebViewScreenState();
}

class _LoginWebViewScreenState extends State<LoginWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';
  bool _loginCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1a1a2e))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
            _checkForAuthCallback(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkForAuthCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(ApiConfig.oauthLogin));
  }

  void _checkForAuthCallback(String url) async {
    // Check if we've been redirected to the callback URL or the main page after auth
    if (_loginCompleted) return;
    
    // After successful OAuth, the backend redirects to the base URL
    // We detect this and check if the user is now authenticated
    if (url.startsWith(ApiConfig.baseUrl) && 
        !url.contains('/api/oauth/callback') &&
        !url.contains('app-auth')) {
      
      _loginCompleted = true;
      
      // Get cookies from WebView and try to authenticate
      final authService = AuthService();
      
      // Extract cookies from WebView
      final cookieManager = WebViewCookieManager();
      final cookies = await cookieManager.getCookies(ApiConfig.baseUrl);
      
      // Find the session cookie
      String? sessionCookie;
      for (final cookie in cookies) {
        if (cookie.name == 'app_session_id') {
          sessionCookie = cookie.value;
          break;
        }
      }
      
      if (sessionCookie != null) {
        // Store the session cookie in our API service
        await authService.setSessionFromCookie(sessionCookie);
        
        // Check authentication status
        final isAuthenticated = await authService.checkAuth();
        
        if (mounted) {
          if (isAuthenticated) {
            // Success! Close the WebView and return to the app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully signed in!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop(false);
          }
        }
      } else {
        // No session cookie found, might need to wait or retry
        debugPrint('No session cookie found yet');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF1a1a2e).withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF00D9FF),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
