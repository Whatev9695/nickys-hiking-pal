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
- Optional Supabase accounts with automatic cross-device cloud sync
- Private-by-default multi-user data isolation using row-level security
- Hiking groups with invite codes and explicitly shared plans
- Accessible labels, keyboard controls, semantic landmarks, and non-color status labels

## Data ownership and privacy

The app is local-first. Hikes, photos, routes, settings, and goals save immediately in the browser's `localStorage`, so the app remains useful offline. When Supabase is configured and a user signs in, the complete journal also syncs to that user's private cloud row and follows them across devices.

Supabase row-level security ensures users can access only their own journal. Hiking groups expose only plans that a member deliberately shares; completed hikes and private notes are never automatically shared. Exact trailheads can still be offset on the map.

**Restore app backup** reads a JSON file previously created by **Export my data**. It replaces the hikes, plans, goals, and settings currently stored in that browser. It is for moving or recovering the complete app state, while **Import spreadsheet** is specifically for converting an existing Excel/CSV hiking history into completed hikes.

Photo capacity still depends on the browser's local storage quota. The included schema creates a private `hike-photos` storage bucket and policies as a foundation for moving full-resolution photo files out of journal JSON in a later release.

## Cloud sync setup

1. Create a Supabase project.
2. Run [`supabase/schema.sql`](supabase/schema.sql) in the project's SQL editor.
3. For local use, copy `config.example.js` values into `config.js`:

```js
window.NHP_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseAnonKey: "YOUR_PUBLIC_ANON_KEY"
};
```

4. For GitHub Pages, add repository secrets named `SUPABASE_URL` and `SUPABASE_ANON_KEY`. The deployment workflow generates `config.js` from them.
5. In Supabase Authentication, configure the deployed site URL and desired email/password confirmation settings.
6. Deploy the updated files.

The public anonymous key is intended for browser use; security comes from the included row-level security policies. Never place the Supabase service-role key in this app.

Once connected, accounts can sign in on multiple devices. Every authenticated user receives a separate local cache as well as a private cloud journal, preventing account data from mixing on a shared browser. A brand-new account starts empty and offers an explicit **Import this device's journal** action rather than silently claiming another user's local data. Later changes save locally first and sync shortly afterward. On reconnect, the app compares update times so newer offline work is uploaded instead of overwritten. The database also snapshots the previous journal state before every cloud update. The **Sync now** button provides an explicit retry.

Group creators receive an eight-character invite code. Other authenticated users can join with that code and view plans explicitly shared to the group. Individual journals and stats remain separate.

## Mapping and data sources

The app uses [Leaflet](https://leafletjs.com/) with [OpenStreetMap](https://www.openstreetmap.org/) and [OpenTopoMap](https://opentopomap.org/) tiles. It does not scrape, copy, or depend on AllTrails data. Trail information comes from demo data, manual entry, user files, or optional reference links.

No API keys are required. A future live-weather adapter should use an environment variable and a provider that permits the intended use.

Current weather uses the no-key [Open-Meteo Forecast API](https://open-meteo.com/en/docs). It defaults to the Seattle area until Robert chooses **Use my location**; the chosen coordinates remain only in local app settings. Mountain weather can differ sharply from trailhead conditions, so the dashboard explicitly encourages checking official mountain forecasts.

## Spreadsheet import

Choose **Import spreadsheet**, select the workbook, and review the automatic column matches before importing. The importer supports common variations such as `Hike Name`, `Trail`, `Date Completed`, `Miles`, `Elevation Gain`, `Duration`, `Rating`, and many practical-note fields. It can add imported rows to the current journal or replace the demo hikes, and it skips exact name/date/location duplicates by default.

Elevation values are stored to the exact foot. Duration can be entered as hours, minutes, and seconds in the app, and imported as `H:MM:SS`, written time such as `5h 12m 34s`, or legacy decimal hours.

Numeric imports currently assume miles and feet. Duration recognizes `H:MM:SS`, written time, and decimal hours. The mapping rules and unit conversions can be extended once Robert's real workbook is available.

Use **Download an example import template** in the importer to see every currently supported column. Once Robert's real workbook is available, its exact headers and any special conventions can be added to the matching rules.

## Requirement review

All first-version requirements from the project brief are represented in the working app, including responsive CRUD workflows, detailed notes, planning checklists, bucket lists, photos, map layers, GPX/KML routes, stats, comparisons, goals, filtering, exports, safety, privacy, accessibility, and local persistence.

Infrastructure-dependent stretch features still not included are live GPS recording, public social profiles, friend challenges, AI summaries, and public sharing. Cloud sync, authenticated multi-user journals, private groups, and live weather are implemented.

## Project structure

```text
.
├── assets/hiking-hero.png
├── app.js
├── cloud.js
├── config.js
├── config.example.js
├── index.html
├── manifest.webmanifest
├── supabase/schema.sql
├── styles.css
└── sw.js
```

## GitHub Pages

The included workflow deploys the repository root to GitHub Pages. In repository settings, set **Pages → Source** to **GitHub Actions** if it is not selected automatically.

## Tests

Serve the project and open `tests/smoke.html` to run browser smoke tests for the greeting, weather behavior, dialog cancellation, manual hike entry, spreadsheet import, navigation, and mobile layout.

## License

MIT. OpenStreetMap and OpenTopoMap tiles retain their respective attribution and usage policies.
