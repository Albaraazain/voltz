'use client';
import React from 'react';
import Link from 'next/link';

export default function Terms() {
  const sections = [
    {
      title: "Platform Overview",
      content: [
        "ElectriConnect is a platform connecting homeowners with qualified electricians",
        "We verify electrician credentials and facilitate service bookings",
        "We do not provide electrical services directly",
        "Users must be 18 years or older to use the platform",
        "Users are responsible for maintaining account security"
      ]
    },
    {
      title: "User Responsibilities",
      content: [
        "Provide accurate and complete information",
        "Maintain professional conduct and communication",
        "Respect intellectual property rights",
        "Report any suspicious or inappropriate behavior",
        "Comply with all applicable laws and regulations"
      ]
    },
    {
      title: "Service Terms",
      content: [
        "Booking confirmations are binding agreements",
        "Cancellation policies apply to all bookings",
        "Service quality standards must be maintained",
        "Payment processing through secure channels only",
        "Communication must be through the platform"
      ]
    },
    {
      title: "Platform Rules",
      content: [
        "No unauthorized commercial activities",
        "No harassment or discriminatory behavior",
        "No sharing of personal contact information",
        "No circumvention of platform fees",
        "No false reviews or feedback"
      ]
    }
  ];

  return (
    <main className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-blue-600 text-white">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-blue-700"></div>
        <div className="relative container mx-auto px-6 py-24">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">Terms of Service</h1>
          <p className="text-xl text-blue-100 max-w-2xl">
            Please read these terms carefully before using ElectriConnect.
          </p>
          <p className="text-blue-200 mt-4">Last updated: January 2024</p>
        </div>
      </section>

      {/* Content Sections */}
      <section className="py-20">
        <div className="container mx-auto px-6">
          <div className="max-w-4xl mx-auto space-y-16">
            {sections.map((section, idx) => (
              <div key={idx}>
                <h2 className="text-2xl font-semibold mb-6 text-gray-800">{section.title}</h2>
                <div className="bg-white rounded-xl shadow-sm p-8">
                  <ul className="space-y-4">
                    {section.content.map((item, itemIdx) => (
                      <li key={itemIdx} className="flex items-start">
                        <span className="inline-block w-2 h-2 rounded-full bg-blue-600 mt-2 mr-3"></span>
                        <span className="text-gray-600">{item}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            ))}

            {/* Legal Notice */}
            <div>
              <h2 className="text-2xl font-semibold mb-6 text-gray-800">Legal Notice</h2>
              <div className="bg-white rounded-xl shadow-sm p-8">
                <p className="text-gray-600 mb-4">
                  By using ElectriConnect, you agree to these terms. We reserve the right to modify these terms at any time.
                  Significant changes will be notified through the platform or via email.
                </p>
                <div className="space-y-2">
                  <p className="text-gray-800">
                    For legal inquiries: <a href="mailto:legal@electriconnect.com" className="text-blue-600 hover:text-blue-700">legal@electriconnect.com</a>
                  </p>
                  <p className="text-gray-800">
                    Business Hours: Monday to Friday, 9 AM - 5 PM EST
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-12">
        <div className="container mx-auto px-6">
          <div className="max-w-4xl mx-auto text-center">
            <div className="flex justify-center space-x-8 mb-8">
              <Link href="/" className="hover:text-white transition-colors">Support Home</Link>
              <Link href="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
            </div>
            <p className="text-sm">© 2024 ElectriConnect. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  );
} 