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
            });
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
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(ApiConfig.oauthLogin));
  }

  void _checkForAuthCallback(String url) async {
    if (_loginCompleted) return;
    
    // After successful OAuth, the backend redirects to the base URL
    // We detect this and check if the user is now authenticated
    if (url.startsWith(ApiConfig.baseUrl) && 
        !url.contains('/api/oauth/callback') &&
        !url.contains('app-auth')) {
      
      _loginCompleted = true;
      
      // Try to get the session cookie using JavaScript
      try {
        final cookieString = await _controller.runJavaScriptReturningResult(
          'document.cookie'
        );
        
        // Parse the cookie string to find app_session_id
        String? sessionCookie;
        final cookieStr = cookieString.toString().replaceAll('"', '');
        final cookies = cookieStr.split(';');
        
        for (final cookie in cookies) {
          final trimmed = cookie.trim();
          if (trimmed.startsWith('app_session_id=')) {
            sessionCookie = trimmed.substring('app_session_id='.length);
            break;
          }
        }
        
        if (sessionCookie != null && sessionCookie.isNotEmpty) {
          // Store the session cookie in our API service
          final authService = AuthService();
          await authService.setSessionFromCookie(sessionCookie);
          
          // Check authentication status
          final isAuthenticated = await authService.checkAuth();
          
          if (mounted) {
            if (isAuthenticated) {
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
          // No session cookie found via JavaScript, try checking auth anyway
          // The cookie might be httpOnly
          final authService = AuthService();
          final isAuthenticated = await authService.checkAuth();
          
          if (mounted) {
            if (isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully signed in!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            } else {
              // Cookie is httpOnly, inform user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login completed. Please check your connection.'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.of(context).pop(false);
            }
          }
        }
      } catch (e) {
        debugPrint('Error getting cookies: $e');
        if (mounted) {
          Navigator.of(context).pop(false);
        }
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
