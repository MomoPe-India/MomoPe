# Merchant App - Phase 2 Enhancements

**Status**: Ready for implementation  
**Date**: February 17, 2026

---

## Overview

With core merchant features complete, Phase 2 focuses on **analytics, productivity tools, and merchant experience improvements** to make the app indispensable for daily business operations.

---

## Priority Enhancements

### 🎯 Option A: Analytics Dashboard (Highest Impact)

**What**: Add comprehensive revenue analytics with interactive charts

**Features**:
- **Revenue Chart**: 7-day/30-day line chart with trend analysis
- **Performance Metrics**: Week-over-week growth, peak hours
- **Category Breakdown**: Revenue by payment method (cash vs coins)
- **Customer Insights**: Repeat customers, average basket size
- **Export Reports**: Download weekly/monthly summaries as PDF

**Technical**:
- Use `fl_chart` package (already in dependencies)
- New screen: `AnalyticsScreen` with tabs (Overview, Revenue, Customers)
- New RPC: `get_merchant_analytics(period)` for aggregated data
- Chart types: Line (revenue trend), Bar (hourly distribution), Pie (payment mix)

**Effort**: ~3-4 hours  
**Value**: ⭐⭐⭐⭐⭐ (Critical for business insights)

---

### 📱 Option B: QR Code Enhancements

**What**: Make QR code more shareable and professional

**Features**:
- **Download QR**: Save as image to gallery
- **Share QR**: Share via WhatsApp/Email with business details
- **Print Format**: Generate printable QR with merchant branding
- **Dynamic QR**: Include promo codes or special offers
- **QR Analytics**: Track scans (requires backend enhancement)

**Technical**:
- Add `share_plus` to pubspec (removed earlier)
- Use `image_gallery_saver` for downloads
- Create printable template with merchant logo/name
- Optional: QR scan tracking table

**Effort**: ~2 hours  
**Value**: ⭐⭐⭐⭐ (Helps merchant acquisition)

---

### 🔍 Option C: Smart Search & Export

**What**: Advanced transaction search and data export

**Features**:
- **Search Bar**: Search by amount, date range, customer ID
- **Advanced Filters**: Multiple status, date range picker, amount range
- **Bulk Actions**: Select transactions for export
- **CSV Export**: Download transaction history
- **Receipt Generation**: Generate PDF receipts for customers

**Technical**:
- Add search TextField with debouncing
- Date range picker widget
- CSV generation from transaction list
- PDF generation using `pdf` package

**Effort**: ~2-3 hours  
**Value**: ⭐⭐⭐⭐ (Improves merchant workflow)

---

### ⚙️ Option D: Profile Management Suite

**What**: Allow merchants to manage their business details

**Features**:
- **Edit Business Info**: Update name, address, category
- **Update Banking**: Change bank account details (with verification)
- **Commission History**: View rate changes over time
- **Support Tickets**: In-app support system
- **Document Upload**: Upload GSTIN/PAN documents

**Technical**:
- Create edit screens for business and banking
- Form validation with proper security
- File upload to Supabase storage
- Admin approval workflow for sensitive changes

**Effort**: ~3-4 hours  
**Value**: ⭐⭐⭐ (Nice to have, not urgent)

---

### 🔔 Option E: Real-time Notifications

**What**: Notify merchants of important events

**Features**:
- **Transaction Alerts**: New payment received (push notification)
- **Settlement Reminders**: Upcoming payout notifications
- **Low Activity**: Nudge if no sales in 24 hours
- **Promotional**: Platform announcements
- **In-App Inbox**: View notification history

**Technical**:
- Firebase Cloud Messaging (FCM) integration
- Supabase triggers to send notifications
- Local notifications for foreground
- Notification preferences screen

**Effort**: ~4-5 hours  
**Value**: ⭐⭐⭐⭐ (Keeps merchants engaged)

---

## Recommended Implementation Order

### Week 1: Analytics Foundation
1. ✅ **Analytics Dashboard** - Most requested by merchants
2. 📱 **QR Enhancements** - Quick win, high visibility

### Week 2: Productivity Tools  
3. 🔍 **Search & Export** - Improves daily operations
4. 🔔 **Notifications** - Boosts engagement

### Week 3: Polish & Expansion
5. ⚙️ **Profile Management** - Reduces support burden
6. 📊 **Advanced Reports** - Monthly/yearly summaries

---

## Quick Wins (Can do now)

### 1. Dashboard Chart Enhancement (~30 mins)
Add a simple 7-day revenue bar chart to existing dashboard using `fl_chart`.

### 2. Settlement Schedule Details (~20 mins)
Show detailed T+3 calculation with actual payout date on Settlement screen.

### 3. Transaction Detail Share (~15 mins)
Add "Share Receipt" button on transaction detail (text-based, no PDF yet).

### 4. Empty State Improvements (~30 mins)
Better empty states with actionable suggestions (e.g., "Share your QR to get started").

---

## Decision Time

**Which option should we start with?**

1. **Option A**: Analytics Dashboard (recommended - highest merchant value)
2. **Option B**: QR Enhancements (quick, visible improvement)
3. **Option C**: Search & Export (practical, daily use)
4. **Something else**: Let me know your priority!

I'm ready to start immediately with whichever you choose. My recommendation is **Option A (Analytics)** since merchants constantly ask "How's my business doing?" and this directly answers that.
