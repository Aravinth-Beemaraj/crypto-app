# Crypto Market App

A Flutter-based cryptocurrency market and research application built using the Binance REST API and WebSocket.

## About

This application provides real-time cryptocurrency market information with coin search, filtering, sorting, interactive price charts, market statistics, and a persistent watchlist.

The app uses the Binance REST API for market and historical data and Binance WebSocket for real-time price updates.

The project focuses on a clean, responsive, user-friendly experience with reusable widgets, centralized theme management, proper state handling, and clear feedback messages.

## Features

- Live cryptocurrency market data
- Search, filter and sort coins
- Interactive price charts
- Real-time price updates using WebSocket
- Add/remove coins from Watchlist
- Market statistics
- Light and Dark theme support
- System-based theme detection and automatic theme switching
- Persistent Watchlist using SharedPreferences
- Reusable and modular UI widgets
- Centralized colors and theme configuration
- User-friendly SnackBar and feedback messages
- Loading, error and empty states
- Proper API error handling
- Responsive and clean UI
- Smooth navigation and user interactions

## User Experience

- Supports both Light and Dark themes
- Automatically follows the device system theme when configured
- Provides clear and user-friendly SnackBar messages for actions and errors
- Displays loading indicators while fetching data
- Provides meaningful error and empty states
- Uses reusable UI components to maintain consistent design
- Provides responsive layouts for different screen sizes
- Preserves Watchlist data locally between app sessions

## Tech Stack

- Flutter & Dart
- Provider – State Management
- Binance REST API – Market and historical data
- Binance WebSocket – Real-time price updates
- fl_chart – Interactive price charts
- SharedPreferences – Local watchlist persistence

## Binance APIs Used

- `exchangeInfo` – Available trading pairs
- `ticker/24hr` – Price, 24h change, high, low and volume
- `klines` – Historical price data for charts
- WebSocket `@ticker` – Real-time price updates

## Architecture

```text
UI
 ↓
Provider
 ↓
Repository
 ↓
Services
 ↓
Binance REST API / WebSocket