# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyApp.Repo.insert!(%MyApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MyApp.Repo
alias MyApp.Users.User

Repo.insert!(%User{mobile: "987654321", email: "user1@test.com", password_hash: Bcrypt.hash_pwd_salt("password1")})
Repo.insert!(%User{mobile: "111222333", email: "user2@test.com", password_hash: Bcrypt.hash_pwd_salt("password2")})
Repo.insert!(%User{mobile: "123456789", email: "user3@test.com", password_hash: Bcrypt.hash_pwd_salt("password3")})
Repo.insert!(%User{mobile: "000111222", email: "user4@test.com", password_hash: Bcrypt.hash_pwd_salt("password4")})
