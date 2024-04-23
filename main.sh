#!/bin/bash

function check_login() {
  local nom_utilisateur fichier_mot_de_passe="credentials.txt"
  read -p "Nom d'utilisateur : " nom_utilisateur
  read -sp "Mot de passe : " mot_de_passe
  if [[ "$nom_utilisateur" == "$(sed -n '1p' $fichier_mot_de_passe)" ]] && [[ "$mot_de_passe" == "$(sed -n '2p' $fichier_mot_de_passe)" ]]; then
    return 0
  else
    echo "Nom d'utilisateur ou mot de passe incorrect."
    return 1
  fi
}

function show_help() {
  echo "Commandes disponibles :"
  echo "  help         - Affiche ce message d'aide"
  echo "  ls           - Liste les fichiers et dossiers"
  echo "  rm           - Supprime un fichier"
  echo "  rmd/rmdir  - Supprime un répertoire"
  echo "  about        - Affiche des informations sur cette invite"
  echo "  version/--v/vers - Affiche la version de l'invite"
  echo "  age          - Demande votre âge et indique si vous êtes majeur ou mineur"
  echo "  quit         - Quitte l'invite"
  echo "  profil       - Affiche vos informations de profil"
  echo "  passw        - Change le mot de passe"
  echo "  cd           - Change de répertoire"
  echo "  pwd          - Affiche le répertoire de travail actuel"
  echo "  hour         - Affiche l'heure actuelle"
  echo "  *            - Indique une commande inconnue"
  echo "  httpget      - Télécharge le code source d'un site web"
  echo "  smtp         - Envoie un e-mail"
  echo "  open         - Ouvre un fichier dans VIM (même s'il n'existe pas)"
  echo "  rps          - Joue à Pierre-Papier-Ciseaux avec un autre joueur"
  echo "  rmdirwtf     - Supprimer un ou plusieurs dossier"
}

function age() {
  while true; do
    read -p "Entrez votre âge : " age_utilisateur

    if [[ $age_utilisateur =~ ^[0-9]+$ ]]; then
      if [ "$age_utilisateur" -ge 18 ]; then
        echo "Vous êtes majeur."
      else
        echo "Vous êtes mineur."
      fi
      break
    else
      echo "Veuillez entrer un âge valide (valeur numérique)."
    fi
  done
}

function profil() {
  if [ -f "credentials.txt" ]; then
    prenom=$(sed -n '3p' credentials.txt)
    nom=$(sed -n '4p' credentials.txt)
    age=$(sed -n '5p' credentials.txt)
    email=$(sed -n '6p' credentials.txt)

    echo "Prénom : $prenom"
    echo "Nom : $nom"
    echo "Âge : $age"
    echo "Email : $email"
  else
    echo "Informations de profil introuvables. Veuillez vous assurer que credentials.txt existe."
  fi
}

function passw() {
  if [ -f "credentials.txt" ]; then
    read -sp "Entrez le nouveau mot de passe : " nouveau_mot_de_passe
    echo

    read -sp "Confirmez le nouveau mot de passe : " confirmer_mot_de_passe
    echo

    if [ "$nouveau_mot_de_passe" = "$confirmer_mot_de_passe" ]; then
      sed -i "2s/.*/$nouveau_mot_de_passe/" credentials.txt
      echo "Mot de passe modifié avec succès."
    else
      echo "Les mots de passe ne correspondent pas. Le mot de passe n'a pas été modifié."
    fi
  else
    echo "Fichier de mots de passe introuvable. Veuillez vous assurer que credentials.txt existe."
  fi
}

function httpget() {
  read -p "Entrez l'URL : " url
  read -p "Entrez le nom du fichier pour enregistrer : " nom_fichier

  curl -o "$nom_fichier" "$url"

  if [ $? -eq 0 ]; then
    echo "Code source HTML téléchargé avec succès et enregistré dans $nom_fichier."
  else
    echo "Échec du téléchargement du code source HTML."
  fi
}

function smtp() {
  read -p "Entrez l'adresse e-mail du destinataire : " destinataire
  read -p "Entrez le sujet : " sujet
  read -p "Entrez le corps du message : " corps

  fichier_temporaire=$(mktemp)
  echo -e "À : $destinataire\nSujet : $sujet\n\n$corps" > "$fichier_temporaire"

  sendmail -t < "$fichier_temporaire"

  if [ $? -eq 0 ]; then
    echo "E-mail envoyé avec succès."
  else
    echo "Échec de l'envoi de l'e-mail."
  fi

  rm "$fichier_temporaire"
}

