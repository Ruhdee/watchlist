# Watchlist: Minimalist Movie Watchlist App

Watchlist is a minimalist movie watchlist app designed and built using **Flutter**. The app allows users to search, track, and organize movies they want to watch, leveraging data from [The Movie Database (TMDb)](https://www.themoviedb.org/).

## Features

- 💡 **Minimalist UI:** Clean and distraction-free interface for managing watchlists.
- 🔍 **Search:** Find movies and add them to your personal watchlist.
- 📋 **Persistent Storage:** Your watchlist is stored locally and persists between sessions.
- 🌙 **Dark Theme:** Optimized for low-light and AMOLED devices.
- ⚡ **Performance:** Fast, efficient caching and optimized image loading.


## Getting Started

To run Watchlist on your own device, follow these steps:

### 1. Clone the Repository

git clone https://github.com/your-username/watchlist.git
cd watchlist


### 2. Install Dependencies

Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed.

Then run:

flutter pub get


### 3. Set Up API Credentials

This app uses TMDb API, and requires a Bearer Access Token.

- Find the `.env.example` file in the project root
- Rename it to `.env`


- Obtain your Bearer Access Token from [TMDb API](https://developer.themoviedb.org/reference/authentication-guide)
- Open `.env` and update the following line (replace `<<Your_Bearer_Access_Token>>`):

TMDB_BEARER_TOKEN=<<Your_Bearer_Access_Token>>



### 4. Run the App

flutter run


You can run it on Android, iOS, or any supported Flutter platform.

## Development Notes

- The app is built in Flutter and uses `.env` for secret management ([flutter_dotenv](https://pub.dev/packages/flutter_dotenv) recommended).
- API requests require a valid TMDb Bearer Token; the app will not work without proper authentication.
- All API credentials must be kept secret—never commit your `.env` file to a public repo.

## Contribution

Please open Issues and Pull Requests for bugs, features, or improvements.

---

**Minimalist Movie Watchlist App**  
Powered by Flutter & TMDb