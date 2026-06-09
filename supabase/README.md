# Supabase Setup

This folder turns the local-first demo into a durable multi-user app.

## Provision

1. Create a Supabase project.
2. Open **SQL Editor**, paste `schema.sql`, and run it once.
3. Open **Authentication → URL Configuration**:
   - Set the Site URL to the deployed app URL.
   - Add local and deployed redirect URLs as needed.
4. Choose whether email confirmation is required under **Authentication → Providers → Email**.
5. Copy the project URL and public anonymous key from **Project Settings → API**.

For local use, put the values in `config.js`. For GitHub Pages, add repository secrets:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

The Pages workflow writes those values into `config.js` during deployment.

## Security Model

- `app_states`: one complete private journal per authenticated user.
- `app_state_versions`: up to 50 previous journal snapshots per user.
- `groups`: hiking groups with invite codes.
- `group_members`: membership records.
- `shared_plans`: only plans a member explicitly shares.
- `hike-photos`: private storage bucket foundation.

Row-level security is enabled on every table. The browser receives only the public anonymous key. Never expose the service-role key.

## Smoke Check

After deployment:

1. Create two test accounts.
2. Log a different hike in each account and confirm journals remain separate.
3. Sign into one account on another device and confirm its journal loads.
4. Create a group, join from the other account using the invite code, and share one plan.
5. Confirm the shared plan is visible while completed hikes and private notes remain invisible.