function open() {
  read -p "Entrez le nom du fichier : " nom_fichier

  vim "$nom_fichier"
}

function rps() {
  echo "Jouons à Pierre-Papier-Ciseaux !"

  read -p "Entrez le nom du Joueur 1 : " joueur1
  read -p "Entrez le nom du Joueur 2 : " joueur2

  score_joueur1=0
  score_joueur2=0

  while [ $score_joueur1 -lt 3 ] && [ $score_joueur2 -lt 3 ]; do
    echo "Tour de $joueur1 :"

    read -p "Entrez votre choix (pierre, papier, ciseaux ou puit) : " choix_joueur1

    echo "Tour de $joueur2 :"

    read -p "Entrez votre choix (pierre, papier, ciseaux ou puit) : " choix_joueur2

    if [ "$choix_joueur1" == "$choix_joueur2" ]; then
      echo "Match nul !"
    elif [ "$choix_joueur1" == "pierre" ]; then
      if [ "$choix_joueur2" == "ciseaux" ]; then
        echo "$joueur1 remporte ce tour !"
        ((score_joueur1++))
      else
        echo "$joueur2 remporte ce tour !"
        ((score_joueur2++))
      fi
    elif [ "$choix_joueur1" == "papier" ]; then
      if [ "$choix_joueur2" == "pierre" ]; then
        echo "$joueur1 remporte ce tour !"
        ((score_joueur1++))
      else
        echo "$joueur2 remporte ce tour !"
        ((score_joueur2++))
      fi
    elif [ "$choix_joueur1" == "ciseaux" ]; then
      if [ "$choix_joueur2" == "papier" ]; then
        echo "$joueur1 remporte ce tour !"
        ((score_joueur1++))
      else
        echo "$joueur2 remporte ce tour !"
        ((score_joueur2++))
      fi
    elif [ "$choix_joueur1" == "puit" ]; then
      echo "$joueur1 a utilisé puit et gagne !"
      ((score_joueur1++))
    elif [ "$choix_joueur2" == "puit" ]; then
      echo "$joueur2 a utilisé puit et gagne !"
      ((score_joueur2++))
    else
      echo "Choix invalide !"
    fi

    echo "Scores :"
    echo "$joueur1 : $score_joueur1"
    echo "$joueur2 : $score_joueur2"
  done

  if [ $score_joueur1 -gt $score_joueur2 ]; then
    echo "$joueur1 remporte la partie !"
  else
    echo "$joueur2 remporte la partie !"
  fi
}

function rmdirwtf() {
  if ! $loggedIn; then
    echo "Vous devez être connecté pour utiliser cette commande."
    return
  fi

  read -sp "Entrez votre mot de passe pour continuer : " mot_de_passe_entre
  echo

  mot_de_passe_stocke=$(sed -n '2p' credentials.txt)
  if [ "$mot_de_passe_entre" != "$mot_de_passe_stocke" ]; then
    echo "Mot de passe incorrect. Accès refusé."
    return
  fi

  read -p "Entrez le(s) nom(s) du/des répertoire(s) à supprimer : " repertoires

  for repertoire in $repertoires; do
    if [ -d "$repertoire" ]; then
      rm -r "$repertoire"
      echo "Répertoire '$repertoire' supprimé avec succès."
    else
      echo "Répertoire '$repertoire' introuvable."
    fi
  done
}

loggedIn=false
while true; do
  if ! $loggedIn; then
    if ! check_login; then
      continue
    fi
    loggedIn=true
    echo
    echo "Bienvenue dans l'invite magique !"
  fi

  read -p "magic-prompt> " commande args

  case "$commande" in
    help)
      show_help
      ;;
    ls)
      ls -a
      ;;
    rm)
      rm "$args"
      ;;
    rmd|rmdir)
      rmdir "$args"
      ;;
    about)
      echo "Il s'agit d'un Magic Prompt avec diverses fonctionnalités."
      ;;
    version|--v|vers)
      echo "Version : 1.0"
      ;;
    age)
      age
      ;;
    passw)
      passw
      ;;
    quit)
      echo "Fermeture du magic-prompt..."
      break
      ;;
    profil)
      profil
      ;;
    cd)
      cd "$args" && pwd 
      ;;
    pwd)
      pwd
      ;;
    hour)
      date +"%H:%M:%S"
      ;;
    httpget)
      httpget
      ;;
    smtp)
      smtp
      ;;
    open)
      open
      ;;
    rps)
      rps
      ;;
    rmdirwtf)
      rmdirwtf
      ;;
    *)
      echo "Commande inconnue : '$commande'"
      ;;
  esac
done
