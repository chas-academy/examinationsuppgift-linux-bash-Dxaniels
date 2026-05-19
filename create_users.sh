#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
  echo "Du måste köra scriptet som root"
  exit 1
fi

# Kontrollera att minst ett användarnamn skickas med
if [ $# -eq 0 ]; then
  echo "Du måste skriva minst ett användarnamn"
  exit 1
fi

# Skapa först alla användare
for user in "$@"; do
  echo "Hanterar användare: $user"

  if id "$user" &>/dev/null; then
    echo "$user finns redan"
  else
    useradd -m "$user"
  fi

  mkdir -p "/home/$user/Documents"
  mkdir -p "/home/$user/Downloads"
  mkdir -p "/home/$user/Work"

  chown -R "$user:$user" "/home/$user"
  chmod 700 "/home/$user"

  chmod 700 "/home/$user/Documents"
  chmod 700 "/home/$user/Downloads"
  chmod 700 "/home/$user/Work"
done

# Skapa welcome.txt efter att alla användare finns
for user in "$@"; do
  echo "Välkommen $user" > "/home/$user/welcome.txt"
  echo "Andra användare i systemet:" >> "/home/$user/welcome.txt"

  for other_user in "$@"; do
    if [ "$other_user" != "$user" ]; then
      echo "$other_user" >> "/home/$user/welcome.txt"
    fi
  done

  chown "$user:$user" "/home/$user/welcome.txt"
  chmod 600 "/home/$user/welcome.txt"
done
