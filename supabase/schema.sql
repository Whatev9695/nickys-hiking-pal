-- Run this file once in a new Supabase project's SQL editor.
create extension if not exists pgcrypto;
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create table if not exists public.app_states (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_state_versions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null,
  saved_at timestamptz not null default now()
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  invite_code text not null unique check (char_length(invite_code) = 8),
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  joined_at timestamptz not null default now(),
  primary key (group_id,user_id)
);

create table if not exists public.shared_plans (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  location text,
  target_date date,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.app_states enable row level security;
alter table public.app_state_versions enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.shared_plans enable row level security;

revoke all on public.app_states,public.app_state_versions,public.groups,public.group_members,public.shared_plans from anon;
grant select,insert,update,delete on public.app_states,public.groups,public.group_members,public.shared_plans to authenticated;
grant select on public.app_state_versions to authenticated;

create policy "Users own their app state" on public.app_states
  for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users can view their journal history" on public.app_state_versions
  for select to authenticated using ((select auth.uid()) = user_id);

create or replace function private.snapshot_app_state()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if tg_op='UPDATE' and old.data is distinct from new.data then
    insert into public.app_state_versions(user_id,data) values(old.user_id,old.data);
    delete from public.app_state_versions
    where user_id=old.user_id and id not in (
      select id from public.app_state_versions where user_id=old.user_id order by saved_at desc limit 50
    );
  end if;
  return new;
end;
$$;
revoke all on function private.snapshot_app_state() from public;
drop trigger if exists app_state_snapshot on public.app_states;
create trigger app_state_snapshot before update on public.app_states
for each row execute function private.snapshot_app_state();

create policy "Members can view their groups" on public.groups
  for select to authenticated using (exists (
    select 1 from public.group_members gm where gm.group_id = groups.id and gm.user_id = (select auth.uid())
  ));
create policy "Users can create groups" on public.groups
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Owners can update groups" on public.groups
  for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Owners can delete groups" on public.groups
  for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "Users can view their memberships" on public.group_members
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Owners can add their owner membership" on public.group_members
  for insert to authenticated with check (
    (select auth.uid()) = user_id and role = 'owner' and
    exists (select 1 from public.groups g where g.id = group_id and g.owner_id = (select auth.uid()))
  );
create policy "Users can leave groups" on public.group_members
  for delete to authenticated using ((select auth.uid()) = user_id and role <> 'owner');

create policy "Members can view shared plans" on public.shared_plans
  for select to authenticated using (exists (
    select 1 from public.group_members gm where gm.group_id = shared_plans.group_id and gm.user_id = (select auth.uid())
  ));
create policy "Members can share their plans" on public.shared_plans
  for insert to authenticated with check (
    (select auth.uid()) = owner_id and exists (
      select 1 from public.group_members gm where gm.group_id = shared_plans.group_id and gm.user_id = (select auth.uid())
    )
  );
create policy "Owners can update shared plans" on public.shared_plans
  for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Owners can remove shared plans" on public.shared_plans
  for delete to authenticated using ((select auth.uid()) = owner_id);

create or replace function private.join_hiking_group(code_input text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare target_id uuid;
begin
  select id into target_id from public.groups where invite_code = upper(trim(code_input));
  if target_id is null then raise exception 'Invite code not found'; end if;
  insert into public.group_members(group_id,user_id,role)
  values(target_id,auth.uid(),'member') on conflict do nothing;
  return target_id;
end;
$$;
revoke all on function private.join_hiking_group(text) from public;
grant execute on function private.join_hiking_group(text) to authenticated;

create or replace function public.join_hiking_group(code_input text)
returns uuid language sql security invoker set search_path=public,private
as $$ select private.join_hiking_group(code_input); $$;
revoke all on function public.join_hiking_group(text) from public;
grant execute on function public.join_hiking_group(text) to authenticated;

create or replace function private.create_hiking_group(name_input text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare new_id uuid; new_code text;
begin
  if char_length(trim(name_input)) not between 1 and 80 then raise exception 'Group name is required'; end if;
  new_code := upper(substr(replace(gen_random_uuid()::text,'-',''),1,8));
  insert into public.groups(owner_id,name,invite_code)
  values(auth.uid(),trim(name_input),new_code) returning id into new_id;
  insert into public.group_members(group_id,user_id,role) values(new_id,auth.uid(),'owner');
  return new_id;
end;
$$;
revoke all on function private.create_hiking_group(text) from public;
grant execute on function private.create_hiking_group(text) to authenticated;

create or replace function public.create_hiking_group(name_input text)
returns uuid language sql security invoker set search_path=public,private
as $$ select private.create_hiking_group(name_input); $$;
revoke all on function public.create_hiking_group(text) from public;
grant execute on function public.create_hiking_group(text) to authenticated;

-- Optional cloud-photo foundation. The current app syncs small local previews
-- inside app state; production photo uploads can use this private bucket.
insert into storage.buckets(id,name,public)
values('hike-photos','hike-photos',false) on conflict (id) do nothing;
create policy "Users manage their photo folder" on storage.objects
  for all to authenticated
  using (bucket_id='hike-photos' and (storage.foldername(name))[1]=auth.uid()::text)
  with check (bucket_id='hike-photos' and (storage.foldername(name))[1]=auth.uid()::text);
