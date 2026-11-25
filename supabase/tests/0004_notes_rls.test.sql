begin;
select plan(3);
insert into auth.users (instance_id, id, aud, role, email, created_at, updated_at) values
  ('00000000-0000-0000-0000-000000000000','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','authenticated','authenticated','user_a@example.com',now(),now()),
  ('00000000-0000-0000-0000-000000000000','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','authenticated','authenticated','user_b@example.com',now(),now());
insert into public.notes (owner_id, body) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'nota de A');
select set_config('request.jwt.claims', '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.notes), 0, 'B no lee las notas de A');
update public.notes set body = 'hack' where owner_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
select throws_ok($$ insert into public.notes (owner_id, body) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','x') $$, '42501', null, 'B no inserta como A');
reset role;
select is((select body from public.notes where owner_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), 'nota de A', 'la nota de A sigue intacta');
select * from finish();
rollback;
