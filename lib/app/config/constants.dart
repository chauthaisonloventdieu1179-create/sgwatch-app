class Endpoints {
  Endpoints._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';
  static const String sendOtp = '/password/otp/send';
  static const String verifyOtp = '/password/otp/verify';
  static const String resetPassword = '/password/reset';
  static const String verifyRegistration = '/verify-registration';
  static const String userInfo = '/user-info';

  // User / Profile
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String changePassword = '/change-password';
  static const String userPoint = '/user-point';
  static const String toggleNotification = '/toggle-notification';

  // Products / Catalog
  static const String products = '/products';
  static const String shopProducts = '/shop/products';
  static const String featuredProducts = '/shop/featured-products';
  static const String productDetail = '/shop/products';
  static const String shopBrands = '/shop/brands';
  static const String categories = '/categories';
  static const String brands = '/brands';
  static const String searchProducts = '/products/search';

  // Favorites
  static const String favorites = '/shop/favorites';
  static const String favoritesToggle = '/shop/favorites/toggle';

  // Address
  static const String addresses = '/addresses';
  static const String prefectures = '/prefectures';

  // Cart
  static const String cart = '/shop/cart';
  static const String addToCart = '/shop/cart/items';
  static const String updateCart = '/shop/cart/update';
  static const String removeFromCart = '/shop/cart/remove';

  // Orders
  static const String orders = '/shop/orders';
  static const String checkout = '/shop/orders/checkout';
  static const String cancelOrder = '/shop/orders/{id}/cancel';
  static const String paymentReceipt = '/shop/orders/{id}/payment-receipt';
  static const String orderInvoice = '/shop/orders/{id}/invoice';

  // Chat
  static const String chatHistory = '/chat/history/list';
  static const String chatSendMessage = '/chat/message';
  static const String chatMarkAsRead = '/chat/messages/mark-as-read';

  // Notifications
  static const String notices = '/shop/notices';

  // Reviews
  static const String reviews = '/shop/reviews';
  static const String productReviews = '/shop/products'; // /{id}/reviews

  // Big Sale
  static const String bigSale = '/big-sales';

  // Discount
  static const String discountCodes = '/discount-codes';

  // FCM
  static const String fcmToken = '/fcm_token';
  static const String withdraw = '/withdraw';

  // Collections
  static const String collections = '/shop/collections';

  // Misc
  static const String banners = '/banners';
  static const String posts = '/posts';
  static const String settings = '/settings';
}

class AppConstants {
  AppConstants._();

  static const String appName = 'SGWatch';
  static const String currency = 'VND';
  static const String locale = 'vi_VN';

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;

  // Assets
  static const String logoSplash = 'assets/logo/logo_splash.png';
}
