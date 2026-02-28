import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverReviewsScreen extends StatefulWidget {
  const DriverReviewsScreen({super.key});

  @override
  State<DriverReviewsScreen> createState() => _DriverReviewsScreenState();
}

class _DriverReviewsScreenState extends State<DriverReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final driverId = AuthService.currentUserId;

    if (driverId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view reviews')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Reviews & Ratings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

            // Rating Summary
            _buildRatingSummary(driverId),
            SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

            // Reviews List
            Text(
              'Customer Reviews',
              style: ResponsiveTextStyles.getTitleStyle(context),
            ),
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

            _buildReviewsList(driverId),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(String driverId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserService.getDriverRatingStats(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error loading ratings: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        final averageRating = stats['averageRating'] ?? 0.0;
        final totalReviews = stats['totalReviews'] ?? 0;
        final ratingBreakdown =
            stats['ratingBreakdown'] as Map<int, int>? ?? {};

        return Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Mycolors.orange, Mycolors.orange.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Overall Rating
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.white,
                              size: 24,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalReviews reviews',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating Breakdown',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(5, (index) {
                          final rating = 5 - index;
                          final count = ratingBreakdown[rating] ?? 0;
                          final percentage = totalReviews > 0
                              ? (count / totalReviews)
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  '$rating',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.star, color: Colors.white, size: 12),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percentage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsList(String driverId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserService.getDriverFeedbackStream(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error loading reviews: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer reviews will appear here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewCard(review);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final reviewText = review['review'] ?? review['comment'] ?? '';
    final userName = review['userName'] ?? 'Anonymous';
    final userDetails = review['userDetails'] as Map<String, dynamic>?;
    final actualUserName = userDetails?['name'] ?? userName;
    final createdAt = review['createdAt'];

    String formattedDate = 'Recently';
    try {
      if (createdAt != null) {
        final Timestamp timestamp = createdAt;
        final DateTime dateTime = timestamp.toDate();
        formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      formattedDate = 'Recently';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  actualUserName.isNotEmpty ? actualUserName[0] : 'A',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actualUserName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Mycolors.orange,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Review text
          if (reviewText.isNotEmpty)
            Text(
              reviewText,
              style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
            ),
        ],
      ),
    );
  }
}
