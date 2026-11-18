Package:describe(function(s)
  s.name        = 'HL2 RP'
  s.version     = '1.0.0'
  s.date        = '2026-11-17'
  s.summary     = 'A roleplay gamemode based on Half-Life 2.'
  s.license     = 'AGPL-3.0'

  s.depends('flux', '~> 0.9')

  -- Uncomment the dependency of the database driver the server uses, then run `fpkg install`.
  -- SQLite needs none. MySQL and MariaDB use mysqloo, which is not an fpkg package yet:
  -- copy its module to garrysmod/lua/bin by hand.
  -- s.depends 'gmsv_pg'
end)
