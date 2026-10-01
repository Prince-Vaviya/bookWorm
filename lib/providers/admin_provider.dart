import 'package:flutter/foundation.dart';
import '../models/admin_metrics.dart';
import '../models/book.dart';
import '../providers/library_provider.dart';

class AdminProvider extends ChangeNotifier {
  final Map<String, PublicationStatus> _bookPublicationStatuses = {};

  final List<ModerationReview> _moderationQueue = [
    ModerationReview(
      id: 'mod-1',
      bookId: 'book-1',
      bookTitle: 'Designing Data-Intensive Applications',
      reviewerName: 'Marcus Vance',
      reviewerEmail: 'marcus.v@example.com',
      rating: 5.0,
      comment:
          'Incredible chapter on distributed transactions and linearizability. Best tech book ever written.',
      submittedDate: '10 mins ago',
      status: ModerationStatus.pending,
    ),
    ModerationReview(
      id: 'mod-2',
      bookId: 'book-2',
      bookTitle: 'Meditations',
      reviewerName: 'Sophie Bennett',
      reviewerEmail: 'sophie.b@example.com',
      rating: 4.5,
      comment:
          'Clear translation, helps me cultivate inner peace before work every single morning.',
      submittedDate: '1 hour ago',
      status: ModerationStatus.pending,
    ),
    ModerationReview(
      id: 'mod-3',
      bookId: 'book-4',
      bookTitle: 'Thinking, Fast and Slow',
      reviewerName: 'David K.',
      reviewerEmail: 'david.k@spamlink.org',
      rating: 1.0,
      comment:
          'Visit freebookdownloads.click for free coupon codes and pirated pdf copies now!',
      submittedDate: '3 hours ago',
      status: ModerationStatus.flagged,
      flagReason: 'Automated Spam / Promotional Link Detected',
    ),
  ];

  final List<AdminUserRecord> _usersDirectory = [
    AdminUserRecord(
      id: 'usr-1',
      name: 'Rajneesh',
      email: 'rajneesh@bookworm.app',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida/AEtjO1U3lH30DCsHONA62BPFpjqz_q4AcW8vj0wVGB8oL5vQf8l1yX-2EQh2OBbn9UrAffvTV5BURf-aMlOdyTdmNhXUp0y427UUaWf--NljvZ8dxNpGQKjnV-KRiO8Vqpo70mTYnRKPpmMQOlwVfdf2IJD07ywpsa-K220psyrZzkSSadOohzr1PD4VtOeKVOfL3H1G974-S93HgsBYSW-76GfIrCRUqw0KrEDCjSq3qu9zcdwM8Gav1IAW26sw',
      role: UserRole.admin,
      joinedDate: 'Jan 2024',
      booksRead: 42,
      reviewsCount: 18,
      status: UserAccountStatus.active,
    ),
    AdminUserRecord(
      id: 'usr-2',
      name: 'Elena Rostova',
      email: 'elena.rostova@literature.edu',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
      role: UserRole.curator,
      joinedDate: 'Mar 2024',
      booksRead: 29,
      reviewsCount: 14,
      status: UserAccountStatus.active,
    ),
    AdminUserRecord(
      id: 'usr-3',
      name: 'Michael Chang',
      email: 'm.chang@techdigest.io',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop',
      role: UserRole.reader,
      joinedDate: 'Jun 2024',
      booksRead: 11,
      reviewsCount: 5,
      status: UserAccountStatus.active,
    ),
    AdminUserRecord(
      id: 'usr-4',
      name: 'Amina Al-Sayed',
      email: 'amina.reads@sanctuary.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=300&auto=format&fit=crop',
      role: UserRole.curator,
      joinedDate: 'Aug 2024',
      booksRead: 35,
      reviewsCount: 22,
      status: UserAccountStatus.active,
    ),
  ];

  final List<AdminActivityLog> _activityLogs = [
    AdminActivityLog(
      id: 'act-1',
      title: 'New Book Published',
      description:
          '"Designing Data-Intensive Applications" catalog version updated.',
      timestamp: '15m ago',
      iconType: 'book',
    ),
    AdminActivityLog(
      id: 'act-2',
      title: 'Review Approved',
      description: 'Review by Alex Rivera published to "Meditations".',
      timestamp: '1h ago',
      iconType: 'review',
    ),
    AdminActivityLog(
      id: 'act-3',
      title: 'Role Promoted',
      description: 'Elena Rostova promoted to Curator.',
      timestamp: '3h ago',
      iconType: 'user',
    ),
  ];

  // Getters
  List<ModerationReview> get moderationQueue => _moderationQueue;
  List<AdminUserRecord> get usersDirectory => _usersDirectory;
  List<AdminActivityLog> get activityLogs => _activityLogs;

  int get pendingReviewsCount => _moderationQueue
      .where((r) => r.status == ModerationStatus.pending)
      .length;
  int get flaggedReviewsCount => _moderationQueue
      .where((r) => r.status == ModerationStatus.flagged)
      .length;

  PublicationStatus getBookPublicationStatus(String bookId) {
    return _bookPublicationStatuses[bookId] ?? PublicationStatus.published;
  }

  void setBookPublicationStatus(String bookId, PublicationStatus status) {
    _bookPublicationStatuses[bookId] = status;
    notifyListeners();
  }

  void approveReview(String reviewId, LibraryProvider library) {
    final index = _moderationQueue.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final modReview = _moderationQueue[index];
      modReview.status = ModerationStatus.approved;

      // Sync approved review to the actual Book in LibraryProvider
      final book = library.getBookById(modReview.bookId);
      if (book != null) {
        book.reviews.insert(
          0,
          Review(
            id: modReview.id,
            reviewerName: modReview.reviewerName,
            rating: modReview.rating,
            date: 'Just now',
            comment: modReview.comment,
            likesCount: 0,
          ),
        );
      }

      _activityLogs.insert(
        0,
        AdminActivityLog(
          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Review Approved',
          description:
              'Review by ${modReview.reviewerName} approved for "${modReview.bookTitle}".',
          timestamp: 'Just now',
          iconType: 'review',
        ),
      );
      notifyListeners();
    }
  }

  void rejectReview(String reviewId) {
    final index = _moderationQueue.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _moderationQueue[index].status = ModerationStatus.rejected;
      notifyListeners();
    }
  }

  void toggleUserStatus(String userId) {
    final index = _usersDirectory.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final current = _usersDirectory[index].status;
      _usersDirectory[index].status = current == UserAccountStatus.active
          ? UserAccountStatus.suspended
          : UserAccountStatus.active;
      notifyListeners();
    }
  }

  void updateUserRole(String userId, UserRole role) {
    final index = _usersDirectory.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _usersDirectory[index].role = role;
      notifyListeners();
    }
  }

  void recordNewBookAdded(String title) {
    _activityLogs.insert(
      0,
      AdminActivityLog(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Title Added',
        description: '"$title" added to catalog.',
        timestamp: 'Just now',
        iconType: 'book',
      ),
    );
    notifyListeners();
  }
}
