# Project Setup Guide

## 1. Firebase Setup
- Copy `android/app/google-services.example.json` to `android/app/google-services.json`
- Copy `ios/Runner/GoogleService-Info.example.plist` to `ios/Runner/GoogleService-Info.plist`
- Update with your Firebase project details

## 2. Environment Variables
- Copy `.env.example` to `.env`
- Fill in your actual API keys and secrets

## 3. Android Keystore
- Place your `keystore.jks` in `android/app/`
- Copy `android/key.properties.example` to `android/key.properties`
- Update with your actual passwords

## 4. Install Dependencies
```bash
flutter pub get