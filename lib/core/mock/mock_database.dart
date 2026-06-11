import '../common_imports.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _initData();
  }

  // Active user session state
  UserModel? currentUser;
  bool isDarkTheme = false;

  // Order Settings
  bool isCombineOption = true;
  String orderStartTime = "09:00";
  String orderCutoffTime = "17:00";

  bool isOrderingOpen() {
    try {
      final now = DateTime.now();
      final startParts = orderStartTime.split(':');
      final cutoffParts = orderCutoffTime.split(':');
      if (startParts.length < 2 || cutoffParts.length < 2) return true;
      
      final startHour = int.parse(startParts[0]);
      final startMin = int.parse(startParts[1]);
      final cutoffHour = int.parse(cutoffParts[0]);
      final cutoffMin = int.parse(cutoffParts[1]);
      
      final startTime = DateTime(now.year, now.month, now.day, startHour, startMin);
      final cutoffTime = DateTime(now.year, now.month, now.day, cutoffHour, cutoffMin);
      
      return now.isAfter(startTime) && now.isBefore(cutoffTime);
    } catch (e) {
      return true;
    }
  }

  // Repositories
  final List<UserModel> users = [];
  final List<SnackModel> snacks = [];
  final List<OrderModel> orders = [];
  final List<NotificationModel> notifications = [];

  void _initData() {
    // 1. Initial Users
    users.addAll([
      UserModel(
        uid: 'emp-101',
        name: 'Romil Shah',
        email: 'employee@snackify.com',
        employeeId: 'EMP-9842',
        department: 'Product Design',
        phone: '+1 555-0199',
        role: 'employee',
        profileImage:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      UserModel(
        uid: 'adm-202',
        name: 'Sara K.',
        email: 'admin@snackify.com',
        employeeId: 'ADM-0042',
        department: 'Operations',
        phone: '+1 555-0144',
        role: 'admin',
        profileImage:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      UserModel(
        uid: 'emp-102',
        name: 'Alex Rivera',
        email: 'alex@snackify.com',
        employeeId: 'EMP-1102',
        department: 'Engineering',
        phone: '+1 555-0177',
        role: 'employee',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        uid: 'emp-103',
        name: 'Michael Chen',
        email: 'michael@snackify.com',
        employeeId: 'EMP-1103',
        department: 'Marketing',
        phone: '+1 555-0188',
        role: 'employee',
        profileImage:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
        isActive: false, // Inactive employee demonstration
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ]);

    // 2. Initial Snacks
    snacks.addAll([
      // Tea
      SnackModel(
        id: 'snack-1',
        name: 'Masala Chai',
        description:
            'Brewed black tea with a mixture of aromatic Indian spices and herbs. Rich, creamy, and refreshing.',
        category: 'Tea',
        price: 1.50,
        imageUrl:
            'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        rating: 4.8,
        ingredients: const ['Black Tea', 'Milk', 'Cardamom', 'Ginger', 'Sugar'],
        galleryImages: const [
          'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?auto=format&fit=crop&q=80&w=400',
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&q=80&w=400',
        ],
      ),
      SnackModel(
        id: 'snack-2',
        name: 'Earl Grey Tea',
        description:
            'Premium black tea flavored with the addition of oil of bergamot. Elegant floral aroma.',
        category: 'Tea',
        price: 1.75,
        imageUrl:
            'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        rating: 4.3,
        ingredients: const ['Earl Grey Leaves', 'Water', 'Lemon slice'],
        galleryImages: const [],
      ),
      // Coffee
      SnackModel(
        id: 'snack-3',
        name: 'Vanilla Latte',
        description:
            'Espresso combined with steamed milk and a touch of sweet vanilla syrup. Smooth, frothy finish.',
        category: 'Coffee',
        price: 3.50,
        imageUrl:
            'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        rating: 4.9,
        ingredients: const [
          'Espresso',
          'Steamed Milk',
          'Vanilla Syrup',
          'Foam',
        ],
        galleryImages: const [
          'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&q=80&w=400',
          'https://images.unsplash.com/photo-1570968915860-54d5c301fc9f?auto=format&fit=crop&q=80&w=400',
        ],
      ),
      SnackModel(
        id: 'snack-4',
        name: 'Iced Americano',
        description:
            'Bold espresso shots topped with cold water and ice. A strong, cooling pick-me-up.',
        category: 'Coffee',
        price: 2.75,
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        rating: 4.6,
        ingredients: const ['Espresso', 'Cold Water', 'Ice'],
        galleryImages: const [],
      ),
      // Snacks
      SnackModel(
        id: 'snack-5',
        name: 'Salted Pretzels',
        description:
            'Baked to golden brown perfection, sprinkled with coarse sea salt. Crunchy and satisfying.',
        category: 'Snacks',
        price: 2.20,
        imageUrl:
            'https://images.unsplash.com/photo-1578496482173-95c52c21966a?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        rating: 4.2,
        ingredients: const ['Wheat Flour', 'Coarse Salt', 'Yeast'],
        galleryImages: const [],
      ),
      SnackModel(
        id: 'snack-6',
        name: 'Guacamole & Chips',
        description:
            'Freshly smashed avocados with lime, cilantro, and onions served with crispy corn tortilla chips.',
        category: 'Snacks',
        price: 4.50,
        imageUrl:
            'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        rating: 4.7,
        ingredients: const [
          'Avocados',
          'Tortilla Chips',
          'Lime Juice',
          'Cilantro',
          'Salt',
        ],
        galleryImages: const [
          'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&q=80&w=400',
        ],
      ),
      // Sandwiches
      SnackModel(
        id: 'snack-7',
        name: 'Club Sandwich',
        description:
            'Triple-decker toasted bread filled with grilled chicken, turkey bacon, lettuce, tomatoes, and dynamic house mayo.',
        category: 'Sandwiches',
        price: 5.95,
        imageUrl:
            'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        rating: 4.8,
        ingredients: const [
          'Toasted Bread',
          'Grilled Chicken',
          'Lettuce',
          'Tomatoes',
          'House Mayo',
        ],
        galleryImages: const [],
      ),
      SnackModel(
        id: 'snack-8',
        name: 'Caprese Panini',
        description:
            'Fresh mozzarella, tomatoes, and basil pesto grilled between crusty sourdough bread. Elegant and hot.',
        category: 'Sandwiches',
        price: 5.50,
        imageUrl:
            'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?auto=format&fit=crop&q=80&w=400',
        available: false, // Out of stock example
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        rating: 4.4,
        ingredients: const [
          'Sourdough',
          'Mozzarella Cheese',
          'Tomatoes',
          'Basil Pesto',
        ],
        galleryImages: const [],
      ),
      // Beverages
      SnackModel(
        id: 'snack-9',
        name: 'Fresh Orange Juice',
        description:
            '100% freshly squeezed sweet valencia oranges. Cold-pressed, no added sugar.',
        category: 'Beverages',
        price: 3.00,
        imageUrl:
            'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
        rating: 4.9,
        ingredients: const ['Fresh Oranges', 'Ice'],
        galleryImages: const [],
      ),
      // Desserts
      SnackModel(
        id: 'snack-10',
        name: 'Chocolate Brownie',
        description:
            'Decadent, fudge-like double chocolate chip brownie served warm. Top-tier luxury.',
        category: 'Desserts',
        price: 3.25,
        imageUrl:
            'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        rating: 4.9,
        ingredients: const [
          'Fudge Chocolate',
          'Cocoa Powder',
          'Flour',
          'Butter',
          'Sugar',
        ],
        galleryImages: const [
          'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&q=80&w=400',
        ],
      ),
      SnackModel(
        id: 'snack-11',
        name: 'Matcha Green Tea Latte',
        description:
            'Ceremonial grade matcha whisked with silky steamed milk and sweetened with vanilla syrup.',
        category: 'Tea',
        price: 3.20,
        imageUrl:
            'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        rating: 4.8,
        ingredients: const ['Matcha Powder', 'Steamed Milk', 'Vanilla Syrup'],
        galleryImages: const [],
      ),
      SnackModel(
        id: 'snack-12',
        name: 'Caramel Cold Brew',
        description:
            'Slow-steeped cold brew coffee topped with a splash of sweet cream and a drizzle of rich caramel.',
        category: 'Coffee',
        price: 3.95,
        imageUrl:
            'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4.9,
        ingredients: const ['Cold Brew Coffee', 'Sweet Cream', 'Caramel Syrup'],
        galleryImages: const [],
      ),
      SnackModel(
        id: 'snack-13',
        name: 'Warm Blueberry Muffin',
        description:
            'Freshly baked muffin bursting with real blueberries, finished with a golden sugar streusel crust.',
        category: 'Desserts',
        price: 2.50,
        imageUrl:
            'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        rating: 4.6,
        ingredients: const ['Blueberries', 'Flour', 'Butter', 'Sugar Streusel'],
        galleryImages: const [],
      ),
      SnackModel(
        id: 'snack-14',
        name: 'Smashed Avocado Toast',
        description:
            'Toasted artisanal sourdough topped with fresh seasoned avocado smash, red pepper flakes, and microgreens.',
        category: 'Sandwiches',
        price: 4.80,
        imageUrl:
            'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?auto=format&fit=crop&q=80&w=400',
        available: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 4.7,
        ingredients: const [
          'Sourdough Toast',
          'Avocado',
          'Red Pepper Flakes',
          'Microgreens',
        ],
        galleryImages: const [],
      ),
    ]);

    // 3. Initial Orders
    orders.addAll([
      OrderModel(
        id: 'ord-1001',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[0], quantity: 2), // Masala Chai
          CartItem(snack: snacks[4], quantity: 1), // Pretzels
        ],
        totalAmount: 5.20,
        status: 'completed',
        orderDate: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        approvedBy: 'Sara K.',
        remarks: 'Extra hot tea request.',
      ),
      OrderModel(
        id: 'ord-1002',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[2], quantity: 1), // Vanilla Latte
          CartItem(snack: snacks[9], quantity: 1), // Chocolate Brownie
        ],
        totalAmount: 6.75,
        status: 'pending',
        orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
        approvedBy: '',
        remarks: 'No sugar in latte.',
      ),
      OrderModel(
        id: 'ord-1003',
        employeeId: 'emp-102',
        employeeName: 'Alex Rivera',
        items: [
          CartItem(snack: snacks[6], quantity: 1), // Club Sandwich
          CartItem(snack: snacks[8], quantity: 1), // Orange juice
        ],
        totalAmount: 8.95,
        status: 'preparing',
        orderDate: DateTime.now().subtract(const Duration(minutes: 40)),
        approvedBy: 'Sara K.',
        remarks: '',
      ),
      OrderModel(
        id: 'ord-1004',
        employeeId: 'emp-102',
        employeeName: 'Alex Rivera',
        items: [
          CartItem(snack: snacks[2], quantity: 2), // Vanilla Latte
        ],
        totalAmount: 7.00,
        status: 'ready',
        orderDate: DateTime.now().subtract(const Duration(minutes: 25)),
        approvedBy: 'Sara K.',
        remarks: '',
      ),
      OrderModel(
        id: 'ord-1005',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[7], quantity: 1), // Caprese Panini
          CartItem(snack: snacks[8], quantity: 1), // Fresh Orange Juice
        ],
        totalAmount: 8.50,
        status: 'rejected',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        approvedBy: 'Sara K.',
        remarks: 'Sorry, Caprese sourdough is out of stock today.',
      ),
      OrderModel(
        id: 'ord-1006',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[2], quantity: 1), // Vanilla Latte
          CartItem(snack: snacks[9], quantity: 1), // Chocolate Brownie
        ],
        totalAmount: 6.75,
        status: 'completed',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        approvedBy: 'Sara K.',
        remarks: '',
      ),
      OrderModel(
        id: 'ord-1007',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[3], quantity: 2), // Iced Americano
          CartItem(snack: snacks[5], quantity: 1), // Guacamole & Chips
        ],
        totalAmount: 10.00,
        status: 'ready',
        orderDate: DateTime.now().subtract(const Duration(minutes: 5)),
        approvedBy: 'Sara K.',
        remarks: 'Extra ice please.',
      ),
      OrderModel(
        id: 'ord-1008',
        employeeId: 'emp-101',
        employeeName: 'Romil Shah',
        items: [
          CartItem(snack: snacks[0], quantity: 1), // Masala Chai
          CartItem(snack: snacks[6], quantity: 1), // Club Sandwich
        ],
        totalAmount: 7.45,
        status: 'preparing',
        orderDate: DateTime.now().subtract(const Duration(minutes: 10)),
        approvedBy: 'Sara K.',
        remarks: 'Extra hot tea.',
      ),
    ]);

    // 4. Initial Notifications
    notifications.addAll([
      NotificationModel(
        id: 'notif-1',
        userId: 'emp-101',
        title: 'Order Approved!',
        message:
            'Your order ord-1001 for Masala Chai has been approved by Admin.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      ),
      NotificationModel(
        id: 'notif-2',
        userId: 'emp-101',
        title: 'New Snack Alert!',
        message:
            'Guacamole & Chips is now available in the snack catalog! Try it now.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: 'notif-3',
        userId: 'emp-102',
        title: 'Order Ready for Pickup!',
        message:
            'Your Vanilla Latte is ready. Please collect it from the pantry.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: 'notif-4',
        userId: 'emp-101',
        title: 'Order Rejected ❌',
        message:
            'Your order ord-1005 has been rejected: Sorry, Caprese sourdough is out of stock today.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif-5',
        userId: 'emp-101',
        title: 'Order Ready for Pickup! 🎉',
        message:
            'Your order ord-1007 is ready. Please collect it from the pantry counter.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ]);
  }
}
