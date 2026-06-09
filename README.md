# Nicky's Hiking Pal

A free, private-by-default hiking journal, planner, route map, and progress dashboard. It is responsive, installable, dependency-light, and designed to work well on phones and desktops.

## Live use

This is a static app. Open `index.html`, use GitHub Pages, or serve the folder:

```powershell
python -m http.server 4173
```

Then visit `http://localhost:4173`.

## Working features

- Responsive dashboard with weekly, monthly, yearly, and lifetime summaries
- Goal progress for distance, elevation, hike count, bucket-list completions, and monthly miles
- Motivating Everest, Rainier, building-height, and marathon comparisons
- Personal records, favorites, recent hikes, upcoming plans, and bucket-list progress
- Add, edit, view, favorite, duplicate, and delete completed hikes
- Add, complete, checklist, print, and delete planned hikes
- Add and delete bucket-list hikes with season, priority, logistics, and status
- Structured fields for weather, conditions, crowds, parking, permits, cell service, dogs, water, wildlife, gear, companions, safety, links, tags, and reflection
- Multiple local photo previews per hike
- GPX and KML route import, route display, and GPX export
- Interactive Leaflet map with OpenStreetMap and OpenTopoMap layers
- Completed, planned, and bucket-list markers plus imported route lines
- Search, difficulty/tag filters, and date/distance/elevation/rating sorting
- JSON backup/restore and CSV history export
- Excel (`.xlsx`/`.xls`) and CSV history import with automatic header matching, a reviewable mapping screen, and row preview
- Current local weather with temperature, apparent temperature, wind, precipitation chance, sunrise/sunset, and trail-oriented guidance
- Personalized time-aware greeting for Robert
- Exact-location hiding, local-only storage, and no public sharing
- Leave No Trace reminders and printable hike plans
- Installable/offline-capable PWA shell
- Accessible labels, keyboard controls, semantic landmarks, and non-color status labels

## Data ownership and privacy

Hikes, photos, routes, settings, and goals stay in the browser's `localStorage`. Exact trailheads can be offset on the map. Nothing is uploaded or shared by this app. Use **Export my data** regularly because clearing browser data will remove the local journal.

**Restore app backup** reads a JSON file previously created by **Export my data**. It replaces the hikes, plans, goals, and settings currently stored in that browser. It is for moving or recovering the complete app state, while **Import spreadsheet** is specifically for converting an existing Excel/CSV hiking history into completed hikes.

Photo capacity depends on the browser's local storage quota. A production cloud version should move photos to IndexedDB or user-controlled object storage.

## Mapping and data sources

The app uses [Leaflet](https://leafletjs.com/) with [OpenStreetMap](https://www.openstreetmap.org/) and [OpenTopoMap](https://opentopomap.org/) tiles. It does not scrape, copy, or depend on AllTrails data. Trail information comes from demo data, manual entry, user files, or optional reference links.

No API keys are required. A future live-weather adapter should use an environment variable and a provider that permits the intended use.

Current weather uses the no-key [Open-Meteo Forecast API](https://open-meteo.com/en/docs). It defaults to the Seattle area until Robert chooses **Use my location**; the chosen coordinates remain only in local app settings. Mountain weather can differ sharply from trailhead conditions, so the dashboard explicitly encourages checking official mountain forecasts.

## Spreadsheet import

Choose **Import spreadsheet**, select the workbook, and review the automatic column matches before importing. The importer supports common variations such as `Hike Name`, `Trail`, `Date Completed`, `Miles`, `Elevation Gain`, `Duration`, `Rating`, and many practical-note fields. It can add imported rows to the current journal or replace the demo hikes, and it skips exact name/date/location duplicates by default.

Numeric imports currently assume miles, feet, and hours. The mapping rules and unit conversions can be extended once Robert's real workbook is available.

Use **Download an example import template** in the importer to see every currently supported column. Once Robert's real workbook is available, its exact headers and any special conventions can be added to the matching rules.

## Requirement review

All first-version requirements from the project brief are represented in the working app, including responsive CRUD workflows, detailed notes, planning checklists, bucket lists, photos, map layers, GPX/KML routes, stats, comparisons, goals, filtering, exports, safety, privacy, accessibility, and local persistence.

Infrastructure-dependent stretch features are intentionally not simulated: live GPS recording, social profiles, friend challenges, cloud sync, live weather fetching, AI summaries, and public sharing. The data model is ready for those integrations without changing the core interface.

## Project structure

```text
.
├── assets/hiking-hero.png
├── app.js
├── index.html
├── manifest.webmanifest
├── styles.css
└── sw.js
```

## GitHub Pages

The included workflow deploys the repository root to GitHub Pages. In repository settings, set **Pages → Source** to **GitHub Actions** if it is not selected automatically.

## Tests

Serve the project and open `tests/smoke.html` to run browser smoke tests for the greeting, weather behavior, dialog cancellation, manual hike entry, spreadsheet import, navigation, and mobile layout.

## License

MIT. OpenStreetMap and OpenTopoMap tiles retain their respective attribution and usage policies.
