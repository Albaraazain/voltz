'use client';
import React from 'react';
import Link from 'next/link';

export default function Privacy() {
  const sections = [
    {
      title: "Information We Collect",
      content: [
        "Personal information (name, email, phone number)",
        "Professional credentials for electricians",
        "Location data for service coordination",
        "Payment information for transactions",
        "Usage data and app interactions"
      ]
    },
    {
      title: "How We Use Your Data",
      content: [
        "Facilitate service bookings and payments",
        "Verify electrician credentials",
        "Improve our platform and services",
        "Send important updates and notifications",
        "Ensure platform safety and security"
      ]
    },
    {
      title: "Data Protection",
      content: [
        "Industry-standard encryption for all data",
        "Secure payment processing systems",
        "Regular security audits and updates",
        "Limited employee access to personal data",
        "Automated threat detection and prevention"
      ]
    },
    {
      title: "Your Privacy Rights",
      content: [
        "Access your personal information",
        "Request data correction or deletion",
        "Opt-out of marketing communications",
        "Export your data in portable format",
        "Lodge privacy-related complaints"
      ]
    }
  ];

  return (
    <main className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-blue-600 text-white">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-blue-700"></div>
        <div className="relative container mx-auto px-6 py-24">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">Privacy Policy</h1>
          <p className="text-xl text-blue-100 max-w-2xl">
            We are committed to protecting your privacy and personal information.
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

            {/* Contact Information */}
            <div>
              <h2 className="text-2xl font-semibold mb-6 text-gray-800">Contact Us</h2>
              <div className="bg-white rounded-xl shadow-sm p-8">
                <p className="text-gray-600 mb-4">
                  If you have any questions about our privacy practices or would like to exercise your privacy rights,
                  please contact our Privacy Team:
                </p>
                <div className="space-y-2">
                  <p className="text-gray-800">
                    Email: <a href="mailto:privacy@electriconnect.com" className="text-blue-600 hover:text-blue-700">privacy@electriconnect.com</a>
                  </p>
                  <p className="text-gray-800">
                    Response Time: Within 48 hours
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
              <Link href="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
            </div>
            <p className="text-sm">© 2024 ElectriConnect. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  );
} 