# Crypto Market App

A Flutter-based cryptocurrency market and research app built using the Binance REST API and WebSocket.

## Features

- 1. Live cryptocurrency market data
- 2. Search, filter and sort coins
- 3. Interactive price charts
- 4. Real-time price updates using WebSocket
- 5. Add/remove coins from Watchlist
- 6. Market statistics
- 7. Light and Dark theme support
- 8. Persistent Watchlist using SharedPreferences
- 9. Loading, error and empty states

## Tech Stack

- Flutter & Dart
- Provider – State Management
- Binance REST API – Market data and historical prices
- Binance WebSocket – Real-time price updates
- fl_chart – Price charts
- SharedPreferences – Watchlist persistence

## API Used

- exchangeInfo – Available trading pairs
- ticker/24hr – Price, 24h change, high, low and volume
- klines – Historical price data for charts
- WebSocket `@ticker` – Live price updates

## App Screenshots

App Screenshots are available in [`lib/screenshots`](lib/screenshots).

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