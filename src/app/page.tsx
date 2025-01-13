'use client';
import React from 'react';
import Link from 'next/link';

export default function Home() {
  const supportCategories = [
    {
      title: "For Homeowners",
      items: [
        "Finding and booking electricians",
        "Managing appointments and payments",
        "Rating and reviewing services",
        "Emergency service requests",
        "Account settings and preferences"
      ]
    },
    {
      title: "For Electricians",
      items: [
        "Profile setup and verification",
        "Managing service availability",
        "Handling job requests",
        "Payment processing",
        "Professional guidelines"
      ]
    }
  ];

  const contactMethods = [
    {
      title: "Support",
      email: "support@electriconnect.com",
      description: "For general inquiries and assistance",
      response: "Response within 24 hours"
    },
    {
      title: "Business Inquiries",
      email: "business@electriconnect.com",
      description: "For partnerships and business opportunities",
      response: "Response within 48 hours"
    }
  ];

  return (
    <main className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-blue-600 text-white">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-blue-700"></div>
        <div className="relative container mx-auto px-6 py-24">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">How can we help?</h1>
          <p className="text-xl text-blue-100 max-w-2xl">
            Find answers to common questions and get support for ElectriConnect.
          </p>
        </div>
      </section>

      {/* Support Categories */}
      <section className="py-20">
        <div className="container mx-auto px-6">
          <div className="max-w-4xl mx-auto space-y-16">
            {supportCategories.map((category, idx) => (
              <div key={idx}>
                <h2 className="text-2xl font-semibold mb-6 text-gray-800">{category.title}</h2>
                <div className="bg-white rounded-xl shadow-sm p-8">
                  <ul className="space-y-4">
                    {category.items.map((item, itemIdx) => (
                      <li key={itemIdx} className="flex items-start">
                        <span className="inline-block w-2 h-2 rounded-full bg-blue-600 mt-2 mr-3"></span>
                        <span className="text-gray-600">{item}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            ))}

            {/* Contact Section */}
            <div>
              <h2 className="text-2xl font-semibold mb-6 text-gray-800">Contact Us</h2>
              <div className="grid md:grid-cols-2 gap-6">
                {contactMethods.map((method, idx) => (
                  <div key={idx} className="bg-white rounded-xl shadow-sm p-8">
                    <h3 className="text-xl font-semibold mb-4 text-gray-800">{method.title}</h3>
                    <p className="text-gray-600 mb-4">{method.description}</p>
                    <div className="space-y-2">
                      <p className="text-gray-800">
                        Email: <a href={`mailto:${method.email}`} className="text-blue-600 hover:text-blue-700">{method.email}</a>
                      </p>
                      <p className="text-gray-600">{method.response}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* App Download */}
            <div>
              <h2 className="text-2xl font-semibold mb-6 text-gray-800">Get the App</h2>
              <div className="bg-white rounded-xl shadow-sm p-8">
                <p className="text-gray-600 mb-6">
                  Download ElectriConnect to connect with qualified electricians or manage your electrical service business.
                </p>
                <div className="flex flex-wrap gap-4">
                  <a href="#" className="inline-block bg-black text-white px-6 py-3 rounded-lg hover:bg-gray-800 transition-colors">
                    Download on the App Store
                  </a>
                  <a href="#" className="inline-block bg-black text-white px-6 py-3 rounded-lg hover:bg-gray-800 transition-colors">
                    Get it on Google Play
                  </a>
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
              <Link href="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
              <Link href="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
            </div>
            <p className="text-sm">© 2024 ElectriConnect. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  );
} 