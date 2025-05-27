# 🚨 RESCUE: Real-Time Emergency Victim-Agent Coordination App

**RESCUE** is a mobile app that connects people in distress with nearby volunteers (agents) in real time. Unlike centralized emergency services, RESCUE enables **common citizens**—who voluntarily register as agents—to provide immediate, localized assistance during emergencies. Built using Flutter and Node.js, the app focuses on hyperlocal response, speed, and secure communication.

## 🧩 Key Features

- 📍 **Live Victim-Agent Tracking**  
  Real-time location sharing using Google Maps API for efficient coordination.

- 🛡️ **Geo-Fenced Alerts**  
  Only agents within a 10km radius receive emergency alerts—enabling faster, localized response.

- 👥 **Common Citizen Agents**  
  Any user can register as an agent through a secure OTP system via EmailJS—no government credentials required.

- 🔐 **OTP-Based Agent Verification**  
  Ensures only verified individuals act as agents, adding a layer of security and trust.

- 💬 **In-App Chat & Call**  
  Victims can communicate directly with agents through secure messaging and call features.

- ☁️ **Robust Backend**  
  Powered by Node.js, Express.js, and MongoDB Atlas, deployed on Render.

- 🔄 **No Authentication Overhead**  
  The app is kept lightweight with no login/authentication needed for victims—ensuring speed during emergencies.

## 🆚 Comparison: RESCUE vs 112 India App

| Feature                         | RESCUE App                                                | 112 India App                      |
|---------------------------------|------------------------------------------------------------|------------------------------------|
| Volunteer-Based Response        | ✅ Yes — common citizens as agents                         | ❌ No                              |
| In-App Chat & Call              | ✅ Yes                                                     | ❌ No                              |
| Geo-Fencing                     | ✅ Yes — 10km radius targeting nearby agents               | ❌ No                              |
| OTP-Based Agent Registration    | ✅ Yes (via EmailJS)                                       | ❌ No                              |
| Real-Time Location              | ✅ Google Maps integration                                 | ✅ Yes                             |
| Custom Community Deployments    | ✅ For campuses, societies, private communities            | ❌ Government-controlled only      |

## 🖼️ App Screenshots

<p align="center">
  <img src="screenshots/home.png" width="200">
  <img src="screenshots/emergency.png" width="200">
  <img src="screenshots/map.png" width="200">
  <img src="screenshots/chat.png" width="200">
</p>

## 🚀 How It Works

1. A **victim** taps the emergency button in the app.
2. The app **locates agents** (volunteers) within a 10km radius.
3. A nearby **agent accepts** the rescue request.
4. Victim and agent can **chat or call** within the app.
5. Rescue mission is tracked and completed in real time.

## 💻 Tech Stack

- **Frontend:** Flutter, Dart
- **Backend:** Node.js, Express.js, MongoDB Atlas
- **APIs:** Google Maps API, EmailJS (OTP)
- **Deployment:** Render

## 📌 Unique Position

While services like **112 India** focus on central dispatch from government bodies, **RESCUE empowers local communities** by enabling **trained and verified common citizens** to take action in real time.

## 💸 Funding Requirements

To bring RESCUE to scale, we are seeking support for:
- ✅ Further AI-based accuracy improvements
- ✅ Security enhancements & stress testing
- ✅ Play Store and App Store deployment
- ✅ Awareness campaigns and onboarding of more community agents

## 🧠 Future Roadmap

- Smartwatch-triggered SOS
- Incident analytics dashboard for admins
- Volunteer ratings and trust scores
- Voice-command-based alert system
---

> 🛠️ **RESCUE is built for communities, by communities.** Help us scale life-saving tech, one citizen at a time.
