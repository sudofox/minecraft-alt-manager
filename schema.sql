CREATE TABLE accounts(
  account_uuid text PRIMARY KEY,
  account_email text not null,
  account_password text not null,
  account_username text not null,
  access_token text null,
  client_token text null,
  verified boolean default 0 not null check(verified in(0,1)),
  UNIQUE(account_uuid,account_email,account_username) ON CONFLICT IGNORE
);

