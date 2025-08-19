# PH Power Tracker ⚡

> Real-time, crowdsourced power supply tracking for Port Harcourt City.

PH Power Tracker is a mobile application built with Flutter that allows users to check and report the real-time power (electricity) status across different areas of Port Harcourt, Nigeria. The app relies on a community of users to provide live updates, creating a dynamic and accurate map of the city's power situation.

## Screenshots

<table style="width:100%; border: none;">
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/BrightFK/ph_power/main/screenshots/Screenshot_20250819_042746.png" width="200" alt="Login Screen"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/BrightFK/ph_power/main/screenshots/Screenshot_20250819_042828.png" width="200" alt="Map View"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/BrightFK/ph_power/main/screenshots/Screenshot_20250819_042903.png" width="200" alt="Area List View"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/BrightFK/ph_power/main/screenshots/Screenshot_20250819_042958.png" width="200" alt="Profile Screen"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/BrightFK/ph_power/main/screenshots/Screenshot_20250819_043109.png" width="200" alt="Profile Screen"></td>
  </tr>
  <tr style="text-align:center;">
    <td>Live Map</td>
    <td>Report Screen</td>
    <td>Area List View</td>
    <td>Login Screen</td>
    <td>User Profile</td>
  </tr>
</table>

## Features

-   **Live Power Map:** View a real-time map of Port Harcourt with color-coded pins indicating the power status of different areas.
-   **Crowdsourced Reporting:** Easily report whether you have power ("I Have Light") or not ("No Light"). The app uses your current location to determine the area.
-   **Real-time Updates:** The map and area list update instantly for all users when a new report is made, thanks to a live connection with the backend.
-   **List View:** See a comprehensive list of all tracked areas, their current status, and when they were last updated.
-   **Map Controls:** A convenient toolbar allows you to zoom in/out, find your current location on the map, and reset the map's orientation to face North.
-   **User Authentication:** Secure sign-up and login for users to participate in the community reporting.
-   **Data Efficient:** Designed to use minimal mobile data, with map tiles cached after the first view.

## How It Works

The app's accuracy is based on the "wisdom of the crowd." Since the local power distribution company does not provide a public API, this app uses a crowdsourcing model:

1.  A user in an area reports the current power status.
2.  The report is sent to the Supabase backend, updating the status for that specific area.
3.  Supabase's Realtime feature instantly pushes this update to all other users.
4.  The map and lists on everyone's device update immediately, reflecting the most recent report.

The system is self-correcting—the more active users there are in an area, the more accurate and up-to-date the information becomes.

## Tech Stack

-   **Frontend:** [Flutter](https://flutter.dev/) - For building a cross-platform, high-performance mobile app from a single codebase.
-   **Backend & Database:** [Supabase](https://supabase.com/) - An open-source Firebase alternative. We use:
    -   **PostgreSQL Database:** For storing user and area data.
    -   **Supabase Auth:** For user authentication.
    -   **Realtime Subscriptions:** For live updates on the map.
-   **Mapping:**
    -   [OpenStreetMap](https://www.openstreetmap.org/) - The free, community-driven map data.
    -   [flutter_map](https://pub.dev/packages/flutter_map) - The Flutter package used to render map tiles.
-   **Location Services:** [geolocator](https://pub.dev/packages/geolocator) - To get the user's current GPS coordinates for reporting.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK installed.
-   A Supabase account.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/BrightFK/ph_power.git
    ```
2.  **Install Flutter packages**
    ```sh
    flutter pub get
    ```
3.  **Set up Supabase credentials**
    -   Create a new project on [Supabase](https://supabase.com).
    -   Run the setup SQL script found in the project (or use the one in `README_SETUP.md`) to create the necessary tables (`areas`, `reports`).
    -   In `lib/main.dart`, replace the placeholder values with your actual Supabase URL and Anon Key:
        ```dart
        await Supabase.initialize(
          url: 'YOUR_SUPABASE_URL',
          anonKey: 'YOUR_SUPABASE_ANON_KEY',
        );
        ```
4.  **Run the app**
    ```sh
    flutter run
    ```

## License

Distributed under the MIT License. See `LICENSE` for more information.
