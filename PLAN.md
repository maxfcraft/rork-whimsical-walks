# Whimsical Walks — Onboarding & Paywall Flow

## Overview

A cinematic, story-driven onboarding that takes users on a journey from "remember what it was like to play?" to "this app brings that magic back through walking" — ending with a hard paywall offering a 3-day free trial. aswell as talks about why adventuring is good

---

## Onboarding Screens (6 screens → Paywall)

### Screen 1 — "Remember When…"

- Full-screen dreamy mesh gradient background (your existing whimsical pink/lavender palette)
- Animated sparkles gently floating
- Large whimsical text fades in: **"Remember when the world felt magical?"**
- Smaller text below: *"When every puddle was an ocean and every walk was an adventure"*
- Inspired by the Sam Wong article: play as the most mature form of wellness
- Tap or swipe to continue — soft page indicator dots at bottom

### Screen 2 — "Walking Is Medicine"

- Beautiful animated step counter ring (similar to your home screen ring) that fills up as the screen appears
- **Bold stat**: "Walking boosts creative thinking by 60%" (from your existing walking facts)
- Second stat fades in: "Just 4,400 steps/day significantly improves health"
- Third: "Higher daily steps = fewer symptoms of depression"
- Each stat animates in with a gentle spring, accompanied by a small sparkle
- Tone: science-backed but warm and approachable

### Screen 3 — "Your Walks, Reimagined"

- Animated showcase of the 3 core features, each sliding in one at a time:
  - 🎨 **Whimsical Polaroids** — "Turn your walks into magical memories with fantasy filters"
  - 🗺️ **Daily Quests** — "Fun photo adventures that make every walk an expedition"  
  - 🐾 **Collect Companions** — "Earn adorable pets as you explore"
- Each feature card has a mini preview animation (polaroid tilt, quest card flip, pet bounce)
- Your existing deep rose / lavender / sage color coding for each feature

### Screen 4 — "Make It Yours"

- Ask for their **name** (text field with whimsical styling)
- Ask for their **daily step goal** with a playful picker (3,000 / 5,000 / 7,500 / 10,000 / custom)
- Warm copy: "We'll tailor your adventure just for you"
- Name gets stored and used throughout the app (greeting on home screen)

### Screen 5 — App Store Review Request

- Cheerful screen: "Enjoying the vibes so far? ✨"
- Triggers the native App Store review prompt
- This is placed strategically before the paywall — users who rate are more invested
- Auto-advances after a moment whether they rate or not

### Screen 6 — The Paywall 💰

- **Hard paywall** — no skip button, must start free trial or subscribe
- **Hero section**: Beautiful mesh gradient background with sparkles, your app name "Whimsical Walks" in the signature font
- **Value recap** (3 quick bullet points with icons):
  - ✨ Magical photo filters on every walk
  - 🗺️ Fresh daily quests & adventures  
  - 🐾 Adorable pets that grow with you
- **Pricing cards**:
  - **Monthly** — e.g. $4.99/month (positioned as the "regular" option)
  - **Yearly** — e.g. $29.99/year with a "Save 50%" badge and per-month breakdown ("just $2.49/mo") — this is pre-selected and highlighted with a subtle glow
- **Call-to-action button**: "Start Your 3-Day Free Trial" in deep rose, full-width, with a gentle pulse animation
- Small reassuring text below: "Cancel anytime. No charge for 3 days."
- Legal fine print at the very bottom (subscription terms)

---

## Design & Feel

- Every screen uses the existing whimsical mesh gradient backgrounds with sparkles
- Page transitions are smooth swipes with spring physics
- Text uses your existing serif + whimsical font combination
- Progress dots at the bottom show where you are in the flow
- The whole flow feels like opening a storybook — each page reveals more magic
- Haptic feedback on transitions and interactions 

## RevenueCat Integration

- Connect RevenueCat for subscription management
- Set up two products: Monthly and Yearly
- 3-day free trial attached to both options
- Handle purchase success → dismiss paywall →  then the app intro/ starting and loading screen loads - show the app
- Handle restore purchases for returning users
- Store subscription status so the paywall only shows for non-subscribers

## App Flow Change

- First launch → Splash → Onboarding → Paywall → App intro plays then app
- Returning subscriber → Splash → App (skip onboarding entirely)
- Expired subscriber → App opens to Paywall again

## App Icon

- No change to the existing app icon

