# Mise en place de cinepassion38


Juste pour vous indiquez les commandes qu'il faut faire pour que tout le monde puisse utiliser mon projet cinpassion38.

## Importer le projet :
lien du projet:
https://gitlab.com/2018_LM_SIO2/cinepassion38/tree/dev/
```bash
# Si vous voulez directement l'importer en CLI
 git clone git@framagit.org:bob_ecureuil/cinepassion38_reforged.git
```

<hr/>

## Autorisation de la création du buffer :
Une fois les fichiers dans **/var/www/html/.../cinepassion38/**, il faut changer les droits du dossier **buffer**. Parce que c'est dans ce dossier qu'on créé des fichiers html qui serra afficher avant de ce faire supprimer (génère un fichier html avec mon php).

```bash
# Il y a 2 façons différentes de faire:
sudo chown www-data:www-data ./buffer/
# Ou sinon, mais plus bourrin
sudo chmod a+wrx ./buffer/
```

<hr/>

## SQL
### Importer le script dans la base de données
Une fois cela fait, il faut importer la base de données, pour cela il faut bien faire attention de ce connecter avec mysql **SANS sudo**. *(mysql -u USER_NAME -p)*

La commande pour exécuter directement un script :
```sql
mysql -u USER_NAME -p < ./sgbdr/cinepassion38.sql
```
Si vous avez des problèmes pour vous connecter sur votre utilisateur mysql sans sudo devant. Alors on va créer directement un utilisateur spécialement pour le rojet.

Cette fois il va falloir ce connecter à mysql en root
```bash
sudo mysql # Se connecter en Admin
```

```sql
CREATE USER 'cinepassion38_user'@'localhost' IDENTIFIED BY 'cinepassion38_user';
GRANT ALL PRIVILEGES ON cinepassion38.* TO 'cinepassion38_user'@'localhost';
FLUSH PRIVILEGES; # Cette commande active les privilèges (pour ceux qui n ont jamais vu cette commande)
```

Maintenant vous pouvez tenter de vous connecter sans utiliser root :
```bash
# Le mot de passe est "cinepassion38_user"
mysql -u cinepassion38_user -p
# Ou si vous avez pas envie de marquer le mot de passe
mysql -u cinepassion38_user -p'cinepassion38_user'
```
Si vous pouvez aller sur la base de données. Il n'y a pas de problème alors.

### Vérification des drivers
Il y aussi la possibilité que votre ordinateur n'est pas les drivers qui vont bien pour pouvoir utiliser PDO (ce qui me permet de faire le lien entre le php et mysql).
Pour cela on va simplement les installer:

```bash
sudo apt install php-mysql
```

<hr/>

## Modification du fichier de configuration
Pour cela il faut simplement allé modifier le fichier de configuration et mettre les bonnes informations.

```bash
# ouverture du fichier
gedit ./configuration/dev.ini
```

Remplacer les informations de la ligne 52 à 60 par

```txt
; ===================================================================
; Connect into Data Base
; ===================================================================
[baseDeDonnees]
dbserverName = "127.0.0.1"
dbBaseName = "cinepassion38"
dbLogin = "cinepassion38_user"
dbPassword = "cinepassion38_user"
```

<hr/>

## La page blanche
Cela provient simplement d'un problème de cache.
Pour résoudre le problème, il faut faire **crtl + F5** sur la page.

<hr/>

## User
Sur le site pour ce connecter, j'ai tout le temps utilisé le même mot de passe **azer**.
Il y a des users avec plus de droits que les autres. Par exemple **admin**

<hr/>

**Vous pouvez maintenant lancer le projet et vous amuser avec !**

## Autre configuration
Un fichier de configuration `./configuration/dev.ini` existe.
Il peut être utilisé pour configurer plus ou moins de chose.
Mais aucune documentation n'a été créé pour cela. 
Il faut donc regarder dans le code et le fichier pour savoir comment l'utiliser.

## Copyright FR
Comme ce projet est un projet scolaire, dont une partie du code n'a pas été écrite par moi.
Malgré l'autorisation de mettre ce code en publique.
Je ne peux pas mettre le projet OpenSource comme je voudrais. 
Aller lire `./copyright.txt` pour plus de détail.

## Copyright ENG
As this project is a school project, part of the code was not written by me.
Despite the permission to put this code in public.
I can't put the project OpenSource as I would like. 
Go read `./copyright.txt` for more detail.