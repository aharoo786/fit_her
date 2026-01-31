# Google Analytics Setup Guide

This guide explains how to use Google Analytics in your Flutter fitness app.

## Setup Completed

✅ Firebase Analytics dependency added to `pubspec.yaml`
✅ Analytics service created (`lib/data/services/analytics_service.dart`)
✅ Analytics helper created (`lib/helper/analytics_helper.dart`)
✅ Dependency injection configured
✅ Firebase initialization updated

## How to Use Analytics

### 🔹 User Acquisition & Onboarding

#### 1. Track App Open
```dart
// Automatically tracked in main.dart
// Or manually:
await AnalyticsHelper.trackAppOpen();
```

#### 2. Track Sign Up
```dart
await AnalyticsHelper.trackSignUp('email'); // or 'google', 'apple'
```

#### 3. Track Login
```dart
await AnalyticsHelper.trackLogin('email'); // or 'google', 'apple'
```

#### 4. Track Tutorial Completion
```dart
await AnalyticsHelper.trackTutorialComplete(tutorialName: 'onboarding_tutorial');
```

### 🔹 Engagement / Browsing

#### 5. Track Screen Views
```dart
@override
void initState() {
  super.initState();
  AnalyticsHelper.trackScreenView('workout_screen');
}
```

#### 6. Track Scroll Activity
```dart
// When user scrolls through content
await AnalyticsHelper.trackScrollActivity(
  'classes_screen',
  contentType: 'classes',
  scrollDepth: 50, // percentage scrolled
);
```

#### 7. Track Search
```dart
// When user searches
await AnalyticsHelper.trackSearch(
  'yoga',
  searchCategory: 'workouts',
  resultsCount: 15,
);
```

#### 8. Track Class View
```dart
// When user opens a class page
await AnalyticsHelper.trackClassView(
  'Morning Yoga',
  classType: 'live',
  instructorName: 'Sarah Johnson',
);
```

### 🔹 Subscription & Payment Funnel

#### 9. Track Subscribe Click
```dart
await AnalyticsHelper.trackSubscribeClick(screenName: 'home_screen');
```

#### 10. Track Plan Selection
```dart
await AnalyticsHelper.trackPlanSelected(
  'Premium',
  planPrice: '29.99',
  planDuration: 'monthly',
);
```

#### 11. Track Checkout Begin
```dart
await AnalyticsHelper.trackBeginCheckout(
  'Premium',
  planPrice: '29.99',
  currency: 'USD',
);
```

#### 12. Track Payment Info Added
```dart
await AnalyticsHelper.trackAddPaymentInfo(
  'card',
  planName: 'Premium',
);
```

#### 13. Track Successful Purchase
```dart
await AnalyticsHelper.trackPurchase(
  'Premium',
  '29.99',
  currency: 'USD',
  transactionId: 'txn_123456',
);
```

#### 14. Track Failed Purchase
```dart
await AnalyticsHelper.trackPurchaseFailed(
  'Premium',
  planPrice: '29.99',
  errorReason: 'insufficient_funds',
  paymentType: 'card',
);
```

### 🔹 Classes & Sessions

#### 15. Track Class Booking
```dart
await AnalyticsHelper.trackClassBooked(
  'Morning Yoga',
  classType: 'live',
  instructorName: 'Sarah Johnson',
  classTime: '09:00',
  classDate: '2024-01-15',
);
```

#### 16. Track Class Attendance
```dart
await AnalyticsHelper.trackClassAttended(
  'Morning Yoga',
  classType: 'live',
  instructorName: 'Sarah Johnson',
  duration: 60, // minutes attended
);
```

#### 17. Track Missed Class
```dart
await AnalyticsHelper.trackClassMissed(
  'Morning Yoga',
  classType: 'live',
  instructorName: 'Sarah Johnson',
  reason: 'forgot', // 'forgot', 'sick', 'busy', 'technical_issue'
);
```

#### 18. Track Session Feedback
```dart
await AnalyticsHelper.trackSessionFeedback(
  'Morning Yoga',
  5, // rating 1-5
  feedback: 'Great session!',
  instructorName: 'Sarah Johnson',
);
```

### 🔹 Retention / Drop-off

#### 19. Track Daily Active User
```dart
await AnalyticsHelper.trackDailyActiveUser();
```

#### 20. Track Weekly Active User
```dart
await AnalyticsHelper.trackWeeklyActiveUser();
```

#### 21. Track Churn Event
```dart
await AnalyticsHelper.trackChurnEvent(
  7, // days inactive
  lastActivity: 'login',
);
```

### 🔹 Other Events

#### 22. Track Button Clicks
```dart
await AnalyticsHelper.trackButtonClick(
  'continue_button',
  screenName: 'login_screen',
);
```

#### 23. Track Workout Events
```dart
await AnalyticsHelper.trackWorkoutEvent(
  'started',
  workoutType: 'cardio',
  duration: 1800, // seconds
);
```

#### 24. Track Diet Events
```dart
await AnalyticsHelper.trackDietEvent(
  'meal_logged',
  mealType: 'breakfast',
  foodItem: 'oatmeal',
);
```

#### 25. Track Freeze Events
```dart
await AnalyticsHelper.trackFreezeEvent('freeze_requested');
```

#### 26. Track Errors
```dart
try {
  // Your code
} catch (e) {
  await AnalyticsHelper.trackError(
    'api_error',
    errorMessage: e.toString(),
    screenName: 'login_screen',
  );
}
```

#### 27. Set User Properties
```dart
await AnalyticsHelper.setUserId(userId);
await AnalyticsHelper.setUserProperty('user_type', 'premium');
await AnalyticsHelper.setUserProperty('subscription_status', 'active');
```

## Integration Examples

### Login Screen Integration

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.trackScreenView('login_screen');
  }

  void _handleLogin() async {
    try {
      await AnalyticsHelper.trackButtonClick('login_button', screenName: 'login_screen');
      await AnalyticsHelper.trackLogin('email');
      
      // Your login logic
      authController.login();
    } catch (e) {
      await AnalyticsHelper.trackError('login_failed', errorMessage: e.toString());
    }
  }
}
```

### Tutorial Integration

```dart
// In your tutorial service
Future<bool> showSubscribeTutorial(BuildContext context) async {
  await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'started');
  
  // Show tutorial dialog
  bool result = await _showTutorialDialog(context, ...);
  
  if (result) {
    await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'completed');
  } else {
    await AnalyticsHelper.trackTutorialEvent('subscribe_tutorial', 'skipped');
  }
  
  return result;
}
```

## Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`fither-e7a36`)
3. Go to Analytics section
4. You'll see events being tracked in real-time

## Key Events to Track

### User Journey
- Screen views
- Login/Signup methods
- Button clicks
- Navigation patterns

### Business Metrics
- Subscription conversions
- Tutorial completion rates
- Feature usage
- User engagement

### Error Tracking
- API failures
- App crashes
- User-reported issues

## Best Practices

1. **Consistent Naming**: Use consistent event names across your app
2. **Meaningful Parameters**: Include relevant data with events
3. **User Privacy**: Don't track sensitive personal information
4. **Performance**: Don't block UI with analytics calls
5. **Testing**: Test analytics in development mode

## Debugging

To debug analytics in development:

```dart
// Enable debug mode
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
```

Check Firebase Console for real-time events during development.

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Test analytics events in development
3. Monitor Firebase Console for data
4. Set up custom dashboards in Google Analytics
5. Configure conversion goals for key user actions
