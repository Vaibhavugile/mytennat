// lib/screens/ad_page.dart
import 'package:flutter/material.dart';

class AdPage extends StatelessWidget {
  const AdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertisements', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Our Sponsors',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Ad Banner 1
              _buildAdBanner(
                'Ad 1: Exclusive Deals!',
                'https://via.placeholder.com/600x250/FF0000/FFFFFF?text=Ad+1+-+Exclusive+Deals',
                'https://www.example.com/ad1', // Replace with actual ad link
              ),
              const SizedBox(height: 24),
              // Ad Banner 2
              _buildAdBanner(
                'Ad 2: Find Your Dream Flat!',
                'https://via.placeholder.com/600x250/00FF00/000000?text=Ad+2+-+Dream+Flat',
                'https://www.example.com/ad2', // Replace with actual ad link
              ),
              const SizedBox(height: 24),
              // Ad Banner 3
              _buildAdBanner(
                'Ad 3: Premium Features!',
                'https://via.placeholder.com/600x250/0000FF/FFFFFF?text=Ad+3+-+Premium+Features',
                'https://www.example.com/ad3', // Replace with actual ad link
              ),
              const SizedBox(height: 24),
              // Ad Banner 4 (example of a smaller ad or different style)
              _buildAdBanner(
                'Ad 4: Rent Furniture!',
                'https://via.placeholder.com/400x150/FFA500/FFFFFF?text=Ad+4+-+Rent+Furniture',
                'https://www.example.com/ad4', // Replace with actual ad link
              ),
              const SizedBox(height: 24),
              // You can add more ad banners here
              const Text(
                'Interested in advertising with us? Contact us at ads@mytennant.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner(String title, String imageUrl, String adLink) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Open the ad link when tapped
          // In a real app, you'd use url_launcher package:
          // import 'package:url_launcher/url_launcher.dart';
          // launchUrl(Uri.parse(adLink));
          print('Navigating to ad: $adLink');
          // For now, just print to console
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 200, // Adjust height as needed
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            // You could add a small description or call to action here
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //   child: Text(
            //     'Click to learn more!',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}