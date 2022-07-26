-- ===============================================================================================================
-- base de données : cinepassion38
-- type : MySql V5.7.11 (WampServer 3.0.4)
-- auteur : Christophe Goidin <christophe.goidin@ac-grenoble.fr> (lycée louise Michel - Grenoble)
-- création :
-- 		décembre 2009
-- modification :
--      septembre 2010	ajout des films
--      juillet 2012	type_film -> genre
--      octobre 2012	historisation avec trigger
--      mai 2013		réorganisation du code : variable, ...
--      août 2013		héritage personne -> realisateur et acteur
--                      table participer
--                      création des routines (fonctions et procédures stockées)
--      septembre 2013	adaptation du code en fonction des droits donnés aux utilisateurs
--      septembre 2016	ajout de films. Correction des bugs relatifs aux caractères accentués
--		juin 2017		refonte du site web full objet MVC (et donc de la base de données)
--						réécriture des noms en respectant la numérotation "lower camel case"
-- 
-- ***********************************************************************************************************
-- *                                         Utilisation                                                     *
-- * il faut penser à désactiver sur la VM la commande -> SET GLOBAL log_bin_trust_function_creators = 1;    *
-- * il faut adapter le nom de la base de données en fonction de votre groupe d'appartenance                 *
-- * par exemple : base de données du groupe 3 -> USE CinePassion38_Groupe3                                  *
-- ***********************************************************************************************************
-- A FAIRE : voir les ""
-- ===============================================================================================================


START TRANSACTION;


-- ===============================================================================================================
--   paramétrage pour une exécution locale OU sur la machine virtuelle 
-- ===============================================================================================================
-- le paramètre log_bin_trust_function_creators doit être positionné à 1 afin de pouvoir exécuter des routines
-- localement : vous êtes administrateur de votre serveur de base de données, vous DEVEZ donc activer ce paramètre
-- sur la VM  : vous n'êtes pas administrateur et vous n'avez pas les droits pour activer ce paramètre, il faut donc DESACTIVER cette commande (erreur sinon).
--              l'administrateur (qui lui a les droits) a déjà activé cette commande
SET GLOBAL log_bin_trust_function_creators = 1;



-- ============================================================================
--   mot de passe par défaut
-- ============================================================================
SET @defautMotDePasse = "azer";



-- ===============================================================================================================
--   création et sélection de la base de données
-- ===============================================================================================================
DROP DATABASE IF EXISTS cinepassion38;
CREATE DATABASE cinepassion38;
USE cinepassion38;


-- REGION tables
-- ===============================================================================================================
--   création des tables                                
-- ===============================================================================================================
CREATE TABLE pays (
	numPays								TINYINT UNSIGNED AUTO_INCREMENT			COMMENT "Le numéro du pays",
 	libellePays							VARCHAR(30)	NOT NULL					COMMENT "Le libellé du pays",
  libelleHommePays							VARCHAR(30)	NOT NULL					COMMENT "Le libellé du pays pour un homme (un acteur américain)",
  libelleFemmePays							VARCHAR(30)	NOT NULL					COMMENT "Le libellé du pays (une actrice américaine)",
	CONSTRAINT UK_LibellePays			UNIQUE KEY (libellePays),
	CONSTRAINT PK_NumPays				PRIMARY KEY (numPays)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE genre (
	numGenre							TINYINT UNSIGNED AUTO_INCREMENT			COMMENT "Le numéro du genre",
	libelleGenre						VARCHAR(20) NOT NULL					COMMENT "Le libellé du genre",
	CONSTRAINT UK_LibelleGenre			UNIQUE KEY (libelleGenre),
	CONSTRAINT PK_NumGenre				PRIMARY KEY (numGenre)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
 
CREATE TABLE film (
	numFilm								SMALLINT UNSIGNED AUTO_INCREMENT		COMMENT "le numéro du film",
	titreFilm							VARCHAR(60) NOT NULL					COMMENT "Le titre du film",
	synopsisFilm						VARCHAR(1500) NULL						COMMENT "Le résumé du film",
	dureeFilm							TIME NOT NULL							COMMENT "La durée du film : ...h ...m ...s",
	dateSortieFilm						DATE NULL								COMMENT "La date de sortie en France du film",
	numGenreFilm						TINYINT	UNSIGNED NOT NULL				COMMENT "Le numéro de genre du film",
	numRealisateurFilm					SMALLINT UNSIGNED NOT NULL				COMMENT "Le numéro du réalisateur du film",
	numPaysFilm							TINYINT	UNSIGNED NOT NULL DEFAULT 1		COMMENT "Le numéro du pays de réalisation du film",
	CONSTRAINT UK_TitreFilm				UNIQUE KEY (titreFilm),
	CONSTRAINT PK_Film					PRIMARY KEY (numFilm)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;  

CREATE TABLE personne (
	numPersonne							SMALLINT UNSIGNED AUTO_INCREMENT		COMMENT "Le numéro de la personne",
	prenomPersonne						VARCHAR(20) NOT NULL					COMMENT "Le prénom de la personne",
	nomPersonne							VARCHAR(20) NOT NULL					COMMENT "Le nom de la personne",
	dateNaissancePersonne				DATE NULL								COMMENT "La date de naissance de la personne",
	villeNaissancePersonne				VARCHAR(20) NULL						COMMENT "La ville de naissance de la personne",
	sexePersonne						ENUM("M","F") NOT NULL					COMMENT "Le sexe de la personne",
	numPaysPersonne						TINYINT UNSIGNED NOT NULL DEFAULT 1		COMMENT "Le numéro du pays d'origine de la personne",
	CONSTRAINT UK_Personne				UNIQUE KEY (prenomPersonne, nomPersonne),
	CONSTRAINT PK_Personne				PRIMARY KEY (numPersonne),
	CONSTRAINT FK_NumPaysPersonne		FOREIGN KEY (numPaysPersonne) REFERENCES pays(numPays) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;  

CREATE TABLE realisateur (
	numRealisateur						SMALLINT UNSIGNED						COMMENT "Le numéro du réalisateur",
	CONSTRAINT PK_Realisateur			PRIMARY KEY (numRealisateur),
	CONSTRAINT FK_NumRealisateur		FOREIGN KEY (numRealisateur) REFERENCES personne(numPersonne) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;  

CREATE TABLE acteur (
	numActeur							SMALLINT UNSIGNED						COMMENT "Le numéro de l'acteur",
	tailleActeur						TINYINT UNSIGNED						COMMENT "La taille est exprimée en cm",
	CONSTRAINT PK_Acteur				PRIMARY KEY (numActeur),
	CONSTRAINT FK_NumActeur				FOREIGN KEY (numActeur) 	REFERENCES personne(numPersonne) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8; 

CREATE TABLE participer (
	numFilm								SMALLINT UNSIGNED NOT NULL				COMMENT "Le numéro du film",
	numActeur							SMALLINT UNSIGNED NOT NULL				COMMENT "Le numéro de l'acteur",
	role								VARCHAR(50)	NULL						COMMENT "Le rôle joué par l'acteur dans le film",
	CONSTRAINT PK_Participer			PRIMARY KEY (numFilm, numActeur),
	CONSTRAINT FK_ParticiperFilm		FOREIGN KEY (numFilm) 		REFERENCES film(numFilm) 		ON DELETE CASCADE,
	CONSTRAINT FK_ParticiperActeur		FOREIGN KEY (numActeur) 	REFERENCES acteur(numActeur) 	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE typeUser (
	numTypeUser							TINYINT UNSIGNED AUTO_INCREMENT							COMMENT "Le numéro du type d'utilisateur",
	libelleTypeUser						ENUM("administrateur", "membre", "visiteur") NOT NULL	COMMENT "Le libellé du type d'utilisateur",
	CONSTRAINT PK_TypeUser				PRIMARY KEY (numTypeUser)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE user (
	loginUser							VARCHAR(20)												COMMENT "Le login de l'utilisateur",
	motDePasseUser						VARCHAR(128) NOT NULL									COMMENT "Le mot de passe chiffré de l'utilisateur à l'aide de l'algorithme SHA2 512bits",
	prenomUser							VARCHAR(20) NOT NULL									COMMENT "Le prénom de l'utilisateur",
	nomUser								VARCHAR(20) NOT NULL									COMMENT "Le nom de l'utilisateur",
	dateNaissanceUser					DATE NOT NULL											COMMENT "La date de naissance de l'utilisateur",
	sexeUser							ENUM("H", "F") DEFAULT "H" NOT NULL						COMMENT "Le sexe de l'utilisateur : H ou F",
	adresseUser							VARCHAR(30)												COMMENT "L'adresse de l'utilisateur : Numéro de la voie, type de la voie et libellé de la voie",
	codePostalUser						VARCHAR(5)												COMMENT "Le code postal de l'utilisateur",
	villeUser							VARCHAR(20)												COMMENT "Le libellé de la ville de l'utilisateur",
	telephoneFixeUser					VARCHAR(10)												COMMENT "Le numéro de téléphone fixe de l'utilisateur",
	telephonePortableUser				VARCHAR(10)												COMMENT "Le numéro de téléphone portable de l'utilisateur",
	mailUser							VARCHAR(40) NOT NULL									COMMENT "L'adresse électronique de l'utilisateur",
	avatarUser							VARCHAR(20)												COMMENT "Le nom de l'avatar de l'utilisateur",
	nbTotalConnexionUser				INTEGER UNSIGNED DEFAULT 0 NOT NULL						COMMENT "Le nombre total de connexion de l'utilisateur",
	nbEchecConnexionUser				TINYINT UNSIGNED DEFAULT 0 NOT NULL						COMMENT "Le nombre d'échecs de connexion de l'utilisateur",
	dateHeureCreationUser				DATETIME NOT NULL										COMMENT "La date et l'heure de la création de l'utilisateur",
	dateHeureDerniereConnexionUser		DATETIME												COMMENT "La date et l'heure de la dernière connexion de l'utilisateur",
	typeUser							TINYINT UNSIGNED NOT NULL								COMMENT "Le numéro du type d'utilisateur",
	CONSTRAINT PK_User					PRIMARY KEY (loginUser),
	CONSTRAINT UK_TelephonePortableUser	UNIQUE KEY (telephonePortableUser),
	CONSTRAINT UK_MailUser				UNIQUE KEY (mailUser),
	CONSTRAINT FK_TypeUser				FOREIGN KEY (typeUser) REFERENCES typeUser(numTypeUser) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE rsa (
	numKeyRsa							TINYINT UNSIGNED AUTO_INCREMENT							COMMENT "Le numéro du couple de clés",
	tailleKeyRsa						SMALLINT UNSIGNED NOT NULL								COMMENT "Le nombre de bits de la clé : 128, 256, 512, 1024, 2048 ou 4096",
	privateKeyRsa						VARCHAR(3300) NOT NULL									COMMENT "La clé privée RSA",
  	publicKeyRsa						VARCHAR(850) NOT NULL									COMMENT "La clé publique RSA",
	CONSTRAINT PK_RSA					PRIMARY KEY (numKeyRsa)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ===============================================================================================================
--   création des clés étrangères
-- ===============================================================================================================
ALTER TABLE film 
	ADD CONSTRAINT FK_NumGenreFilm			FOREIGN KEY (numGenreFilm)			REFERENCES genre(numGenre) ON DELETE CASCADE,
	ADD CONSTRAINT FK_NumRealisateurFilm	FOREIGN KEY (numRealisateurFilm)	REFERENCES realisateur(numRealisateur) ON DELETE CASCADE,    
	ADD CONSTRAINT FK_NumPaysFilm			FOREIGN KEY (numPaysFilm)			REFERENCES pays(numPays) ON DELETE CASCADE;

-- END REGION


-- ============================================================================
--   ajout du champ dans la table des utilisateurs afin de gérer le grain de sel
-- ============================================================================
ALTER TABLE user
ADD grainDeSelUser VARCHAR(20) NOT NULL	COMMENT "Le grain de sel associé à l'utilisateur pour le chiffrement de son mot de passe";

-- REGION routines
-- ===============================================================================================================
--   création des routines (procédures et fonctions stockées)
-- ===============================================================================================================
DELIMITER //
CREATE FUNCTION getAge(pDateNaissance DATE) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE vAge TINYINT UNSIGNED;
    SELECT YEAR(CURDATE()) - YEAR(pDateNaissance) - IF(DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(pDateNaissance, '%m%d'), 1, 0) INTO vAge FROM Dual;
	RETURN vAge;
END //

CREATE FUNCTION getNbAnneesEcart(pDate1 DATE, pDate2 DATE) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE vNbAnneesEcart TINYINT UNSIGNED;
    IF pDate1 > pDate2 THEN
		SELECT YEAR(pDate1) - YEAR(pDate2) - IF(DATE_FORMAT(pDate1, '%m%d') < DATE_FORMAT(pDate2, '%m%d'), 1, 0) INTO vNbAnneesEcart FROM Dual;
	ELSE
		SELECT YEAR(pDate2) - YEAR(pDate1) - IF(DATE_FORMAT(pDate2, '%m%d') < DATE_FORMAT(pDate1, '%m%d'), 1, 0) INTO vNbAnneesEcart FROM Dual;
	END IF;
	RETURN vNbAnneesEcart;
END //

CREATE PROCEDURE ajoutPersonne(IN pTypePersonne ENUM("realisateur", "acteur", "polyvalent"), IN pPrenomPersonne VARCHAR(20), IN pNomPersonne VARCHAR(20), IN pTaillePersonne TINYINT UNSIGNED, IN pDateNaissancePersonne DATE, IN pVilleNaissancePersonne VARCHAR(20), IN pSexePersonne ENUM("M","F"), IN pNumPaysPersonne TINYINT UNSIGNED)
BEGIN
	DECLARE vNumeroMax SMALLINT UNSIGNED;
	INSERT INTO personne VALUES (null, pPrenomPersonne, pNomPersonne, pDateNaissancePersonne, pVilleNaissancePersonne, pSexePersonne, pNumPaysPersonne);
	SELECT MAX(numPersonne) INTO vNumeroMax FROM personne;
	IF (pTypePersonne = "realisateur") THEN
		INSERT INTO realisateur VALUES (vNumeroMax);
	ELSEIF (pTypePersonne = "acteur") THEN
		INSERT INTO acteur VALUES (vNumeroMax, pTaillePersonne);
	ELSE -- polyvalent
		INSERT INTO realisateur VAlUES (vNumeroMax);
		INSERT INTO acteur VALUES (vNumeroMax, pTaillePersonne);
    END IF;
END //












-- ============================================================================
--   fonction renvoyant un grain de sel aléatoire
-- ============================================================================
CREATE FUNCTION getGrainDeSel() RETURNS VARCHAR(20)
BEGIN
	DECLARE vGrainDeSel VARCHAR(20);
	SET vGrainDeSel = "";
	WHILE LENGTH(vGrainDeSel) < 20 DO
       	SET vGrainDeSel = CONCAT(vGrainDeSel, getUnCaractereAleatoire());
	END WHILE;
	RETURN vGrainDeSel;
END //

-- ============================================================================
--   fonction renvoyant le mot de passe haché
-- ============================================================================
CREATE FUNCTION getMotDePasseHache(pMotDePasse VARCHAR(20), pGrainDeSel VARCHAR(20)) RETURNS VARCHAR(128)
BEGIN
	RETURN SHA2(CONCAT(MD5(CONCAT(pGrainDeSel, pMotDePasse)), pGrainDeSel, MD5(CONCAT(pMotDePasse, pGrainDeSel))), 512);
END //

-- ============================================================================
--   fonction stockée renvoyant un caractère aléatoire
-- ============================================================================
CREATE FUNCTION getUnCaractereAleatoire() RETURNS VARCHAR(1)
BEGIN
	DECLARE vChaine VARCHAR(62);
	SET vChaine = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	RETURN SUBSTR(vChaine, CEILING(RAND() * LENGTH(vChaine)), 1);
END //

-- ============================================================================
--   procédure stockée permettant d'affecter un gain de sel aléatoire et de réinitialiser le mot de passe de tous les utilisateurs
-- ============================================================================
CREATE PROCEDURE majGrainDeSelUser()
BEGIN
	DECLARE vFini BOOLEAN DEFAULT False;
	DECLARE vLoginUser VARCHAR(20);
	DECLARE vGrainDeSelUser VARCHAR(20);
	DECLARE curseurUser CURSOR FOR SELECT loginUser FROM user;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vfini = true;
	OPEN curseurUser;
	boucle: REPEAT
		FETCH curseurUser INTO vLoginUser;
		SET vGrainDeSelUser = getGrainDeSel();
		UPDATE user SET grainDeSelUser = vGrainDeSelUser,
					    motDePasseUser = getMotDePasseHache(@defautMotDePasse, vGrainDeSelUser)
		WHERE loginUser = vLoginUser;
	UNTIL vFini = true
	END REPEAT boucle;
	CLOSE curseurUser;
END //





CREATE PROCEDURE ajoutUser(IN pTypeUser ENUM("administrateur", "membre", "visiteur"),
						   IN pLoginUser VARCHAR(20),
						   IN pMotDePasseUser VARCHAR(20),
						   IN pPrenomUser VARCHAR(20),
						   IN pNomUser VARCHAR(20),
						   IN pDateNaissanceUser DATE, 
						   IN pSexeUser ENUM("H", "F"),
						   IN pAdresseUser VARCHAR(30),
						   IN pCodePostalUser VARCHAR(5),
						   IN pVilleUser VARCHAR(20),
						   IN pTelephoneFixeUser VARCHAR(10),
						   IN pTelephonePortableUser VARCHAR(10),
						   IN pMailUser VARCHAR(40),
						   IN pAvatarUser VARCHAR(20))
BEGIN
	-- génération du grain de sel aléatoire
	DECLARE vGrainDeSel VARCHAR(20);
	SET vGrainDeSel = getGrainDeSel();
			
	-- insertion de l'utilisateur
    INSERT INTO user(loginUser,
    				 motDePasseUser,
    				 grainDeSelUser,
    				 prenomUser,
    				 nomUser,
    				 dateNaissanceUser,
    				 sexeUser,
    				 adresseUser,
    				 codePostalUser,
    				 villeUser,
    				 telephoneFixeUser,
    				 telephonePortableUser,
    				 mailUser,
    				 avatarUser,
    				 nbTotalConnexionUser,
    				 nbEchecConnexionUser,
    				 dateHeureCreationUser,
    				 dateHeureDerniereConnexionUser,
    				 typeUser
    				 )
     				 VALUES (pLoginUser,
	                         getMotDePasseHache(pMotDePasseUser, vGrainDeSel),
							 vGrainDeSel,
							 pPrenomUser,
							 pNomUser,
							 pDateNaissanceUser,
							 pSexeUser,
							 pAdresseUser,
							 pCodePostalUser,
							 pVilleUser,
							 pTelephoneFixeUser,
							 pTelephonePortableUser,
							 pMailUser,
							 IF(pAvatarUser <> "?", pAvatarUser, IF(pSexeUser = "H", "H", "F")),
							 0,
							 0,
							 SYSDATE(),
							 null,
							 (SELECT numTypeUser FROM typeUser WHERE libelleTypeUser = pTypeUser));
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION getNumPersonne(pTypePersonne ENUM("realisateur", "acteur"), pPrenomPersonne VARCHAR(20), pNomPersonne VARCHAR(20)) RETURNS SMALLINT UNSIGNED
BEGIN
    DECLARE vNumPersonne SMALLINT UNSIGNED;
    IF (pTypePersonne = "realisateur") THEN
		SELECT numRealisateur INTO vNumPersonne FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = pPrenomPersonne AND nomPersonne = pNomPersonne;
	ELSE -- acteur
		SELECT numActeur INTO vNumPersonne FROM acteur A INNER JOIN personne P ON A.numActeur = P.numPersonne WHERE prenomPersonne = pPrenomPersonne AND nomPersonne = pNomPersonne;
	END IF;
	RETURN vNumPersonne;
END //

DELIMITER ;
-- END REGION

-- REGION trigger
-- ===============================================================================================================
--   création des triggers (ou déclencheurs)
-- ===============================================================================================================
DELIMITER //

-- A FAIRE...

DELIMITER ;
-- END REGION	


-- REGION tuples
-- ===============================================================================================================
--   insertion des enregistrements relatifs aux pays
-- ===============================================================================================================
INSERT INTO pays (libellePays, libelleHommePays, libelleFemmePays) VALUES 
	("Pays-Bas", "Hollandais", "Hollandaise"),
	("Afrique du sud", "Sud-Africain", "Sud-Africaine"),
	("Allemagne", "Allemand", "Allemande"),
	("Angleterre", "Angalis", "Anglaise"),
	("Argentine", "Argentin", "Argentine"),
	("Australie", "Australien", "Australienne"),
	("Belgique", "Belge", "Belge"),
	("Canada", "Canadien", "Canadienne"),
	("Chine", "Chinois", "Chinoise"),
	("Espagne", "Espagnol", "Espagnole"),
	("France", "Français", "Française"),
	("Inde", "Indien", "Indienne"),
	("Israël", "Israëlien", "Israëlienne"),
	("Irak", "Irakien", "Irakienne"),
	("Italie", "Italien", "Italienne"),
	("Japon", "Japonais", "Japonaise"),
	("Nouvelle-Zelande", "Néo-Zélandais", "Néo-Zélandaise"),
	("Porto Rico", "Porto Ricain", "Porto Ricaine"),
	("Portugal", "Portugais", "Portugaise"),
	("Suede", "Suedois", "Suedoise"),
	("Ukraine", "Ukrainien", "Ukranienne"),
	("Etats-Unis", "Américain", "Américaine");

SELECT numPays INTO @AfriqueDuSud		FROM pays WHERE libellePays = "Afrique du sud";
SELECT numPays INTO @Allemagne 			FROM pays WHERE libellePays = "Allemagne";
SELECT numPays INTO @Angleterre			FROM pays WHERE libellePays = "Angleterre";
SELECT numPays INTO @Argentine			FROM pays WHERE libellePays = "Argentine";
SELECT numPays INTO @Australie			FROM pays WHERE libellePays = "Australie";
SELECT numPays INTO @Belgique 			FROM pays WHERE libellePays = "Belgique";
SELECT numPays INTO @Canada 			FROM pays WHERE libellePays = "Canada";
SELECT numPays INTO @Chine				FROM pays WHERE libellePays = "Chine";
SELECT numPays INTO @Espagne			FROM pays WHERE libellePays = "Espagne";
SELECT numPays INTO @France 			FROM pays WHERE libellePays = "France";
SELECT numPays INTO @Inde				FROM pays WHERE libellePays = "Inde";
SELECT numPays INTO @Israel				FROM pays WHERE libellePays = "Israël";
SELECT numPays INTO @Irak				FROM pays WHERE libellePays = "Irak";
SELECT numPays INTO @Italie				FROM pays WHERE libellePays = "Italie";
SELECT numPays INTO @Japon 				FROM pays WHERE libellePays = "Japon";
SELECT numPays INTO @NouvelleZelande	FROM pays WHERE libellePays = "Nouvelle-Zelande";
SELECT numPays INTO @PortoRico			FROM pays WHERE libellePays = "Porto Rico";
SELECT numPays INTO @Portugal			FROM pays WHERE libellePays = "Portugal";
SELECT numPays INTO @Suede				FROM pays WHERE libellePays = "Suede";
SELECT numPays INTO @Ukraine			FROM pays WHERE libellePays = "Ukraine";
SELECT numPays INTO @Usa 				FROM pays WHERE libellePays = "Etats-Unis";
SELECT numPays INTO @PaysBas 			FROM pays WHERE libellePays = "Pays-Bas";


-- ===============================================================================================================
--   insertion des enregistrements relatifs aux personnes
-- ===============================================================================================================
CALL ajoutPersonne("realisateur",	"Chris",		"Weitz",			null,	"1969-11-30",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Peter",		"Billingsley",		null,	"1971-04-16",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Joe",			"Johnston",			null,	"1950-05-13",	"Fort Worth",				"M", @Usa);
CALL ajoutPersonne("realisateur",	"Garry",		"Marshall",			null,	"1934-11-13",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Martin",		"Scorsese",			null,	"1942-11-19",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Tim",			"Burton",			null,	"1958-08-25",	"Burbank",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Kevin",		"Greutert",			null,	"1965-03-31",	"Pasadena",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Darren Lynn",	"Bousman",			null,	"1979-01-11",	"Overland Park",			"M", @Usa);
CALL ajoutPersonne("realisateur",	"Raja",			"Gosnell",			null,	"1958-12-09",	"Los Angeles",				"M", @Usa);
CALL ajoutPersonne("realisateur",	"Henri",		"Pachard",			null,	"1939-06-04",	"Kansas city",				"M", @Usa);
CALL ajoutPersonne("realisateur",	"James",		"Mangold",			null,	"1963-12-16",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Joel",			"Schumacher",		null,	"1939-08-29",	"New York",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Dennis",		"Dugan",			null,	"1946-09-05",	"Wheaton",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Josh",			"Gordon",			null,	null,			null,						"M", @Usa);
CALL ajoutPersonne("realisateur",	"Douglas",		"McGrath",			null,	"1958-01-01",	null,						"M", @Usa);
CALL ajoutPersonne("realisateur",	"John Erick",	"Dowdle",			null,	"1973-12-10",	null,						"M", @Usa);
CALL ajoutPersonne("realisateur",	"Ron",			"Clements",			null,	"1953-04-25",	"Sioux city",				"M", @Usa);
CALL ajoutPersonne("realisateur",	"Lee",			"Unkrich",			null,	"1967-08-08",	"Cleveland",				"M", @Usa);
CALL ajoutPersonne("realisateur",	"Mike",			"Mitchell",			null,	"1970-01-01",	null,						"M", @Usa);
CALL ajoutPersonne("realisateur",	"Robert",		"Zemeckis",			null,	"1951-05-04",	"Chicago",					"M", @Usa);
CALL ajoutPersonne("realisateur",	"Barthelemy",	"Grossmann",		null,	"1981-10-30",	null,						"M", @France);
CALL ajoutPersonne("realisateur",	"Olivier",		"Dahan",			null,	"1967-06-26",	"La ciotat",				"M", @France);
CALL ajoutPersonne("realisateur",	"Jacques",		"Perrin",			null,	"1941-07-13",	"Paris",					"M", @France);
CALL ajoutPersonne("realisateur",	"Louis",		"Leterrier",		null,	"1973-06-17",	null,						"M", @France);
CALL ajoutPersonne("realisateur",	"Eric",			"Lavaine",			null,	null,			null,						"M", @France);
CALL ajoutPersonne("realisateur",	"Bertrand",		"Blier",			null,	"1939-03-14",	"Paris",					"M", @France);
CALL ajoutPersonne("realisateur",	"Alain",		"Corneau",			null,	"1943-08-07",	"Meung-sur-Loire",			"M", @France);
CALL ajoutPersonne("realisateur",	"Mickael",		"Cohen",			null,	"1970-12-13",	"Maisons-Laffitte", 		"M", @France);
CALL ajoutPersonne("realisateur",	"Xavier",		"Beauvois",			null,	"1967-03-20",	"Auchel",					"M", @France);
CALL ajoutPersonne("realisateur",	"Alexandre",	"Aja",				null,	"1978-08-07",	"Paris",					"M", @France);
CALL ajoutPersonne("realisateur",	"Matthew",		"Vaughn",			null,	"1971-03-07",	"Londres",					"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Christopher",	"Nolan",			null,	"1970-07-30",	"Londres",					"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Guy",			"Ritchie",			null,	"1968-09-10",	"Hatfield",					"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Paul W.S.",	"Anderson",			null,	"1965-03-04",	"Newcastle upon",			"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Rupert",		"Wyatt",			null,	"1972-10-06",	"Exeter",					"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Ridley",		"Scott",			null,	"1937-11-30",	"South Shields",			"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Roger",		"Michell",			null,	"1956-06-05",	"Pretoria",					"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Simon",		"West",				null,	"1961-05-20",	"Letchworth",				"M", @Angleterre);
CALL ajoutPersonne("realisateur",	"Sharon",		"Maguire",			null,	"1960-11-28",	"Aberystwyth",				"F", @Angleterre);
CALL ajoutPersonne("realisateur",	"David",		"Cronenberg",		null,	"1943-03-15",	"Totonto",					"M", @Canada);
CALL ajoutPersonne("realisateur",	"James",		"Cameron",			null,	"1954-08-16",	"Kapuskasing",				"M", @Canada);
CALL ajoutPersonne("realisateur",	"Jason",		"Reitman",			null,	"1977-10-19",	"Montréal",					"M", @Canada);
CALL ajoutPersonne("realisateur",	"Peter",		"Jackson",			null,	"1961-10-31",	"Pukerua Bay",				"M", @NouvelleZelande);
CALL ajoutPersonne("realisateur",	"Martin",		"Campbell",			null,	"1943-10-24",	"Hastings",					"M", @NouvelleZelande);
CALL ajoutPersonne("realisateur",	"Roland",		"Emmerich",			null,	"1955-11-10",	"Stuttgart",				"M", @Allemagne);
CALL ajoutPersonne("realisateur",	"Daniel",		"Stamm",			null,	"1976-04-20",	"Hambourg",					"M", @Allemagne);
CALL ajoutPersonne("realisateur",	"Oren",			"Peli",				null,	"1970-05-10",	null,						"M", @Israel);
CALL ajoutPersonne("realisateur",	"M.Night",		"Shyamalan",		null,	"1970-08-06",	"Pondichéry",				"M", @Inde);
CALL ajoutPersonne("realisateur",	"Hideo",		"Nakata",			null,	"1961-07-19",	"Okayama",					"M", @Japon);
CALL ajoutPersonne("realisateur",	"Jorge",		"Blanco",			null,	null,			null,						"M", @Espagne);
CALL ajoutPersonne("realisateur",	"Phillip",		"Noyce",			null,	"1950-04-29",	"Griffith",					"M", @Australie);
CALL ajoutPersonne("realisateur",	"Ben",			"Stassen",			null,	null,			null,						"M", @Belgique);
CALL ajoutPersonne("realisateur",	"Shawkat Amin",	"Korki",			null,	null,			null,						"M", @Irak);
CALL ajoutPersonne("realisateur",	"Alister",		"Grierson",			null,	null,			null,						"M", @Australie);
CALL ajoutPersonne("realisateur",	"Paulo",		"Rocha",			null,	"1935-12-22",	"Porto",					"M", @Portugal);
CALL ajoutPersonne("realisateur",	"Paul",			"Verhoeven",		null,	"1938-07-18",	"Amsterdam",				"M", @PaysBas);

CALL ajoutPersonne("acteur",		"Renée",		"Zellweger",		160,	"1969-04-25", 	"Katy",						"F", @Usa);
CALL ajoutPersonne("acteur",		"Jeff",			"Goldblum",			160,	"1952-10-22", 	"Pittsburgh",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Bill",			"Pullman",			160,	"1953-12-17", 	"New York",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Jessie",		"Usher",			160,	"1992-02-29", 	"Baltimore",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Maika",		"Monroe",			160,	"1993-05-29", 	"Santa Barbara",			"F", @Usa);
CALL ajoutPersonne("acteur",		"William",		"Fichtner",			160,	"1956-11-27", 	"New York",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Tom",			"Hanks",			160,	"1956-07-09", 	"Oakland",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Gary",			"Sinise",			160,	"1955-03-17", 	"Blue Island",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Robin",		"Wright",			160,	"1966-04-08", 	"Dallas",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Zoe",			"Saldana",			160,	"1978-07-19", 	null,						"F", @Usa);
CALL ajoutPersonne("acteur",		"Sigourney",	"Weaver",			160,	"1949-10-08", 	"New York",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Stephen",		"Lang",				160,	"1952-07-11", 	"New York",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Michelle",		"Rodriguez",		160,	"1978-07-12",	"Bexar County",				"F", @Usa);
CALL ajoutPersonne("acteur",		"Leonardo",		"DiCaprio",			160,	"1974-11-11", 	"Los Angeles",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Mark",			"Ruffalo",			160,	"1967-11-22",	"Kenosha",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Michelle",		"Williams",			160,	"1980-09-09",	"Kalispell",				"F", @Usa);
CALL ajoutPersonne("acteur",		"Arnold",		"Schwarzenegger",	160,	"1947-07-30",	"Thal",						"M", @Usa);
CALL ajoutPersonne("acteur",		"John",			"Cusack",			160,	"1966-06-28",	"Evanston",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Linda",		"Hamilton",			160,	"1956-09-26",	null,						"F", @Usa);
CALL ajoutPersonne("acteur",		"Michael",		"Biehn",			160,	"1956-07-31",	"Anniston",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Danny",		"Glover",			160,	"1946-07-22",	"San francisco",			"M", @Usa);
CALL ajoutPersonne("acteur",		"Julia",		"Roberts",			160,	"1967-10-28", 	"Atlanta",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Randy",		"Couture",			160,	"1963-06-22", 	"Lynnwood",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Steve",		"Austin",			160,	"1964-12-18", 	"Victoria",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Eric",			"Roberts",			160,	"1956-04-18", 	"Biloxi",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Jessica",		"Alba",				160,	"1981-04-28", 	"Pomona ",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Jessica",		"Biel",				160,	"1982-03-03", 	"Ely",						"F", @Usa);
CALL ajoutPersonne("acteur",		"Anne",			"Hathaway",			160,	"1982-11-12", 	"New York",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Jennifer",		"Garner",			160,	"1972-04-17", 	"Houston",					"F", @Usa);
CALL ajoutPersonne("acteur",		"Bradley",		"Cooper",			160,	"1975-01-05", 	"Philadelphie",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Jamie",		"Foxx",				160,	"1967-12-13", 	"Terrell",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Patrick",		"Dempsey",			160,	"1966-01-13", 	"Lewiston",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Ashton",		"Kutcher",			160,	"1978-02-07", 	"Cedar Rapids",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Kristen",		"Stewart",			160,	"1990-04-09", 	"Los Angeles",				"F", @Usa);
CALL ajoutPersonne("acteur",		"Taylor",		"Lautner",			160,	"1992-02-11", 	"Grand Rapids",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Tom",			"Cruise",			160,	"1962-07-03",	"Syracuse",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Ali",			"Larter",			160,	"1976-02-28",	null,						"F", @Usa);
CALL ajoutPersonne("acteur",		"Burt",			"Young",			160,	"1940-04-30",	"New York",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Angelina",		"Jolie",			160,	"1975-06-04",	"Los Angeles",				"F", @Usa);
CALL ajoutPersonne("acteur",		"Cameron",		"Diaz",				160,	"1972-08-30",	"San diego",				"F", @Usa);
CALL ajoutPersonne("acteur",		"Ed",			"Harris",			160,	"1960-11-28",	"Tenafly",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Mel",			"Gibson",			160,	"1956-01-03",	"Peekskill",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Bruce",		"Willis",			160,	"1955-03-19",	"Idar-Oberstein",			"M", @Usa);
CALL ajoutPersonne("acteur",		"Samuel",		"L. Jackson",		160,	"1948-12-21",	"Washington",				"M", @Usa);
CALL ajoutPersonne("acteur",		"Chuck",		"Norris",			160,	"1940-03-10",	"Ryan",						"M", @Usa);
CALL ajoutPersonne("acteur",		"Terry",		"Crews",			160,	"1968-07-30",	"Flint",					"M", @Usa);
CALL ajoutPersonne("acteur",		"Charisma ",	"Carpenter",		160,	"1970-07-23",	null,						"F", @Usa);
CALL ajoutPersonne("acteur",		"Jason",		"Statham",			160,	"1967-07-12", 	"Chesterfield",				"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Colin",		"Firth",			160,	"1960-09-10", 	"Grayshott",				"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Emma",			"Thompson",			160,	"1959-04-15", 	"Londres",					"F", @Angleterre);
CALL ajoutPersonne("acteur",		"Kristin",		"Scott Thomas",		160,	"1960-05-24", 	"Redruth",					"F", @Angleterre);
CALL ajoutPersonne("acteur",		"Emily",		"Mortimer",			160,	"1971-12-01",	"Londres",					"F", @Angleterre);
CALL ajoutPersonne("acteur",		"Thandie",		"Newton",			160,	"1972-11-06",	null,						"F", @Angleterre);
CALL ajoutPersonne("acteur",		"Ben",			"Kingsley",			160,	"1943-12-31",	"Snaiton",					"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Robert",		"Pattinson",		160,	"1986-05-13", 	"Londres",					"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Wentworth",	"Miller",			160,	"1972-06-02",	"Chipping Norton",			"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Kate",			"Winslet",			160,	"1975-10-05",	"Reading",					"F", @Angleterre);
CALL ajoutPersonne("acteur",		"Hugh",			"Grant",			160,	"1960-09-09",	"Londres",					"M", @Angleterre);
CALL ajoutPersonne("acteur",		"Sam",			"Worthington",		160,	"1976-08-02", 	"Godalming",				"M", @Australie);
CALL ajoutPersonne("acteur",		"Cate",			"Blanchett",		160,	"1969-05-14",	"Melbourne",				"F", @Australie);
CALL ajoutPersonne("acteur",		"Kad",			"Merad",			160,	"1964-03-27",	"Sidi Bel Abbes",			"M", @France);
CALL ajoutPersonne("acteur",		"Isabelle",		"Huppert",			160,	"1963-03-16", 	"Paris",					"F", @France);
CALL ajoutPersonne("acteur",		"Laurent",		"lafitte",			160,	"1973-08-22", 	"Paris",					"M", @France);
CALL ajoutPersonne("acteur",		"Anne",			"Consigny",			160,	"1953-05-22", 	"Alençon",					"F", @France);
CALL ajoutPersonne("acteur",		"Charles",		"Berling",			160,	"1958-04-30", 	"Saint-Mandé",				"M", @France);
CALL ajoutPersonne("acteur",		"Gerard",		"Depardieu",		160,	"1948-12-27",	"Chateauroux",				"M", @France);
CALL ajoutPersonne("acteur",		"Clovis",		"Cornillac",		160,	"1967-08-16",	"Lyon",						"M", @France);
CALL ajoutPersonne("acteur",		"Carole",		"Bouquet",			160,	"1957-08-18",	"Neuilly-sur-Seine",		"F", @France);	
CALL ajoutPersonne("acteur",		"Franck",		"Dubosc",			160,	"1963-11-07",	"Petit-Quevilly",			"M", @France);
CALL ajoutPersonne("acteur",		"Valerie",		"Lemercier",		160,	"1964-03-09",	"Dieppe",					"F", @France);
CALL ajoutPersonne("acteur",		"Gerard",		"Darmon",			160,	"1948-02-29",	"Paris",					"M", @France);
CALL ajoutPersonne("acteur",		"Emmanuelle",	"Beart",			160,	"1963-08-14",	"Saint-Tropez",				"F", @France);
CALL ajoutPersonne("acteur",		"Ludivine",		"Sagnier",			160,	"1979-07-03",	"Saint-Cloud",				"F", @France);
CALL ajoutPersonne("acteur",		"Marion",		"Cotillard",		160,	"1975-09-30",	"Paris",					"F", @France);
CALL ajoutPersonne("acteur",		"Dolph",		"Lundgren",			160,	"1957-11-03", 	"Stockholm",				"M", @Suede);
CALL ajoutPersonne("acteur",		"Max",			"von Sydow",		160,	"1929-10-10",	"Lund",						"M", @Suede);
CALL ajoutPersonne("acteur",		"François",		"Damiens",			160,	"1973-01-17",	"Uccle",					"M", @Belgique);
CALL ajoutPersonne("acteur",		"JC",			"Van Damme",		160,	"1960-10-18",	"Berchem-St-Agathe",		"M", @Belgique);
CALL ajoutPersonne("acteur",		"Virginie",		"Efira",			160,	"1977-05-05", 	"Bruxelles",				"F", @Belgique);
CALL ajoutPersonne("acteur",		"David",		"Zayas",			160,	"1969-12-31", 	null,						"M", @PortoRico);
CALL ajoutPersonne("acteur",		"Joaquin",		"Phoenix",			160,	"1974-10-28", 	"San Juan",					"M", @PortoRico);
CALL ajoutPersonne("acteur",		"Jet",			"Li",				160,	"1963-04-26", 	"Pekin",					"M", @Chine);
CALL ajoutPersonne("acteur",		"Russel",		"Crowe",			160,	"1964-04-07",	"Wellington",				"M", @NouvelleZelande);
CALL ajoutPersonne("acteur",		"Milla",		"Jovovich",			160,	"1975-12-17",	"Kiev",						"F", @Ukraine);
CALL ajoutPersonne("acteur",		"Charlize",		"Theron",			160,	"1975-08-07",	"Benoni",					"F", @AfriqueDuSud);
CALL ajoutPersonne("acteur",		"Liam",			"Hemsworth",		160,	"1990-01-13", 	"Melbourne",				"M", @Australie);

CALL ajoutPersonne("polyvalent",	"Sylvester",	"Stallone",			160,	"1946-07-06",	"New-York",					"M", @Usa);
CALL ajoutPersonne("polyvalent",	"Ben",			"Affleck",			160,	"1972-08-15",	"Berkeley",					"M", @Usa);

SELECT numRealisateur INTO @AlexandreAja		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Alexandre"		AND nomPersonne = "Aja";
SELECT numRealisateur INTO @BertrandBlier		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Bertrand"		AND nomPersonne = "Blier";
SELECT numRealisateur INTO @ChristopherNolan	FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Christopher"	AND nomPersonne = "Nolan";
SELECT numRealisateur INTO @DarrenLynnBousman	FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Darren Lynn"	AND nomPersonne = "Bousman";
SELECT numRealisateur INTO @EricLavaine			FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Eric"			AND nomPersonne = "Lavaine";
SELECT numRealisateur INTO @GuyRitchie			FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Guy"			AND nomPersonne = "Ritchie";
SELECT numRealisateur INTO @JamesCameron 		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "James"			AND nomPersonne = "Cameron";
SELECT numRealisateur INTO @JoelSchumacher		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Joel"			AND nomPersonne = "Schumacher";
SELECT numRealisateur INTO @KevinGreutert		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Kevin"			AND nomPersonne = "Greutert";
SELECT numRealisateur INTO @M.NightShyamalan 	FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "M.Night"		AND nomPersonne = "Shyamalan";
SELECT numRealisateur INTO @MartinCampbell		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Martin"		AND nomPersonne = "Campbell";
SELECT numRealisateur INTO @PeterJackson 		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Peter"			AND nomPersonne = "Jackson";
SELECT numRealisateur INTO @RidleyScott 		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Ridley"		AND nomPersonne = "Scott";
SELECT numRealisateur INTO @RobertZemeckis 		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Robert"		AND nomPersonne = "Zemeckis";
SELECT numRealisateur INTO @RolandEmmerich 		FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Roland"		AND nomPersonne = "Emmerich";
SELECT numRealisateur INTO @SylvesterStallone	FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Sylvester"		AND nomPersonne = "Stallone";
SELECT numRealisateur INTO @TimBurton 			FROM realisateur R INNER JOIN personne P ON R.numRealisateur = P.numPersonne WHERE prenomPersonne = "Tim" 			AND nomPersonne = "Burton";


-- ===============================================================================================================
--   insertion des enregistrements relatifs aux genres
-- ===============================================================================================================
INSERT INTO genre (libelleGenre) VALUES 
	("action"), 
	("animation"),
	("aventure"),
	("comédie"),
	("documentaire"),
	("drame"),
	("épouvante/horreur"),
	("érotique"),
	("fantastique"),
	("guerre"),
	("peplum"),
	("policier"),
	("thriller"),
	("western"),
	("science-fiction");

SELECT numGenre INTO @Action			FROM genre WHERE libelleGenre = "action";
SELECT numGenre INTO @Animation			FROM genre WHERE libelleGenre = "animation";
SELECT numGenre INTO @Aventure			FROM genre WHERE libelleGenre = "aventure";
SELECT numGenre INTO @Comedie			FROM genre WHERE libelleGenre = "comédie";
SELECT numGenre INTO @Documentaire		FROM genre WHERE libelleGenre = "documentaire";
SELECT numGenre INTO @Drame				FROM genre WHERE libelleGenre = "drame";
SELECT numGenre INTO @EpouvanteHorreur	FROM genre WHERE libelleGenre = "épouvante/horreur";
SELECT numGenre INTO @Erotique			FROM genre WHERE libelleGenre = "érotique";
SELECT numGenre INTO @Fantastique		FROM genre WHERE libelleGenre = "fantastique";
SELECT numGenre INTO @ScienceFiction	FROM genre WHERE libelleGenre = "science-fiction";
SELECT numGenre INTO @Guerre			FROM genre WHERE libelleGenre = "guerre";
SELECT numGenre INTO @Peplum			FROM genre WHERE libelleGenre = "peplum";
SELECT numGenre INTO @Policier			FROM genre WHERE libelleGenre = "policier";
SELECT numGenre INTO @Thriller			FROM genre WHERE libelleGenre = "thriller";
SELECT numGenre INTO @Western			FROM genre WHERE libelleGenre = "western";


-- ===============================================================================================================
--   insertion des enregistrements relatifs aux films
-- ===============================================================================================================
INSERT INTO film (titreFilm, numPaysFilm, dureeFilm, dateSortieFilm, numGenreFilm, numRealisateurFilm, synopsisFilm) VALUES 
	("Twilight - chapitre 2 - tentation", 					@Usa,				"02:10", "2009-11-18", @Fantastique, 		getNumPersonne("Realisateur", "Chris", "Weitz"),			"\"Tu ne me reverras plus. Je ne reviendrai pas. Poursuis ta vie, ce sera comme si je n'avais jamais existé.\" Abandonnée par Edward, celui qu'elle aime passionnément, Bella ne s'en relève pas. Comment oublier son amour pour un vampire et revenir à une vie normale ? Pour combler son vide affectif, Bella court après le danger et prends des risques de plus en plus inconsidérés. Edward n'étant plus là pour la protéger, c'est Jacob, l'ami discret et indéfectible qui va la défendre et veiller sur elle. Mais peu à peu elle réalise l'ambiguïté des sentiments qu'ils éprouvent l'un envers l'autre..."),  
	("13m2", 												@France,			"01:24", "2007-06-20", @Policier, 			getNumPersonne("Realisateur", "Barthelemy", "Grossmann"),	"Après le braquage d'un fourgon blindé, José, Farouk et Réza se réfugient dans une planque de 13m2. Enfermés avec l'argent, la conscience salie, les liens et les caractères des trois amis se révèlent au fil des mensonges et conflits qu'engendre cette situation oppressante. Chaque sortie dans le monde réel se présente désormais comme une menace, arriveront-ils à déjouer leur destin et à prendre un nouveau départ ?"),
	("Paranormal activity", 								@Usa,				"01:26", "2009-11-11", @EpouvanteHorreur,	getNumPersonne("Realisateur", "Oren", "Peli"),				"Un jeune couple suspecte leur maison d'être hantée par un esprit démoniaque. Ils décident alors de mettre en place une surveillance vidéo durant leur sommeil afin d'enregistrer les évènements nocturnes dont ils sont les victimes."), 
	("Oceans", 												@France,			"01:47", "2010-01-27", @Documentaire, 		getNumPersonne("Realisateur", "Jacques", "Perrin"),			"Filer à 10 noeuds au coeur d'un banc de thons en chasse, accompagner les dauphins dans leurs folles cavalcades, nager avec le grand requin blanc épaule contre nageoire... Le film Océans c'est être poisson parmi les poissons. Après Himalaya et Le Peuple migrateur, Jacques Perrin nous entraîne, avec des moyens de tournage inédits, des banquises polaires aux tropiques, au coeur des océans et de ses tempêtes pour nous faire redécouvrir les créatures marines connues, méconnues, ignorées. Océans s'interroge sur l'empreinte que l'homme impose à la vie sauvage et répond par l'image et l'émotion à la question : \" L'Océan ? C'est quoi l'Océan. \""),
	("Wolfman", 											@Usa,				"01:39", "2010-02-10", @Fantastique, 		getNumPersonne("Realisateur", "Joe", "Johnston"),			"Lawrence Talbot est un aristocrate torturé que la disparition de son frère force à revenir au domaine familial. Contraint de se rapprocher à nouveau de son père, Talbot se lance à la recherche de son frère...et se découvre une terrible destinée. L'enfance de Lawrence Talbot prit fin à la mort de sa mère. Ayant quitté le paisible hameau de Blackmoor, il a passé plusieurs décennies à essayer d'oublier. Mais, sous les suppliques de la fiancée de son frère, Gwen Conliffe, il revient à Blackmoor pour l'aider à retrouver l'homme qu'elle aime. Il y apprend qu'une créature brutale et assoiffée de sang s'affère à décimer les villageois et que Aberline, un inspecteur soupçonneux de Scotland Yard, est là pour mener l'enquête. Réunissant petit à petit les pièces du puzzle sanglant, Talbot découvre une malédiction ancestrale qui transforme ses victimes en loups-garous les nuits de pleine lune. Pour mettre fin au massacre et protéger la femme dont il est tombé amoureux, il doit anéantir la créature macabre qui rôde dans les forêts encerclant Blackmoor. Alors qu'il traque la bête infernale, cet homme hanté par le passé va découvrir une part de lui-même qu'il n'aurait jamais soupçonnée."),
	("Valentine's day", 									@Usa,				"02:03", "2010-02-10", @Comedie, 			getNumPersonne("Realisateur", "Garry", "Marshall"),			"Les destins croisés de couples qui se séparent ou se retrouvent, de célibataires qui se rencontrent à Los Angeles, le jour de Saint-Valentin..."),
	("Le choc des titans", 									@Usa,				"02:15", "2010-04-07", @Fantastique, 		getNumPersonne("Realisateur", "Louis", "Leterrier"),		"La dernière bataille pour le pouvoir met en scène des hommes contre des rois et des rois contre des dieux. Mais la guerre entre les dieux eux-mêmes peut détruire le monde. Né d'un dieu mais élevé comme un homme, Persée ne peut sauver sa famille des griffes de Hadès, dieu vengeur du monde des Enfers. N'ayant plus rien à perdre, Persée se porte volontaire pour conduire une mission dangereuse et porter un coup fatal à Hadès avant que celui-ci ne s'empare du pouvoir de Zeus et fasse régner l'enfer sur terre. A la tête d'une troupe de guerriers courageux, Persée entreprend un périlleux voyage dans les profondeurs des mondes interdits. Luttant contre des démons impies et des bêtes redoutables, il ne survivra que s'il accepte son pouvoir en tant que dieu, qu'il défie son destin et crée sa propre destinée."),
	("Shutter island", 										@Usa,				"02:17", "2010-02-24", @Thriller, 			getNumPersonne("Realisateur", "Martin", "Scorsese"),		"En 1954, le marshal Teddy Daniels et son coéquipier Chuck Aule sont envoyés enquêter sur l'île de Shutter Island, dans un hôpital psychiatrique où sont internés de dangereux criminels. L'une des patientes, Rachel Solando, a inexplicablement disparu. Comment la meurtrière a-t-elle pu sortir d'une cellule fermée de l'extérieur ? Le seul indice retrouvé dans la pièce est une feuille de papier sur laquelle on peut lire une suite de chiffres et de lettres sans signification apparente. Oeuvre cohérente d'une malade, ou cryptogramme !"),
	("My own love song", 									@Usa,				"01:38", "2010-04-07", @Drame, 				getNumPersonne("Realisateur", "Olivier", "Dahan"),			"Jane, une ex-chanteuse devenue handicapée à la suite d'un accident, reçoit des nouvelles de son fils. En effet, Devon reprend contact avec sa mère car il souhaite l'inviter à sa communion. Malgré les craintes de Jane de retrouver son fils après des années et de faire face à son passé, son ami Joey arrive à la convaincre d'entreprendre ce périple à travers les Etats-Unis. C'est au cours de ce voyage et des rencontres qu'ils feront sur la route que Jane composera sa plus belle chanson d'amour."),
	("Thérapie de couples", 								@Usa,				"01:47", "2010-12-24", @Comedie, 			getNumPersonne("Realisateur", "Peter", "Billingsley"),		"Quatre couples d'amis du Midwest embarquent pour une croisière très spéciale sur une île paradisiaque du Pacifique Sud. Le couple à l'origine du voyage a décidé de se rendre à l'Eden, une station balnéaire de luxe, comme dernier recours pour sauver leur mariage. Les trois autres s'apprêtent à profiter des multiples trésors qu'offre ce petit coin de paradis : mer turquoise, plage de sable blanc, jet-ski, spa dernière tendance, etc. Mais ils vont vite se rendre compte que leur participation au programme très original de thérapie de couples que propose l'Eden n'a rien d'optionnel. Soudain, leurs vacances au tarif de groupe ne semblent plus une si bonne affaire que ça."),
	("Kick-ass", 											@Usa,				"01:41", "2010-04-21", @Action, 			getNumPersonne("Realisateur", "Matthew", "Vaughn"),			"Dave Lizewski est un adolescent gavé de comics qui ne vit que pour ce monde de super-héros et d'incroyables aventures. Décidé à vivre son obsession jusque dans la réalité et du coeur. Ils se sont quittés alors qu'ils s'aimaient toujours. Incapable de faire un pas de plus. Cette nuit-là, ils se retrouvent. Jean va replonger dans le souvenir de leur histoire commune et être envahi par le désir de comprendre la raison de cet échec. Jusqu'au petit matin, grâce aux allers-retours entre le passé et le présent, les pièces du puzzle vont s'assembler. Leur histoire n'est peut-être pas terminée..."),
	("Resident evil - afterlife", 							@Usa,				"01:42", "2010-09-22", @EpouvanteHorreur,	getNumPersonne("Realisateur", "Paul W.S.", "Anderson"),		"Dans un monde ravagé par un virus, transformant ses victimes en morts-vivants, Alice continue sa lutte à mort avec Umbrella Corporation. Elle poursuit son voyage à la recherche de survivants et d'un lieu sûr où les mener. Cette quête les mènent à Los Angeles mais ils constatent très vite que la ville est infestée par des milliers de morts-vivants. Alice et ses compagnons (dont un vieil ami inattendu) sont sur le point de tomber dans un piège d'Umbrella."),
	("La mouche", 											@Usa,				"01:36", "1987-01-21", @Fantastique, 		getNumPersonne("Realisateur", "David", "Cronenberg"),		"Seth Brundle est un jeune biologiste très doué. Après avoir fait ses premières armes dans une brillante équipe, il se décide à travailler seul. Il met au point une invention qui doit révolutionner le monde : la \"téléportation\" qui consiste à transporter la matière à travers l'espace. Les essais sur un babouin sont peu convaincants et après des fuites dans la presse, il décide de se téléporter lui-même. Seulement il ne s'apercoit pas qu'une mouche fait partie du voyage."),
	("Ring", 												@Japon,				"01:38", "2001-12-11", @EpouvanteHorreur,	getNumPersonne("Realisateur", "Hideo", "Nakata"),			"Un soir, seules à la maison, deux lycéennes se font peur en se racontant une mauvaise blague. Une étrange rumeur circule à propos d'une cassette vidéo qui, une fois visionnée, déclenche une terrible malédiction : une mort annoncée sept jours plus tard. Après le décès de sa cousine Tomoko Oishi, Reiko Asakawa, une jeune journaliste, enquête, mais très vite le maléfice la rattrape."),
	("Planète 51", 											@Angleterre,		"01:30", "2010-02-03", @Animation, 			getNumPersonne("Realisateur", "Jorge", "Blanco"),			"Tout est normal sur la Planète 51. Le ciel est bleu, les habitants sont vert pomme et les Cadillacs volent. Lorsque Chuck, un astronaute aussi futé qu'une huître, y déboule avec sa fusée, les habitants s'enfuient en hurlant. Une invasion extraterrestre, au secours ! L'armée aux trousses, Chuck se carapate. Lem, un gamin aussi vert que brave, va tenter de sauver cet être étrange des griffes du général Grawl."),
	("In the air", 											@Usa,				"01:50", "2010-01-27", @Comedie, 			getNumPersonne("Realisateur", "Jason", "Reitman"),			"L'odyssée de Ryan Bingham, un spécialiste du licenciement à qui les entreprises font appel pour ne pas avoir à se salir les mains. Dans sa vie privée, celui-ci fuit tout engagement (mariage, propriété, famille) jusqu'à ce que sa rencontre avec deux femmes ne le ramène sur terre. Ryan Bingham est un collectionneur compulsif de miles aériens cumulés lors de ses incessants voyages d'affaire. Misanthrope, il adore cette vie faite d'aéroports, de chambres d'hôtel et de voitures de location. Lui dont les besoins tiennent à l'intérieur d'une seule valise est même à deux doigts d'atteindre un des objectifs de sa vie : les 10 millions de miles. Alors qu'il tombe amoureux d'une femme rencontrée lors d'un de ses nombreux voyages, il apprend par la voix de son patron que ses méthodes de travail vont devoir évoluer. Inspiré par une nouvelle jeune collaboratrice très ambitieuse, celui-ci décide que les licenciements vont pouvoir se faire de manière encore plus rentable, via... vidéo conférence. Ce qui risque évidemment de limiter ces voyages que Bingham affectionne tant..."),
	("La princesse et la grenouille", 						@Usa,				"01:37", "2010-01-27", @Animation, 			getNumPersonne("Realisateur", "Ron", "Clements"),			"Un conte qui se déroule à la Nouvelle-Orléans, dans le légendaire quartier français, où vit une jeune fille nommée Tiana."),
	("Le dernier exorcisme", 								@Usa,				"01:27", "2010-09-15", @EpouvanteHorreur, 	getNumPersonne("Realisateur", "Daniel", "Stamm"),			"Quand il arrive dans une ferme, le révérend Cotton Marcus s'attend à réaliser un simple exorcisme sur un fanatique religieux troublé. Cependant, il est contacté en dernier recours pour aider une adolescente, Nell, possédée par un démon. En arrivant à la ferme, l'exorciste se rend vite compte que rien n'aurait pu le préparer au mal qu'il va affronter alors qu'il s'apprête à filmer un documentaire avec toute une équipe de tournage. Il est cependant trop tard pour faire marche arrière, les croyances du révérend seront ébranléées quand lui et son équipe devront trouver un moyen de sauver Nell avant qu'il ne soit trop tard pour elle...comme pour eux."),
	("Salt", 												@Usa,				"01:41", "2010-08-25", @Thriller, 			getNumPersonne("Realisateur", "Phillip", "Noyce"),			"Evelyn Salt est sans aucun doute l'un des meilleurs agents que la CIA ait jamais comptés dans ses rangs. Pourtant, lorsque la jeune femme est accusée d'être une espionne au service de la Russie, elle doit fuir. Evelyn Salt va faire appel à sa remarquable expertise pour échapper à ceux qui la traquent, y compris dans son propre camp. En cherchant à percer le secret de ceux qui la visent, Salt va brouiller toutes les pistes. Est-elle vraiment ce qu'elle prétend ! Désormais, une seule question se pose : qui est Salt !"),
	("Toy story 3", 										@Usa,				"01:40", "2010-07-14", @Animation, 			getNumPersonne("Realisateur", "Lee", "Unkrich"),			"Les créateurs des très populaires films Toy Story ouvrent à nouveau le coffre à jouets et invitent les spectateurs à retrouver le monde délicieusement magique de Woody et Buzz au moment où Andy s'apprète à partir pour l'université. Délaissée, la plus célèbre bande de jouets se retrouve... à la crèche ! Les bambins déchaînés et leurs petits doigts capables de tout arracher sont une vraie menace pour nos amis ! Il devient urgent d'échafauder un plan pour leur échapper au plus vite. Quelques nouveaux venus vont se joindre à la Grande évasion, dont l'éternel séducteur et célibataire Ken, compagnon de Barbie, un hérisson comédien nommé Larosse, et un ours rose parfumé à la fraise appelé Lotso."),
	("The town", 											@Usa,				"02:03", "2010-09-15", @Thriller, 			getNumPersonne("Realisateur", "Ben", "Affleck"),			"Doug MacRay est un criminel impénitent, le leader de facto d'une impitoyable bande de braqueurs de banque qui s'ennorgueillit de voler à leur gré sans se faire prendre. Sans attaches particuliàres, Doug ne craint jamais la perte d'un être cher. Mais tout va changer le jour où, lors du dernier casse de la bande, ils prennent en otage la directrice de la banque, Claire Keesey. Bien qu'ils l'aient relâchée indemne, Claire est nerveuse car elle sait que les voleurs connaissent son nom... et savent où elle habite. Mais elle baisse la garde le jour où elle rencontre un homme discret et plutôt charmant du nom de Doug... ne réalisant pas qu'il est celui qui, quelques jours plus tôt, l'avait terrorisée. L'attraction instantanée entre eux va se transformer graduellement en une romance passionnée qui menacera de les entraîner tous deux sur un chemin dangereux et potentiellement mortel."),
	("Le voyage extraordinaire de Samy", 					@Belgique,			"01:25", "2010-08-11", @Animation, 			getNumPersonne("Realisateur", "Ben", "Stassen"),			"Alors qu'il se hisse hors de son nid sur une plage de Californie, Samy, petite tortue des mers, trouve et perd dans la foulée l'amour de sa vie : la jeune Shelly. Au cours de son périple à travers les océans qu'accomplissent toutes les tortues de mer avant de retrouver la plage qui les a vus naitre, Samy n'a de cesse de faire face à tous les dangers afin de retrouver Shelly. Accompagné de son meilleur ami Ray, ils sont des observateurs privilégiés de la façon dont l'homme affecte la planète. Mais il est alors secouru par ces mêmes humains. Il combat des piranhas, échappe à un aigle et part à la recherche d'un mystérieux passage secret. Un jour, enfin, après toutes ces aventures, Samy retrouve Shelly. Elle non plus ne l'a pas oublié..."),
	("Crime d'amour", 										@France,			"01:44", "2010-08-18", @Thriller, 			getNumPersonne("Realisateur", "Alain", "Corneau"),			"Dans le décor aseptisé des bureaux d'une puissante multinationale, deux femmes s'affrontent... La jeune Isabelle travaille sous les ordres de Christine, une femme de pouvoir qu'elle admire sans réserve. Convaincue de son ascendant sur sa protégée, Christine entraîne Isabelle dans un jeu trouble et pervers de séduction et de domination. Ce jeu dangereux va trop loin... jusqu'au point de non retour."),
	("Le cristal d'amour", 									@Usa,				"01:30", "1990-08-20", @Erotique, 			getNumPersonne("Realisateur", "Henri", "Pachard"),			"En des temps très anciens qui rappellent ceux de la Préhistoire, une amazone pulpeuse se met en quête du cristal d'amour, une pierre magique aux vertus aphrodisiaques qui vient d'être dérobée par un guerrier du clan adverse..."),
	("A travers la poussière", 								@France,			"01:16", "2009-04-15", @Drame,				getNumPersonne("Realisateur", "Shawkat Amin", "Korki"),		"Pendant l'invasion de l'Irak par les Américains en 2003, les combattants kurdes (Peshmergas) luttent contre les troupes de Saddam Hussein dans des conditions chaotiques. Deux d'entre eux, Azad et Rashid, sont chargés d'une mission de ravitaillement. Ils partent au front dans un camion chargé de nourriture. Ils trouvent un garçon arabe de 5 ans perdu sur la route. Azad, dont le jeune frère fut tué lors d'une opération de Saddam Hussein contre les Kurdes, veut ramener le jeune garçon chez lui. Rashid s'y oppose. Il veut d'abord remplir sa mission. Et lui qui voue une haine farouche au dictateur découvre que le jeune garçon s'appelle Saddam !"),
	("Des hommes et des dieux", 							@France,			"02:00", "2010-09-08", @Drame,				getNumPersonne("Realisateur", "Xavier", "Beauvois"),		"Un monastère perché dans les montagnes du Maghreb, dans les années 1990. Huit moines chrétiens français vivent en harmonie avec leurs fràres musulmans. Quand une équipe de travailleurs étrangers est massacrée par un groupe islamiste, la terreur s'installe dans la région. L'armée propose une protection aux moines, mais ceux-ci refusent. Doivent-ils partir ? Malgré les menaces grandissantes qui les entourent, la décision des moines de rester coûte que coûte, se concrétise jour après jour... Ce film s'inspire librement de la vie des Moines Cisterciens de Tibhirine en Algérie de 1993 jusqu'à leur enlèvement en 1996."),
	("Shrek 4, il était une fin", 							@Usa,				"01:33", "2010-06-30", @Animation,			getNumPersonne("Realisateur", "Mike", "Mitchell"),			"Après avoir vaincu un méchant dragon, sauvé une belle princesse et le royaume de ses parents, que peut encore faire un ogre malodorant et mal léché ? Domestiqué, assagi, Shrek a perdu jusqu'à l'envie de rugir et regrette le bon vieux temps où il semait la terreur dans le royaume. Aujourd'hui, tel une idole déchue, il se contente de signer des autographes à tour de bras. Trop triste... C'est alors que l'habile et sournois Tracassin lui propose un contrat. Shrek se retrouve soudain transporté dans un monde parallèle totalement déjanté où les ogres sont pourchassés, où Tracassin est roi, où Fiona et son bien-aimé ne se jamais rencontrés... Shrek va-t-il réussir à déjouer le sortilège, à repasser de l'autre côté du miroir, à sauver ses amis, à retrouver son monde et reconquérir l'amour de sa vie !"),
	("Night and day", 										@Usa,				"01:40", "2010-07-28", @Action,				getNumPersonne("Realisateur", "James", "Mangold"),			"Lorsque June rencontre Roy, elle croit que le destin lui sourit enfin et qu'elle a trouvé l'homme de ses rêves. Pourtant, très vite, elle le suspecte d'être un espion et le cauchemar commence. Elle se retrouve traquée avec lui dans une coursepoursuite à travers la planète qui ne leur laisse aucun répit. Leur vie ne tient qu'à un fil et le danger est partout. Pour avoir une chance de s'en sortir, June et Roy doivent se faire confiance au point de se confier leurs vies. Mais est-ce bien raisonnable ?"),
	("Copains pour toujours", 								@Usa,				"01:42", "2010-09-08", @Comedie,			getNumPersonne("Realisateur", "Dennis", "Dugan"),			"Après trente ans sans se voir, cinq copains d'enfance se retrouvent pour partager un week-end avec femmes et enfants. Leurs relations reprennent là où elles en étaient restées trois décennies plus tôt, et ils vont vite découvrir que vieillir ne signifie pas forcément grandir..."),
	("Une famille très moderne", 							@Usa,				"01:42", "2010-08-25", @Comedie,			getNumPersonne("Realisateur", "Josh", "Gordon"),			"Kassie est une new-yorkaise célibataire, intelligente et dynamique. En dépit des avertissements de son meilleur ami, le sympathique mais légèrement névrosé Wally, elle décide qu'il est grand temps d'avoir un enfant - et cela même si aucun père n'est présent à l'horizon car elle a déjà sélectionné le donneur idéal : le charmant Roland. Alors que Kassie organise une grande soirée pour fêter sa future insémination, un Wally complètement ivre, va procéder à un échange de dernière minute qui va mettre à mal l'organisation parfaite de la future maman. Le lendemain, alors qu'il est victime d'une gueule de bois carabinée, Wally a tout oublié. Sept ans plus tard, lorsque Kassie revient à New York avec son fils, Wally va réaliser qu'il y a une troublante ressemblance entre le petit garçon et lui..."),
	("Mais comment font les femmes", 						@Usa,				"01:30", "2011-09-21", @Comedie,			getNumPersonne("Realisateur", "Douglas", "McGrath"),		"Kate est mariée, a deux enfants et un job épuisant. Professionnelle jusqu'au bout des ongles, elle jongle avec un emploi du temps de ministre pour concilier son travail, l'éducation de ses enfants et sa vie de couple. Sa vie est une succession de mini-cataclysmes auxquels elle doit trouver des solutions : comment réussir une conférence-call en préparant le diner de ses enfants ! Comment arriver à se faire des soirées entre copines quand le petit dernier est malade ! Comment être sexy avec son mari après 12h au bureau ! Mais comment font les femmes ! Si c'était si simple, les hommes feraient pareil..."),
	("Sanctum", 											@Usa,				"01:45", "2011-02-23", @Aventure,			getNumPersonne("Realisateur", "Alister", "Grierson"),		"Plongeur expert, Frank McGuire se lance dans l'exploration à haut risque des grottes immergées d'Esa'ala, dans le Pacifique sud. Il emmène avec lui entre autres son fils de dix-sept ans, Josh, et le milliardaire Carl Hurley, qui finance l'expédition. L'équipe s'engage dans le plus vaste, le plus mystérieux et le plus inaccessible des réseaux de grottes du monde. Lorsqu'une tempète tropicale s'abat sur la zone, ils sont obligés de s'enfoncer dans le labyrinthe sous-marin pour lui échapper. Désormais perdus dans un décor incroyable, ils doivent absolument trouver une issue avant qu'il ne soit trop tard. Ce monde inconnu ne leur pardonnera aucune erreur..."),
	("Les schtroumpfs",										@Usa,				"01:44", "2011-08-03", @Animation,	 		getNumPersonne("Realisateur", "Raja", "Gosnell"),			"Chassés de leur village par Gargamel, le méchant sorcier, les Schtroumpfs se retrouvent au beau milieu de Central Park à travers un portail magique."),
	("Devil", 												@Usa,				"01:20", "2011-04-20", @EpouvanteHorreur, 	getNumPersonne("Realisateur", "John Erick", "Dowdle"),		"A Philadelphie, cinq individus débutent leur journée le plus banalement du monde. Ils pénètrent dans un immeuble de bureaux et montent dans l'ascenseur. Personne ne se connaît ni ne se salue. Ils n'auront à partager cet espace clos que pour un court instant. Mais, quand l'ascenseur reste bloqué, ce qui semblait aléatoire, s'avère vite parfaitement intentionnel, et leur sort ne leur appartient plus. Ces cinq inconnus vont voir leurs secrets exposés au grand jour, et chacun va devoir répondre de ses fautes. Doucement, méthodiquement, leur situation évolue de la simple contrariété à l'angoisse, puis à l'horreur totale. Un à un, l'adversité les frappe, alors que le doute quant à l'identité de l'auteur de ces terribles événements plane sur toutes les têtes... jusqu'à ce qu'ils comprennent la vérité : l'un d'eux est le diable en personne. Quand toute assistance venue de l'extérieur s'avère inutile, les passagers restants sont forcés de réaliser que leur seule chance de s'en sortir est de faire face aux crimes qui les ont menés là où ils sont aujourd'hui."),
	("Coup de foudre à Notting Hill", 						@Angleterre,		"02:03", "1999-08-18", @Comedie, 			getNumPersonne("Realisateur", "Roger", "Michell"),			"Quand un matin, Anna Scott, l'actrice la plus célèbre d'Hollywood, pousse la porte de la librairie de William Thacket, située dans le charmant quartier de Notting Hill, à l'ouest de Londres, le libraire ignore que commence une grande aventure. Par une série de hasards comme seul le destin peut en mettre en scène, William et Anna vivent une rencontre étonnante, attachante. Lorsque la star le rappelle quelque temps plus tard, William n'ose y croire."),
	("Expendables 2 - unité spéciale", 						@Usa,				"01:42", "2012-08-22", @Action, 			getNumPersonne("Realisateur", "Simon", "West"),				"Les Expendables sont de retour, et cette fois, la mission les touche de très près... Lorsque Mr. Church engage Barney Ross, Lee Christmas, Yin Yang, Gunnar Jensen, Toll Road et Hale Caesar - et deux nouveaux, Billy The Kid et Maggie - l'opération semble facile. Mais quand l'un d'entre eux est tué, les Expendables jurent de le venger. Bien qu'en territoire hostile et donnés perdants, ils vont semer le chaos chez leurs adversaires, et se retrouver à tenter de déjouer une menace inattendue - cinq tonnes de plutonium capables de modifier l'équilibre des forces mondiales. Cette guerre-là n'est pourtant rien comparée à ce qu'ils vont faire subir à l'homme qui a sauvagement assassiné leur frère d'armes..."),
	("Bridget Jones Baby",									@Usa,				"01:55", "2016-10-05", @Comedie,			getNumPersonne("Realisateur", "Sharon", "Maguire"),			"Après avoir rompu avec Mark Darcy, Bridget se retrouve de nouveau célibataire, 40 ans passés, plus concentrée sur sa carrière et ses amis que sur sa vie amoureuse. Pour une fois, tout est sous contrôle ! Jusqu’à ce que Bridget fasse la rencontre de Jack... Puis retrouve Darcy... Puis découvre qu’elle est enceinte... Mais de qui ???"),
	("Elle",												@France,			"02:10", "2016-05-25", @Thriller,			getNumPersonne("Realisateur", "Paul", "Verhoeven"),			"Michèle fait partie de ces femmes que rien ne semble atteindre. A la tête d'une grande entreprise de jeux vidéo, elle gère ses affaires comme sa vie sentimentale : d'une main de fer. Sa vie bascule lorsqu’elle est agressée chez elle par un mystérieux inconnu. Inébranlable, Michèle se met à le traquer en retour. Un jeu étrange s'installe alors entre eux. Un jeu qui, à tout instant, peut dégénérer."),
	("Haute tension", 										@France,			"01:35", "2003-06-18", @EpouvanteHorreur, 	@AlexandreAja, 		"Marie, une étudiante de vingt ans, révise ses examens dans la ferme isolée des parents de sa meilleure amie. En l'espace d'une nuit, un tueur, qui ignore son existence, assassine à tour de rôle les membres de cette famille..."),
	("La colline a des yeux", 								@France,			"01:43", "2006-06-21", @EpouvanteHorreur, 	@AlexandreAja, 		"Pour fêter leur anniversaire de mariage, Big Bob Carter, un ancien policier de Cleveland, et sa femme Ethel ont demandé à leur famille de partir avec eux en Californie. Big Bob est sûr que faire la route tous ensemble les aidera à resserrer des liens familiaux un peu distendus. Même si tout le monde vient, personne n'est vraiment ravi d'être là. Lynn, la fille aînée, s'inquiète du confort de son bébé. Son mari, Doug, redoute de passer trop de temps près de son beau-père. La jeune Brenda regrette de ne pas être allée faire la fête à Cancun avec ses amis. Et Bobby ne s'intéresse qu'aux deux chiens de la famille. Une route désertique va conduire les Carter vers le pire des cauchemars..."),
	("Piranha 3D", 											@Usa,				"01:29", "2010-09-01", @EpouvanteHorreur, 	@AlexandreAja, 		"Alors que la ville de Lake Victoria s'appréte à recevoir des milliers d'étudiants pour le week-end de Pâques, un tremblement de terre secoue la ville et ouvre, sous le lac, une faille d'où des milliers de piranhas s'échappent. Inconscients du danger qui les guette, tous les étudiants font la fête sur le lac tandis que Julie, la shérif, découvre un premier corps dévoré... La journée va être d'autant plus longue pour elle que Jake, son fils, a délaissé la garde de ses jeunes frères et soeurs pour servir de guide à bord du bateau des sexy Wild Wild Girls !"),
	("Mirrors", 											@Usa,				"01:51", "2008-09-10", @EpouvanteHorreur, 	@AlexandreAja,		"Un ancien flic, forcé de démissionner de son travail après un accident ayant couté la vie de son associé, travaille à présent comme veilleur de nuit dans un grand magasin brûlé et abandonné. Seuls quelques miroirs ont survécu aux flammes. Il réalise que ceux-ci cachent un horrible secret qui les menace, lui et sa famille."),
	("Les côtelettes", 										@France,			"01:26", "2003-05-28", @Drame, 				@BertrandBlier, 	"Le Vieux et Léonce, deux hommes d'un âge certain, discutent de la vie, de la mort, des femmes ou encore du sexe. Tous les deux vont être troublés par l'apparition de Nacifa, leur jeune et nouvelle femme de ménage maghrébine."),
	("Les valseuses", 										@France,			"01:55", "1974-03-20", @Drame, 				@BertrandBlier, 	"Liés par une forte amitié, deux revoltés en cavale veulent vivre à fond leurs aventures. Cette fuite sera ponctuée de provocations et d'agressions mais également de rencontres, tendres instants de bonheur éphémères."),
	("Merci la vie", 										@France,			"01:57", "1991-03-13", @Drame, 				@BertrandBlier, 	"La randonnée de deux jeunes filles, sur les routes, pendant l'occupation allemande..."),
	("Le bruit des glaçons", 								@France,			"01:27", "2010-08-25", @Drame, 				@BertrandBlier, 	"C'est l'histoire d'un homme qui reçoit la visite de son cancer. \"Bonjour, lui dit le cancer, je suis votre cancer. Je me suis dit que ça serait peut-être pas mal de faire un petit peu connaissance...\""),
	("Batman begins", 										@Usa,				"02:19", "2005-06-15", @Fantastique, 		@ChristopherNolan,	"Comment un homme seul peut-il changer le monde ! Telle est la question qui hante Bruce Wayne depuis cette nuit tragique où ses parents furent abattus sous ses yeux, dans une ruelle de Gotham City. Torturé par un profond sentiment de colère et de culpabilité, le jeune héritier de cette richissime famille fuit Gotham pour un long et discret voyage à travers le monde. Le but de ses pérégrinations : sublimer sa soif de vengeance en trouvant de nouveaux moyens de lutter contre l'injustice."),
	("Le prestige", 										@Usa,				"02:08", "2006-11-15", @Thriller, 			@ChristopherNolan,	"Londres, au début du siècle dernier... Robert Angier et Alfred Borden sont deux magiciens surdoués, promis dès leur plus jeune âge à un glorieux avenir. Une compétition amicale les oppose d'abord l'un à l'autre, mais l'émulation tourne vite à la jalousie, puis à la haine. Devenus de farouches ennemis, les deux rivaux vont s'efforcer de se détruire l'un l'autre en usant des plus noirs secrets de leur art. Cette obsession aura pour leur entourage des conséquences dramatiques..."),
	("The dark knight, le chevalier noir", 					@Usa,				"02:27", "2008-08-13", @Action, 			@ChristopherNolan, 	"Dans ce nouveau volet, Batman augmente les mises dans sa guerre contre le crime. Avec l'appui du lieutenant de police Jim Gordon et du procureur de Gotham, Harvey Dent, Batman vise à éradiquer le crime organisé qui pullule dans la ville. Leur association est très efficace mais elle sera bientôt bouleversée par le chaos déclenché par un criminel extraordinaire que les citoyens de Gotham connaissent sous le nom de Joker."),
	("Inception", 											@Usa,				"01:37", "2010-07-21", @Thriller, 			@ChristopherNolan,	"Un patron d'une entreprise est pris pour cible suite à ses travaux sur l'architecture de l'esprit."),
	("Saw 2", 												@Usa,				"01:35", "2005-12-28", @EpouvanteHorreur,	@DarrenLynnBousman, "Chargé de l'enquète autour d'une mort sanglante, l'inspecteur Eric Mason est persuadé que le crime est l'oeuvre du redoutable Jigsaw, un criminel machiavélique qui impose à ses victimes des choix auxquels personne ne souhaite jamais être confronté. Cette fois-ci, ce ne sont plus deux mais huit personnes qui ont été piégées par Jigsaw..."),
	("Saw 3", 												@Usa,				"01:47", "2006-11-22", @EpouvanteHorreur,	@DarrenLynnBousman, "Le Tueur au puzzle a mystérieusement échappé à ceux qui pensaient le tenir. Pendant que la police se démène pour tenter de remettre la main dessus, le génie criminel a décidé de reprendre son jeu terrifiant avec l'aide de sa protégée, Amanda... Le docteur Lynn Denlon et Jeff ne le savent pas encore, mais ils sont les nouveaux pions de la partie qui va commencer..."),
	("Saw 4", 												@Usa,				"01:30", "2007-11-21", @EpouvanteHorreur,	@DarrenLynnBousman, "Le Tueur au puzzle et sa protégée, Amanda, ont disparu, mais la partie continue. Après le meurtre de l'inspectrice Kerry, deux profileurs chevronnés du FBI, les agents Strahm et Perez, viennent aider le détective Hoffman à réunir les pièces du dernier puzzle macabre laissé par le Tueur pour essayer, enfin, de comprendre. C'est alors que le commandant du SWAT, Rigg, est enlevé... Forcé de participer au jeu mortel, il n'a que 90 minutes pour triompher d'une série de pièges machiavéliques et sauver sa vie. En cherchant Rigg à travers la ville, le détective Hoffman et les deux profileurs vont découvrir des cadavres et des indices qui vont les conduire à l'ex-femme du Tueur, Jill. L'histoire et les véritables intentions du Tueur au puzzle vont peu à peu être dévoilées, ainsi que ses plans sinistres pour ses victimes passées, présentes... et futures."),
	("Poltergay", 											@France,			"01:33", "2006-10-25", @Comedie, 			@EricLavaine, 		"Beaux, jeunes et amoureux... Marc et Emma sont les nouveaux propriétaires d'une maison inhabitée depuis trente ans. Ils ignorent que la cave de la maison a abrité, il y a bien longtemps, une boîte de nuit gay. Le 29 avril 1979 à 2 heures du matin, suite à un incident électrique avec la machine à mousse, en pleine fête disco, la boîte a été dévastée. Parmi les danseurs, cinq corps n'ont jamais été retrouvés. Aujourd'hui, la maison est hantée par cinq fantômes fêtards, taquins et gays. Marc les voit. Emma ne les voit pas. Les \"visions\" de Marc vont précipiter le départ d'Emma. Marc se retrouve seul avec ses interrogations. Touchés par cet homme à la dérive, les fantômes vont l'aider à reconquérir Emma."),
	("Incognito", 											@France,			"01:34", "2009-04-29", @Comedie, 			@EricLavaine, 		"Lucas est devenu une superstar en s'étant approprié les chansons d'un ami qu'il croyait disparu. Soudainement, cet ami réapparait. Lucas, pour lui cacher sa fortune et sa célébrité, commet l'erreur de demander à Francis, un comédien raté, de prendre sa place."),
	("Bienvenue à bord", 									@France,			"01:30", "2011-10-05", @Comedie, 			@EricLavaine, 		"Isabelle, DRH d'une grande compagnie maritime, a commis l'erreur de choisir pour amant son patron. Avant d'embarquer pour la croisière inaugurale du fleuron de la flotte, il décide de la débarquer de sa vie et de son boulot ! Certaines femmes se vengent par le poison, l'arme à feu, ou la calomnie. Elle, elle choisit Rémy, chômeur flamboyant qui a tout raté sur terre et qui se dit qu'après tout sur mer.... Isabelle le recrute comme animateur. Il va d'abord se révéler être le pire cauchemar du PDG et du Directeur de Croisière, puis, peu à peu sur ce palais des mers, Rémy va trouver sa voie, l'amour et le succès. Il changera sa vie et celle de tous ceux qui croiseront sa route à bord..."),
	("Protéger et servir", 									@France,			"01:30", "2010-02-03", @Policier, 			@EricLavaine, 		"Kim Houang et Michel Boudriau sont deux flics \"à la vie à la mort\" depuis qu'ils se sont croisés à l'orphelinat. Michel Boudriau est un flic très marqué par l'éducation catholique qu'il a reçu à l'orphelinat. De cet enseignement salutaire, il a retenu des valeurs qui font honneur à la police française : le pardon, le partage, la compassion.... Kim Houang a été adopté à la naissance par un couple de restaurateurs vietnamiens avant d'être placé à l'orphelinat... Kim a conservé quelques traits hérités de sa petite enfance dans la communauté asiatique, notamment un amour immodéré pour cet art millénaire qu'est le karaoké. Kim a plusieurs gros soucis dans la vie, il est maladivement radin et plaît beaucoup aux filles à physique difficile... Ce ne sont pas les meilleurs flics de France, ni de la région parisienne, ni de leur commissariat... et pourtant ce sont eux qui, sous les ordres d'Aude Lettelier, directeur de la police nationale, sont chargés de déjouer une vague d'attentats qui touche notre beau pays."),
	("A la dérive", 										@Italie,			"01:30", "2003-05-21", @Drame, 				@GuyRitchie, 		"Amber, une femme fortunée, gâtée par son mari, et quelques amis louent un yacht pour faire une croisière sur la Méditerranée pendant l'été. Parmi l'équipage figure Giuseppe, un marin communiste qui n'apprécie guère les caprices de cette femme riche. Un jour, celle-ci se réveille tard dans l'après midi et demande au marin de l'emmener rejoindre ses amis qui ont fait une escale. Malheureusement, le petit bateau à moteur sur lequel ils avaient embarqué tombe en panne. Après avoir dérivé toute la nuit, ils accostent sur une île déserte. Amber est alors obligée de se plier aux volontés de Giuseppe..."),
	("Sherlock holmes 2 - jeu d'ombres", 					@Usa,				"02:07", "2012-01-25", @Action, 			@GuyRitchie, 		"Sherlock Holmes a toujours été réputé pour être l'homme à l'esprit le plus affûté de son époque. Jusqu'au jour où le redoutable professeur James Moriarty, criminel d'une puissance intellectuelle comparable à celle du célèbre détective, fait son entrée en scène... Il a même sans doute un net avantage sur Holmes car il met non seulement son intelligence au service de noirs desseins, mais il est totalement dépourvu de sens moral. Partout dans le monde, la presse s'enflamme : on apprend ainsi qu'en Inde un magnat du coton est ruiné par un scandale, ou qu'en Chine un trafiquant d'opium est décédé, en apparence, d'une overdose, ou encore que des attentats se sont produits à Strasbourg et à Vienne et qu'aux Etats-Unis, un baron de l'acier vient de mourir... Personne ne voit le lien entre ces événements qui semblent sans rapport, hormis le grand Sherlock Holmes qui y discerne la même volonté maléfique de semer la mort et la destruction. Et ces crimes portent tous la marque du sinistre Moriarty. Tandis que leur enquête les mêne en France, en Allemagne et en Suisse, Holmes et Watson prennent de plus en plus de risques. Mais Moriarty a systématiquement un coup d'avance et semble tout près d'atteindre son objectif. S'il y parvient, non seulement sa fortune et son pouvoir seront sans limite, mais le cours de l'Histoire pourrait bien en être changé à jamais..."),
	("Sherlock holmes", 									@Usa,				"02:08", "2010-02-03", @Animation, 			@GuyRitchie, 		"Aucune énigme ne résiste longtemps à Sherlock Holmes... Flanqué de son fidèle ami le Docteur John Watson, l'intrépide et légendaire détective traque sans relâche les criminels de tous poils. Ses armes : un sens aigu de l'observation et de la déduction, une érudition et une curiosité tous azimuts; accessoirement, une droite redoutable... Mais une menace sans précédent plane aujourd'hui sur Londres - et c'est exactement le genre de challenge dont notre homme a besoin pour ne pas sombrer dans l'ennui et la mélancolie. Après qu'une série de meurtres rituels a ensanglanté Londres, Holmes et Watson réussissent à intercepter le coupable : Lord Blackwood. A l'approche de son éxécution, ce sinistre adepte de la magie noire annonce qu'il reviendra du royaume des morts pour exercer la plus terrible des vengeances. La panique s'empare de la ville après l'apparente résurrection de Blackwood. Scotland Yard donne sa langue au chat, et Sherlock Holmes se lance aussitôt avec fougue dans la plus étrange et la plus périlleuse de ses enquêtes..."),
	("True lies", 											@Usa,				"02:24", "1994-10-12", @Action, 			@JamesCameron, 		"Comment un agent secret va reconquérir sa femme qui ignore tout des activités secrètes de son époux et le trouve bien fade en Monsieur-tout-le-monde..."),
	("Aliens le retour", 									@Usa,				"02:17", "1986-10-08", @Fantastique, 		@JamesCameron, 		"Après 57 ans de dérive dans l'espace, Ellen Ripley est secourue par la corporation Weyland-Yutani. Malgré son rapport concernant l'incident survenu sur le Nostromo, elle n'est pas prise au sérieux par les militaires quant à la présence de xénomorphes sur la planète LV-426 où se posa son équipage où plusieurs familles de colons ont été envoyées en mission de \"terraformage\". Après la disparition de ces derniers, Ripley décide d'accompagner une escouade de marines dans leur mission de sauvetage... et d'affronter à nouveau la Bête."),
	("Terminator", 											@Usa,				"01:48", "1985-04-24", @Fantastique, 		@JamesCameron, 		"A Los Angeles en 1984, un Terminator, cyborg surgi du futur, a pour mission d'exécuter Sarah Connor, une jeune femme dont l'enfant à naître doit sauver l'humanité. Kyle Reese, un résistant humain, débarque lui aussi pour combattre le robot, et aider la jeune femme..."),
	("Terminator2 - le jugement dernier", 					@Usa,				"02:15", "1991-10-16", @Fantastique, 		@JamesCameron, 		"En 2029, après leur échec pour éliminer Sarah Connor, les robots de Skynet programment un nouveau Terminator, le T-1000, pour retourner dans le passé et éliminer son fils John Connor, futur leader de la résistance humaine. Ce dernier programme un autre cyborg, le T-800, et l'envoie également en 1995, pour le protéger. Une seule question déterminera le sort de l'humanité : laquelle des deux machines trouvera John la première !"),
	("Titanic", 											@Usa,				"03:14", "1998-01-07", @Drame, 				@JamesCameron, 		"Southampton, 10 avril 1912. Le paquebot le plus grand et le plus moderne du monde, réputé pour son insubmersibilité, le Titanic, appareille pour son premier voyage. Quatre jours plus tard, il heurte un iceberg. A son bord, un artiste pauvre et une grande bourgeoise tombent amoureux."),
	("Abyss", 												@Usa,				"02:45", "1989-09-27", @Fantastique, 		@JamesCameron, 		"Un commando de la Marine américaine débarque à bord de la station de forage sous-marine DeepCore, afin de porter secours à un sous-marin échoué dans les profondeurs. L'équipe de Bud Brigman accueille ces nouveaux arrivants, ainsi que Lindsey, future ex-femme de Bud. Alors que les travaux de récupération commencent autour du submersible naufragé, l'équipage de DeepCore doit faire face à des phénomènes inexpliqués. Et s'ils n'étaient pas seuls, dans les abysses !"),
	("Avatar", 												@Usa,				"02:41", "2009-12-16", @Fantastique, 		@JamesCameron,		"Malgré sa paralysie, Jake Sully, un ancien marine immobilisé dans un fauteuil roulant, est resté un combattant au plus profond de son être. Il est recruté pour se rendre à des années-lumière de la Terre, sur Pandora, où de puissants groupes industriels exploitent un minerai rarissime destiné à résoudre la crise énergétique sur Terre. Parce que l\'atmosphère de Pandora est toxique pour les humains, ceux-ci ont créé le Programme Avatar, qui permet à des 'pilotes' humains de lier leur esprit à un avatar, un corps biologique commandé à distance, capable de survivre dans cette atmosphère létale. Ces avatars sont des hybrides créés génétiquement en croisant l'ADN humain avec celui des Na'vi, les autochtones de Pandora. Sous sa forme d'avatar, Jake peut de nouveau marcher. On lui confie une mission d'infiltration auprès des Na'vi, devenus un obstacle trop conséquent à l'exploitation du précieux minerai. Mais tout va changer lorsque Neytiri, une très belle Na'vi, sauve la vie de Jake..."),
	("Le nombre 23", 										@Usa,				"01:40", "2007-02-28", @Thriller, 			@JoelSchumacher,	"Walter menait une vie paisible, jusqu'à ce qu'il découvre un étrange roman, Le Nombre 23. D'abord intrigué par ce thriller, Walter s'aperçoit rapidement qu'il existe des parallèles troublants entre l'intrigue et sa propre vie. Peu à peu, l'univers du livre envahit sa réalité jusqu'à l'obsession. Comme Fingerling, le détective de l'histoire, Walter est chaque jour plus fasciné par le pouvoir caché que semble détenir le nombre 23. Ce nombre est partout dans sa vie, et Walter est de plus en plus convaincu qu'il est condamné à commettre le même meurtre que Fingerling... Des images cauchemardesques se mettent à le hanter, celles du terrible destin de sa femme et d'un de leurs amis, Isaac French. Walter ne pourra plus échapper au mystère de ce livre. Ce n'est qu'en découvrant le secret du nombre 23 qu'il aura une chance de changer son destin..."),
	("Le fantôme de l'opéra", 								@Usa,				"02:20", "2005-01-12", @Fantastique, 		@JoelSchumacher,	"Au XIXe siècle, dans les fastes du Palais Garnier, l'Opéra de Paris, Christine, soprano vedette, est au sommet de sa gloire. Son succès est dû à sa voix d'or et aux mystérieux conseils qu'elle reçoit d'un \"Ange\", un fantôme qui vit dans les souterrains du bâtiment. L'homme, un génie musical défiguré qui vit reclus et hante l'opéra, aime la jeune fille d'un amour absolu et exclusif. Lorsque Raoul entre dans la vie de Christine, le Fantôme ne le supporte pas..."),
	("Twelve", 												@Usa,				"01:35", "2010-09-08", @Drame, 				@JoelSchumacher,	"Des adolescents riches et désabusés, des fêtes sans joie, des parents absents, un peu de dope pour le grand frisson et parmi eux, White Mike, jeune dealer qui vient de quitter son école privée de l'Upper East Side à New York. White Mike ne fume pas, ne boit pas, ne va pas dans les fêtes, sauf pour vendre sa nouvelle drogue, le Twelve. Notre histoire commence quand Charlie, le cousin de White Mike, est assassiné... et se terminera lors d'un anniversaire, dans la violence et la perdition."),
	("Saw 3D", 												@Usa,				"01:41", "2010-11-10", @EpouvanteHorreur,	@KevinGreutert,		"Alors que les héritiers de Jigsaw se livrent à un combat sans merci, certains des survivants de ses pièges se tournent vers une espèce de gourou porteur de secrets qui déclenchent une nouvelle vague de terreur."),
	("Saw 6", 												@Usa,				"01:30", "2009-11-04", @EpouvanteHorreur,	@KevinGreutert,		"L'agent spécial Strahm est mort, et le détective Hoffman s'impose alors comme le légataire incontesté de l'héritage de Jigsaw. Cependant, tandis que le FBI se rapproche de plus en plus dangereusement de lui, Hoffman est obligé de commencer un nouveau jeu qui révélera enfin quel est le véritable grand dessein derrière les machinations de Jigsaw..."),
	("Green lantern", 										@Usa,				"01:54", "2011-08-10", @Action, 			@MartinCampbell,	"Dans un univers aussi vaste que mystérieux, une force aussi petite que puissante est en place depuis des siècles : des protecteurs de la paix et de la justice appelés Green Lantern Corps, une confrérie de guerriers qui a juré de maintenir l'ordre intergalactique, et dont chaque membre porte un anneau lui conférant des super-pouvoirs. Mais quand un ennemi du nom de Parallax menace de rompre l'équilibre entre les forces de l'univers, leur destin et celui de la Terre repose sur leur dernière recrue, le premier humain jamais choisi : Hal Jordan. Hal est un pilote d'essai talentueux et imprudent, mais les Green Lanterns ont un peu de respect pour les humains, qui n'ont jamais exploité les pouvoirs infinis de l'anneau auparavant. Hal est clairement la pièce manquante du puzzle et il possède, en plus de sa détermination et de sa volonté, une chose qu'aucun des autres membres n'a jamais eu : son humanité. Soutenu par son amour d'enfance, le pilote Carol Ferris, Hal doit rapidement maîtriser ses nouveaux pouvoirs et vaincre ses peur, pour prouver qu'il n'est pas que la clé pour vaincre Parallax... mais peut-être le plus grand Green Lantern de tous les temps."),
	("Hors de controle", 									@Usa,				"01:27", "2010-02-17", @Thriller, 			@MartinCampbell,	"Thomas Craven est un inspecteur vétéran de la brigade criminelle de Boston. Il élève seul sa fille de vingt-cinq ans. Lorsque celle-ci est retrouvée assassinée sur les marches de sa propre maison, personne n'a de doute : c'est lui qui était visé. Pour découvrir qui a tué sa fille, l'inspecteur Craven va devoir s'aventurer dans les milieux troubles où les affaires côtoient la politique. Il va aussi devoir découvrir les secrets de celle qu'il croyait connaître. Dans cet univers où chaque intérêt est supérieur, où chaque information vaut plusieurs vies, face à l'éminence grise du gouvernement envoyée pour effacer les preuves, la quête solitaire de Craven va le conduire au-delà de la pire enquête de sa vie, face à ses propres démons..."),
	("Phénomènes", 											@Usa,				"01:30", "2008-06-11", @Fantastique, 		@M.NightShyamalan, 	"Surgi de nulle part, le phénomène frappe sans discernement. Il n'y a aucun signe avant-coureur. En quelques minutes, des dizaines, des centaines de gens meurent dans des circonstances étranges, terrifiantes, totalement incompréhensibles. Qu'est-ce qui provoque ce bouleversement radical et soudain du comportement humain ! Est-ce une nouvelle forme d'attaque terroriste, une expérience qui a mal tourné, une arme toxique diabolique, un virus qui a échappé à tout contrôle ! Et comment cette menace se propage-t-elle ! Par l'air, par l'eau, ou autrement ! Pour Elliot Moore, professeur de sciences dans un lycée de Philadelphie, ce qui compte est d'abord d'échapper à ce phénomène aussi mystérieux que mortel. Avec sa femme, Alma, ils fuient en compagnie d'un ami, professeur de mathématiques, et de sa fille de huit ans. Très vite, il devient évident que personne n'est plus en sécurité nulle part. Il n'y a aucun moyen d'échapper à ce tueur invisible et implacable. Pour avoir une mince chance de survivre, Elliot et les siens doivent à tout prix comprendre la véritable nature du phénomène, et découvrir ce qui a déchaîné cette force qui menace l'avenir même de l'espèce humaine..."),
	("Signes", 												@Usa,				"01:45", "2002-10-16", @Fantastique, 		@M.NightShyamalan, 	"A Bucks County, en Pennsylvanie. Après la perte de sa femme, Graham Hess a rendu sa charge de pasteur. Tout en s'occupant de sa ferme, il tente d'élever de son mieux ses deux enfants, Morgan et Bo. Son jeune frère Merrill, une ancienne gloire du base-ball, est revenu vivre avec lui pour l'aider. Un matin, la petite famille découvre l'apparition dans ses champs de gigantesques signes et cercles étranges. Des extra-terrestres seraient-ils à l'origine de tels phénomènes surnaturels ! Graham et Merrill vont s'efforcer de percer le mystère qui entoure ces dessins."),
	("Incassable", 											@Usa,				"01:46", "2000-12-27", @Fantastique, 		@M.NightShyamalan, 	"Elijah Price souffre depuis sa naissance d'une forme d'ostéogénèse. S'il reçoit le moindre choc, ses os cassent comme des brindilles. Depuis son enfance, il n'a de cesse d'admirer les superhéros, des personnages qui sont tout l'opposé de lui-même. Propriétaire d'un magasin spécialisé dans les bandes-dessinées, il épluche pendant son temps libre les vieux articles de journaux à la recherche des plus grands désastres qui ont frappé les Etats-Unis. Il se met alors en quête d'éventuels survivants, mais y parvient rarement. Au même moment, un terrible accident ferroviaire fait 131 morts. Un seul des passagers en sort indemne..."),
	("Sixième sens", 										@Usa,				"01:47", "2000-01-05", @Fantastique, 		@M.NightShyamalan, 	"Cole Sear, garconnet de huit ans est hanté par un terrible secret. Son imaginaire est visité par des esprits menaçants. Trop jeune pour comprendre le pourquoi de ces apparitions et traumatisé par ces pouvoirs paranormaux, Cole s'enferme dans une peur maladive et ne veut reveler à personne la cause de son enfermement, à l'exception d'un psychologue pour enfants. La recherche d'une explication rationnelle guidera l'enfant et le thérapeute vers une vérité foudroyante et inexplicable."),
	("Le dernier maitre de l'air", 							@Usa,				"01:52", "2010-07-21", @Action, 			@M.NightShyamalan, 	"Un étrange et irresponsable personnage, successeur d'une longue lignée d'Avatars, est chargé d'empêcher la nation du Feu de conquérir celles de l'Eau, de la Terre et de l'Air."),
	("King kong", 											@Usa,				"03:00", "2005-12-14", @Aventure, 			@PeterJackson, 		"New York, 1933. Ann Darrow est une artiste de music-hall dont la carrière a été brisée net par la Dépression. Se retrouvant sans emploi ni ressources, la jeune femme rencontre l'audacieux explorateur-réalisateur Carl Denham et se laisse entraîner par lui dans la plus périlleuse des aventures... Ce dernier a dérobé à ses producteurs le négatif de son film inachevé. Il n'a que quelques heures pour trouver une nouvelle star et l'embarquer pour Singapour avec son scénariste, Jack Driscoll, et une équipe réduite. Objectif avoué : achever sous ces cieux lointains son génial film d'action. Mais Denham nourrit en secret une autre ambition, bien plus folle : être le premier homme à explorer la mystérieuse Skull Island et à en ramener des images. Sur cette île de légende, Denham sait que \"quelque chose\" l'attend, qui changera à jamais le cours de sa vie..."),
	("Bad taste", 											@NouvelleZelande,	"01:32", "1987-03-15", @EpouvanteHorreur,	@PeterJackson, 		"Une petite ville côtière de Nouvelle-Zélande est le théâtre d'une invasion extraterrestre : les aliens ont effet décidé d'utiliser les habitants comme viande de première qualité pour leur fast-food spatial..."),
	("Braindead", 											@NouvelleZelande,	"01:44", "1993-01-27", @EpouvanteHorreur,	@PeterJackson, 		"Lionel Cosgrove, un jeune homme timide flanqué d'une mère envahissante fait la connaissance de la belle Paquita, dont il tombe amoureux. Ce qui n'est pas du goût de sa chère maman, bien décidée à gâcher cette relation. Alors qu'elle espionne l'un de leurs rendez-vous galants au zoo, cette dernière est mordue par un singe-rat de Sumatra. Succombant à ses blessures, elle se transforme alors en zombie cannibale et contamine peu à peu la ville. Seul Lionel peut stopper l'invasion..."),
	("Fantômes contre fantômes", 							@NouvelleZelande,	"01:40", "1997-01-29", @Fantastique, 		@PeterJackson, 		"Un architecte médium arnaque les habitants de sa ville avec l'aide de ses amis revenants. Lorsque plusieurs habitants ont des infarctus, il est le coupable idéal aux yeux de la population. Il va devoir faire appel aux fantômes pour s'en sortir et affronter un véritable spectre-tueur..."),
	("Le seigneur des anneaux - la communauté de l'anneau",	@Usa,				"02:45", "2001-12-19", @Fantastique, 		@PeterJackson, 		"La trilogie Le Seigneur des anneaux débutera le 19 décembre 2001 avec La Communauté de l'anneau et se poursuivra avec Les Deux tours le 18 décembre 2002 pour s'achever avec Le Retour du roi le 17 décembre 2003. Dans ce chapitre de la trilogie, le jeune et timide Hobbit, Frodon Sacquet, hérite d'un anneau. Bien loin d'être une simple babiole, il s'agit de l'Anneau Unique, un instrument de pouvoir absolu qui permettrait à Sauron, le Seigneur des ténèbres, de régner sur la Terre du Milieu et de réduire en esclavage ses peuples. A moins que Frodon, aidé d'une Compagnie constituée de Hobbits, d'Hommes, d'un Magicien, d'un Nain, et d'un Elfe, ne parvienne à emporter l'Anneau à travers la Terre du Milieu jusqu'à la Crevasse du Destin, lieu où il a été forgé, et à le détruire pour toujours. Un tel périple signifie s'aventurer très loin en Mordor, les terres du Seigneur des ténàbres, où est rassemblée son armée d'Orques maléfiques... La Compagnie doit non seulement combattre les forces extérieures du mal mais aussi les dissensions internes et l'influence corruptrice qu'exerce l'Anneau lui-même. L'issue de l'histoire à venir est intimement liée au sort de la Compagnie."),
	("Le seigneur des anneaux - les deux tours", 			@Usa,				"02:58", "2002-12-18", @Fantastique, 		@PeterJackson, 		"Après la mort de Boromir et la disparition de Gandalf, la Communauté s'est scindée en trois. Perdus dans les collines d'Emyn Muil, Frodon et Sam découvrent qu'ils sont suivis par Gollum, une créature versatile corrompue par l'Anneau. Celui-ci promet de conduire les Hobbits jusqu'à la Porte Noire du Mordor. A travers la Terre du Milieu, Aragorn, Legolas et Gimli font route vers le Rohan, le royaume assiégé de Theoden. Cet ancien grand roi, manipulé par l'espion de Saroumane, le sinistre Langue de Serpent, est désormais tombé sous la coupe du malfaisant Magicien. Eowyn, la nièce du Roi, reconnaît en Aragorn un meneur d'hommes. Entretemps, les Hobbits Merry et Pippin, prisonniers des Uruk-hai, se sont échappés et ont découvert dans la mystérieuse Forêt de Fangorn un allié inattendu : Sylvebarbe, gardien des arbres, représentant d'un ancien peuple végétal dont Saroumane a décimé la forêt..."),
	("Le seigneur des anneaux - le retour du roi", 			@Usa,				"03:20", "2003-12-17", @Fantastique, 		@PeterJackson, 		"Les armées de Sauron ont attaqué Minas Tirith, la capitale de Gondor. Jamais ce royaume autrefois puissant n'a eu autant besoin de son roi. Mais Aragorn trouvera-t-il en lui la volonté d'accomplir sa destinée ! Tandis que Gandalf s'efforce de soutenir les forces brisées de Gondor, Théoden exhorte les guerriers de Rohan à se joindre au combat. Mais malgré leur courage et leur loyauté, les forces des Hommes ne sont pas de taille à lutter contre les innombrables légions d'ennemis qui s'abattent sur le royaume... Chaque victoire se paye d'immenses sacrifices. Malgré ses pertes, la Communauté se jette dans la bataille pour la vie, ses membres faisant tout pour détourner l'attention de Sauron afin de donner à Frodon une chance d'accomplir sa quête. Voyageant à travers les terres ennemies, ce dernier doit se reposer sur Sam et Gollum, tandis que l'Anneau continue de le tenter..."),
	("Lovely bones", 										@Usa,				"02:08", "2010-02-10", @Drame, 				@PeterJackson, 		"L'histoire d'une jeune fille assassinée qui, depuis l'au-delà, observe sa famille sous le choc de sa disparition et surveille son meurtrier, ainsi que la progression de l'enquête..."), 
	("Mensonges d'état", 									@Usa,				"02:08", "2008-11-05", @Action, 			@RidleyScott, 		"Ancien journaliste blessé pendant la guerre en Irak, Roger Ferris est recruté par la CIA pour traquer un terroriste basé en Jordanie. Afin d'infiltrer son réseau, Ferris devra s'assurer le soutien du très roué vétéran de la CIA Ed Hoffman et du chef des renseignements jordaniens, peut-être trop serviable pour être honnête. Bien que ces deux là soient censés être ses alliés, Ferris s'interroge : jusqu'où peut-il leur faire confiance sans mettre toute son opération - et sa vie - en danger !"),
	("Une grande année", 									@Usa,				"01:58", "2007-01-03", @Drame, 				@RidleyScott, 		"Max Skinner, un banquier d'affaires anglais, hérite du vignoble provençal où il passait autrefois ses vacances d'été aux côtés de son oncle. Il y retrouve Francis Duflot, le vigneron qu'il a connu enfant et qui veille depuis trente ans sur les cépages. Alors qu'il prend possession de ses terres, Max apprend qu'il est suspendu suite à une de ses transactions douteuses. Il se résout à s'installer quelque temps dans la propriété. Sachant qu'un château et un vignoble peuvent valoir plusieurs millions de dollars si le vin est bon, il envisage de vendre. Pourtant, il faut se rendre à l'évidence : le domaine ne produit qu'une horrible vinasse. Max commence peu à peu à goûter la douceur de la vie provençale, mais une jeune Californienne, Christie Roberts, débarque soudain et prétend qu'elle est la fille illégitime de l'oncle décédé, ce qui pourrait faire d'elle l'héritièère du domaine..."),
	("La chute du faucon noir", 							@Usa,				"02:23", "2002-02-20", @Guerre, 			@RidleyScott, 		"Le 3 octobre 1993, avec l'appui des Nations Unies, une centaine de marines américains de la Task Force Ranger est envoyée en mission à Mogadiscio, en Somalie, pour assurer le maintien de la paix et capturer les deux principaux lieutenants et quelques autres associés de Mohamed Farrah Aidid, un chef de guerre local. Cette opération de routine vire rapidement au cauchemar lorsque les militaires sont pris pour cibles par les factions armées rebelles et la population, résolument hostiles à toute présence étrangère sur leur territoire."),
	("Les associés", 										@Usa,				"01:56", "2003-09-17", @Drame, 				@RidleyScott, 		"Deux professionnels de l'arnaque à la petite semaine - Roy, le vétéran du tandem, et Franck, son jeune et ambitieux émule - fourguent à des coûts prohibitifs des \"systèmes de filtrage d'eau\" bas de gamme, assortis de lots alléchants : voitures, bijoux ou croisières tropicales, que leurs victimes ne collecteront bien sûr jamais. Ces opéérations sont juteuses, mais la vie privée de Roy est moins reluisante. Agoraphobe et sujet à des tics obsessionnels compulsifs, il consulte un psy pour continuer à fonctionner. C'est alors qu'il découvre avec horreur qu'il a une fille - une enfant dont il soupçonnait l'existence, mais qu'il n'avait jamais cherché à rencontrer. Pis, Angela, 14 ans, n'a qu'une envie : retrouver son père. L'arrivée impromptue de l'adolescente bouleverse les routines névrotiques de Roy, mais passé le choc initial, celui-ci commence à prendre goût à sa tardive paternité..."),
	("Gladiator", 											@Usa,				"02:35", "2000-06-20", @Peplum, 			@RidleyScott, 		"Le général romain Maximus est le plus fidèle soutien de l'empereur Marc Aurèle, qu'il a conduit de victoire en victoire avec une bravoure et un dévouement exemplaires. Jaloux du prestige de Maximus, et plus encore de l'amour que lui voue l'empereur, le fils de MarcAurèle, Commode, s'arroge brutalement le pouvoir, puis ordonne l'arrestation du général et son exécution. Maximus échappe à ses assassins mais ne peut empêcher le massacre de sa famille. Capturé par un marchand d'esclaves, il devient gladiateur et prépare sa vengeance."),
	("Alien, le huitième passager", 						@Usa,				"01:56", "1979-09-12", @Fantastique, 		@RidleyScott, 		"Le vaisseau commercial Nostromo et son équipage, sept hommes et femmes, rentrent sur Terre avec une importante cargaison de minerai. Mais lors d'un arrêt forcé sur une planète déserte, l'officier Kane se fait agresser par une forme de vie inconnue, une arachnide qui étouffe son visage. Après que le docteur de bord lui retire le spécimen, l'équipage retrouve le sourire et dîne ensemble. Jusqu'à ce que Kane, pris de convulsions, voit son abdomen perforé par un corps étranger vivant, qui s'échappe dans les couloirs du vaisseau..."),
	("Thelma et louise", 									@Usa,				"02:09", "1991-05-29", @Drame, 				@RidleyScott, 		"Deux amies, Thelma et Louise, frustrées par une existence monotone l'une avec son mari, l'autre avec son petit ami, décident de s'offrir un week-end sur les routes magnifiques de l'Arkansas. Premier arrêt, premier saloon, premiers ennuis et tout bascule. Un évènement tragique va changer définitivement le cours de leurs vies."),
	("1492 - Christophe Colomb", 							@Usa,				"02:42", "1992-10-12", @Fantastique, 		@RidleyScott, 		"Evocation de la vie de l'homme qui decouvrit le continent americain le 12 octobre 1492."),
	("Prometheus", 											@Usa,				"02:03", "2012-05-30", @Fantastique, 		@RidleyScott, 		"Une équipe d'explorateurs découvre un indice sur l'origine de l'humanité sur Terre. Cette découverte les entraîne dans un voyage fascinant jusqu'aux recoins les plus sombres de l'univers. Là-bas, un affrontement terrifiant qui décidera de l'avenir de l'humanité les attend."),
	("Robin des bois", 										@Usa,				"02:20", "2010-05-12", @Aventure, 			@RidleyScott, 		"A l'aube du treizième siècle, Robin Longstride, humble archer au service de la Couronne d'Angleterre, assiste, en Normandie, à la mort de son monarque, Richard Coeur de Lion, tout juste rentré de la Troisième Croisade et venu défendre son royaume contre les Français. De retour en Angleterre et alors que le prince Jean, frère cadet de Richard et aussi inepte à gouverner qu'obnubilé par son enrichissement personnel, prend possession du trône, Robin se rend à Nottingham où il découvre l'étendue de la corruption qui ronge son pays. Il se heurte au despotique shérif du comté, mais trouve une alliée et une amante en la personne de la belle et impétueuse Lady Marianne, qui avait quelques raisons de douter des motifs et de l'identité de ce croisé venu des bois. Robin entre en résistance et rallie à sa cause une petite bande de maraudeurs dont les prouesses de combat n'ont d'égal que le goût pour les plaisirs de la vie. Ensemble, ils vont s'efforcer de soulager un peuple opprimé et pressuréâ sans merci, de ramener la justice en Angleterre et de restaurer la gloire d'un royaume menacé par la guerre civile. Brigand pour les uns, héros pour les autres, la légende de \"Robin des bois\" est née."),
	("Forrest gump", 										@Usa,				"02:20", "1994-10-05", @Drame, 				@RobertZemeckis, 	"Quelques décennies d'histoire américaine, des années 1940 à la fin du XXème siècle, à travers le regard et l'étrange odyssée d'un homme simple et pur, Forrest Gump."),
	("Apparences", 											@Usa,				"02:09", "2000-09-13", @Fantastique, 		@RobertZemeckis, 	"Le docteur Norman Spencer et sa femme Claire habitent une somptueuse residence sur les berges d'un lac de la Nouvelle-Angleterre. Tout va pour le mieux mais Claire se sent seule. Sa fille est partie a l'universite et son mari consacre tout son temps a ses recherches. Elle entend un jour gemir et pleurer sa nouvelle voisine, Mme Feur, et tente de prendre contact avec elle. Mais elle se heurte a M. Feur, qui lui refuse l'acces a la maison. Au cours de la nuit, elle voit ce dernier charger un grand sac dans sa voiture. Au fil des jours, Claire est assaillie par des sensations etranges."),
	("Contact", 											@Usa,				"02:33", "1997-09-17", @Drame, 				@RobertZemeckis, 	"Ellie Arroway, passionnée depuis sa plus tendre enfance par l'univers, est devenue une jeune et brillante astronome. Avec une petite équipe de chercheurs elle écoute le ciel et guette un signe d'intelligence extraterrestre. Un jour, ils captent un message.Le docteur Norman Spencer et sa femme Claire habitent une somptueuse residence sur les berges d'un lac de la Nouvelle-Angleterre. Tout va pour le mieux mais Claire se sent seule. Sa fille est partie a l'universite et son mari consacre tout son temps a ses recherches. Elle entend un jour gemir et pleurer sa nouvelle voisine, Mme Feur, et tente de prendre contact avec elle. Mais elle se heurte a M. Feur, qui lui refuse l'acces a la maison. Au cours de la nuit, elle voit ce dernier charger un grand sac dans sa voiture. Au fil des jours, Claire est assaillie par des sensations etranges."),
	("Retour vers le futur", 								@Usa,				"01:56", "1985-09-23", @Fantastique, 		@RobertZemeckis, 	"1985. Le jeune Marty McFly mène une existence anonyme auprès de sa petite amie Jennifer, seulement troublée par sa famille en crise et un proviseur qui serait ravi de l'expulser du lycée. Ami de l'excentrique professeur Emmett Brown, il l'accompagne un soir tester sa nouvelle expérience : le voyage dans le temps via une DeLorean modifiée. La démonstration tourne mal : des trafiquants d'armes débarquent et assassinent le scientifique. Marty se réfugie dans la voiture et se retrouve transporté en 1955. Là, il empêche malgré lui la rencontre de ses parents, et doit tout faire pour les remettre ensemble, sous peine de ne pouvoir exister..."),
	("Anonymous", 											@Angleterre,		"02:18", "2012-01-04", @Thriller, 			@RolandEmmerich, 	"C'est l'une des plus fascinantes énigmes artistiques qui soit, et depuis des siècles, les plus grands érudits tentent de percer son mystère. De Mark Twain à Charles Dickens en passant par Sigmund Freud, tous se demandent qui a réellement écrit les oeuvres attribuées à William Shakespeare. Les experts s'affrontent, d'innombrables théories parfois extrêmes ont vu le jour, des universitaires ont voué leur vie à prouver ou à démystifier la paternité artistique des plus célèbres oeuvres de la littérature anglaise. A travers une histoire incroyable mais terriblement plausible, \"Anonymous\" propose une réponse aussi captivante qu'impressionnante. Au coeur de l'Angleterre élisabéthaine, dans une époque agitée d'intrigues politiques, de scandales, de romances illicites à la Cour, et de complots d'aristocrates avides de pouvoir, voici comment ces secrets furent exposés au grand jour dans le plus improbable des lieux : le théâtre..."),
	("10000", 												@AfriqueDuSud,		"01:49", "2008-03-12", @Aventure,			@RolandEmmerich, 	"10 000 ans avant notre ère, au coeur des montagnes... Le jeune chasseur D'Leh aime d'amour tendre la belle Evolet, une orpheline que sa tribu recueillit quelques années plus tôt. Lorsque celle-ci est enlevée par une bande de pillards, D'Leh se lance à sa rescousse à la tête d'une poignée de chasseurs de mammouths. Le groupe, franchissant pour la première fois les limites de son territoire, entame un long périple à travers des terres infestées de monstres, et découvre des civilisations dont il ne soupçonnait pas l'existence. Au fil de ces rencontres, d'autres tribus, spoliées et asservies, se joignent à D'Leh et ses hommes, finissant par constituer une petite armée. Au terme de leur voyage, D'Leh et les siens découvrent un empire inconnu, hérissé d'immenses pyramides dédiées à un dieu vivant, tyrannique et sanguinaire. Le jeune chasseur comprend alors que sa mission n'est pas seulement de sauver Evolet, mais la civilisation tout entière..."),
	("Le jour d'après", 									@Usa,				"02:05", "2004-05-29", @Action, 			@RolandEmmerich, 	"Le climatologue Jack Hall avait prédit l'arrivée d'un autre âge de glace, mais n'avait jamais pensé que cela se produirait de son vivant. Un changement climatique imprévu et violent à l'échelle mondiale entraîne à travers toute la planète de gigantesques ravages : inondations, grêle, tornades et températures d'une magnitude inédite. Jack a peu de temps pour convaincre le Président des Etats-Unis d'évacuer le pays pour sauver des millions de personnes en danger, dont son fils Sam. A New York où la température est inférieure à - 20° C, Jack entreprend une périlleuse course contre la montre pour sauver son fils."),
	("Godzilla", 											@Usa,				"02:20", "1998-09-16", @Fantastique, 		@RolandEmmerich, 	"Une tempête effroyable se dechaîne sur le Pacifique, engloutissant un pétrolier tandis qu'un immense éclair illumine le ciel au-dessus de la Polynésie française. Des empreintes géantes creusent un inquiétant sillon à travers des milliers de kilomètres de forêts et de plages au Panama. Les navires chavirent au large des côtes américaines et ces horribles phénomènes s'approchent de plus en plus près de New York. Le chercheur Nick Tatopoulos est arraché à ses recherches afin d'aider les Etats-Unis à traquer le monstre qui est à l'origine de ces désastres mystérieux."),
	("2012", 												@Usa,				"02:40", "2009-11-11", @Fantastique, 		@RolandEmmerich, 	"Jamais une date n'avait été aussi importante pour de nombreuses cultures, religions, scientifiques et gouvernements. \"2012\" raconte l'héroïque bataille d'un groupe de survivants à la suite d'un cataclysme planétaire..."),  
	("Rambo 3", 											@Usa,				"01:40", "1988-10-16", @Action, 			@SylvesterStallone, "Le Colonel Trautman contacte Rambo dans sa retraite en Thaïlande pour qu'il l'accompagne dans une mission périlleuse en Afghanistan. Mais l'ex-soldat refuse afin de se consacrer aux moines bouddhistes qui l'ont recueilli. Lorsque, quelques jours plus tard, l'agent Griggs lui explique que Trautman a été capturé par le Colonel Zaysen, Rambo décide de sauver son ami. Il s'infiltre dans les lignes ennemies et découvre toute l'horreur du conflit qui oppose les moudjahidin à l'armée soviétique. Déterminé, il s'attaque à toute une armée sans oublier son objectif premier : récupérer Trautman."),
	("John Rambo", 											@Usa,				"01:30", "2008-02-06", @Action, 			@SylvesterStallone, "John Rambo s'est retiré dans le nord de la Thaïlande, où il mène une existence simple dans les montagnes et se tient à l'écart de la guerre civile qui fait rage non loin de là, sur la frontière entre la Thaïlande et le Myanmar. Il pêche et capture des serpents venimeux pour les vendre. La violence du monde le rattrape lorsqu'un groupe de volontaires humanitaires mené par Sarah et Michael Bennett vient le trouver pour qu'il les guide jusqu'à un camp de réfugiés auquel ils veulent apporter une aide médicale et de la nourriture. Rambo finit par accepter et leur fait remonter la rivière, vers l'autre côté de la frontière. Deux semaines plus tard, le pasteur Arthur Marsh lui apprend que les volontaires ne sont pas revenus et que les ambassades refusent de l'aider à les retrouver. Rambo sait mieux que personne ce qu'il faut faire dans ce genre de situation..."),
	("Rocky Balboa", 										@Usa,				"01:45", "2007-01-24", @Action, 			@SylvesterStallone, "Rocky Balboa, le légendaire boxeur, a depuis longtemps quitté le ring. De ses succès, il ne reste plus que des histoires qu'il raconte aux clients de son restaurant. La mort de son épouse lui pèse chaque jour et son fils ne vient jamais le voir. Le champion d'aujourd'hui s'appelle Mason Dixon, et tout le monde s'accorde à le définir comme un tueur sans élégance ni coeur. Alors que les promoteurs lui cherchent désespérément un adversaire à sa taille, la légende de Rocky refait surface. L'idée d'opposer deux écoles, deux époques et deux titans aussi différents enflamme tout le monde. Pour Balboa, c'est l'occasion de ranimer les braises d'une passion qui ne l'a jamais quitté. L'esprit d'un champion ne meurt jamais..."),
	("Expendables - unité spéciale", 						@Usa,				"01:45", "2010-08-18", @Action, 			@SylvesterStallone, "Ce ne sont ni des mercenaires, ni des agents secrets. Ils choisissent eux-mêmes leurs missions et n'obéissent à aucun gouvernement. Ils ne le font ni pour l'argent, ni pour la gloire, mais parce qu'ils aident les cas désespérés. Depuis dix ans, Izzy Hands, de la CIA, est sur les traces du chef de ces hommes, Barney Ross. Parce qu'ils ne sont aux ordres de personne, il devient urgent de les empêcher d'agir. Eliminer un général sud-américain n'est pas le genre de job que Barney Ross accepte, mais lorsqu'il découvre les atrocités commises sur des enfants, il ne peut refuser. Avec son équipe d'experts, Ross débarque sur l'île paradisiaque où sévit le tyran. Lorsque l'embuscade se referme sur eux, il comprend que dans son équipe, il y a un traître. Après avoir échappé de justesse à la mort, ils reviennent aux Etats-Unis, où chaque membre de l'équipe est attendu. Il faudra que chacun atteigne les sommets de son art pour en sortir et démasquer celui qui a trahi..."),
	("Big fish", 											@Usa,				"02:05", "2004-03-03", @Drame, 				@TimBurton, 		"L'histoire à la fois drôle et poignante d'Edward Bloom, un père débordant d'imagination, et de son fils William. Ce dernier retourne au domicile familial après l'avoir quitté longtemps auparavant, pour être au chevet de son père, atteint d'un cancer. Il souhaite mieux le connaître et découvrir ses secrets avant qu'il ne soit trop tard. L'aventure débutera lorsque William tentera de discerner le vrai du faux dans les propos de son père mourant."),
	("Beetlejuice", 										@Usa,				"01:32", "1988-12-14", @Comedie, 			@TimBurton, 		"Pour avoir voulu sauver un chien, Adam et Barbara Maitland passent tout de go dans l'autre monde. Peu après, occupants invisibles de leur antique demeure ils la voient envahie par une riche et bruyante famille new-yorkaise. Rien à redire jusqu'au jour où cette honorable famille entreprend de donner un cachet plus urbain à la vieille demeure. Adam et Barbara, scandalisés, décident de déloger les intrus. Mais leurs classiques fantômes et autres sortilèges ne font aucun effet. C'est alors qu'ils font appel à un \"bio-exorciste\" freelance connu sous le sobriquet de Beetlejuice."),
	("Batman", 												@Usa,				"02:05", "1989-09-13", @Fantastique, 		@TimBurton, 		"Le célèbre et impitoyable justicier, Batman, est de retour. Plus beau, plus fort et plus dépoussiéré que jamais, il s'apprête à nettoyer Gotham City et à affronter le terrible Joker..."),
	("Batman, le défi", 									@Usa,				"02:06", "1992-07-15", @Fantastique, 		@TimBurton, 		"Non seulement Batman doit affronter le Pingouin, monstre génétique doté d'une intelligence à toute épreuve, qui sème la terreur mais, plus difficile encore, il doit faire face à la séduction de deux super-femmes, la douce Selina Kyle et la féline Catwoman qui va lui donner bien du fil a retordre. Si Bruce Wayne apprécie Selina, Batman n'est pas insensible au charme de Catwoman."),
	("Edward aux mains d'argent", 							@Usa,				"01:45", "1991-04-19", @Fantastique, 		@TimBurton, 		"Edward Scissorhands n'est pas un garçon ordinaire. Création d'un inventeur, il a reçu un coeur pour aimer, un cerveau pour comprendre. Mais son concepteur est mort avant d'avoir pu terminer son oeuvre et Edward se retrouve avec des lames de métal et des instruments tranchants en guise de doigts."),
	("Frankenweenie", 										@Usa,				"01:40", "2012-10-31", @Animation, 			@TimBurton, 		"Après la mort soudaine de Sparky, son chien qu'il adorait, le jeune Victor se tourne vers le pouvoir de la science pour ramener à la vie celui qui était aussi son meilleur ami. Il lui apporte au passage quelques modifications de son cru... Victor va tenter de cacher sa création \"faite main\", mais quand Sparky s'échappe, les camarades de Victor, ses professeurs et la ville tout entière vont apprendre que vouloir mettre la vie en laisse peut avoir quelques monstrueuses conséquences..."),
	("Les noces funèbres", 									@Usa,				"01:15", "2005-10-19", @Animation, 			@TimBurton, 		"Au XIXe siècle, dans un petit village d'Europe de l'est, Victor, un jeune homme, découvre le monde de l'au-delà après avoir épousé, sans le vouloir, le cadavre d'une mystérieuse mariée. Pendant son voyage, sa promise, Victoria l'attend désespérément dans le monde des vivants. Bien que la vie au Royaume des Morts s'avère beaucoup plus colorée et joyeuse que sa véritable existence, Victor apprend que rien au monde, pas même la mort, ne pourra briser son amour pour sa femme."),
	("Alice au pays des merveilles", 						@Usa,				"01:42", "2010-03-24", @Fantastique, 		@TimBurton, 		"Alice, désormais âgée de 19 ans, retourne dans le monde fantastique qu'elle a découvert quand elle était enfant. Elle y retrouve ses amis le Lapin Blanc, Bonnet Blanc et Blanc Bonnet, le Loir, la Chenille, le Chat du Cheshire et, bien entendu, le Chapelier Fou. Alice s'embarque alors dans une aventure extraordinaire où elle accomplira son destin : mettre fin au règne de terreur de la Reine Rouge."),
	("Independance day - Resurgence",						@Usa,				"02:01", "2016-07-20", @ScienceFiction,		@RolandEmmerich,	"Nous avons toujours su qu'ils reviendraient. La terre est menacée par une catastrophe d’une ampleur inimaginable. Pour la protéger, toutes les nations ont collaboré autour d’un programme de défense colossal exploitant la technologie extraterrestre récupérée. Mais rien ne peut nous préparer à la force de frappe sans précédent des aliens. Seule l'ingéniosité et le courage de quelques hommes et femmes peuvent sauver l’humanité de l'extinction.");


-- ===============================================================================================================
--   insertion des enregistrements relatifs aux participations des personnes aux films
-- ===============================================================================================================
-- Elle
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Elle";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Isabelle",	"Huppert"),		"Michelle");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Laurent",	"Lafitte"),		"Patrick");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Anne",		"Consigny"),	"Anna");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Charles",	"Berling"),		"Richard");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Virginie",	"Efira"),		"Rebecca");

-- Bridget Jones Baby
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Bridget Jones Baby";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Renée",		"Zellweger"),		"Bridget Jones");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Patrick",	"Dempsey"),			"Jack Qwant");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Colin",		"Firth"),			"Mark Darcy");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Emma",		"Thompson"),		"la gynécologue");

-- Independance day : resurgence
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Independance day - Resurgence";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jeff",		"Goldblum"),		"David Levinson");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Bill",		"Pullman"),			"président Thomas J. Whitmore");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Liam",		"Hemsworth"),		"Jake Morrison");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jessie",		"Usher"),			"Dylan Hiller");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Maika",		"Monroe"),			"Patricia Whitmore");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "William",	"Fichtner"),		"général Adams");

-- Twilight - chapitre 2 - tentation
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Twilight - chapitre 2 - tentation";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Kristen",	"Stewart"),			"Bella Swan");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Robert",		"Pattinson"),		"Edward Cullen");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Taylor",		"Lautner"),			"Jacob Black");

-- Valentine's day
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Valentine's day";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Julia",		"Roberts"),			"Kate Hazeltine");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jessica",	"Alba"),			"Morley Clarkson");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Anne",		"Hathaway"),		"Liz");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jessica",	"Biel"),			"Kara Monahan");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jennifer",	"Garner"),			"Julia Fitzpatrick");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Bradley",	"Cooper"),			"Holden");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jamie",		"Foxx"),			"Kelvin Moore");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Patrick",	"Dempsey"),			"Harrison Copeland");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Ashton",		"Kutcher"),			"Reed Bennett");

-- Avatar
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Avatar";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sam",		"Worthington"),		"Jake Sully");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Zoe",		"Saldana"),			"Neytiri");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sigourney",	"Weaver"),			"Grace Augustine");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Stephen",	"Lang"),			"colonel Miles Quaritch");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Michelle",	"Rodriguez"),		"Trudy Chacon");

-- Shutter Island
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Shutter Island";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Leonardo",	"DiCaprio"),		"Teddy Daniels");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Mark",		"Ruffalo"),			"marshal Chuck Aule");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Ben",		"Kingsley"),		"Cawley, psychiatre en chef");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Michelle",	"Williams"),		"Dolores Chanal");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Emily",		"Mortimer"),		"Rachel Solando");

-- Terminator
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Terminator";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Arnold",		"Schwarzenegger"),	"terminator");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Michael",	"Biehn"),			"Kyle Reese");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Linda",		"Hamilton"),		"Sarah Connor");

-- Protéger et servir
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Protéger et servir";								 
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Kad",		"Merad"),			"Michel Boudriau");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Clovis",		"Cornillac"),		"Kim Houang");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Carole",		"Bouquet"),			"Aude Letellier");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "François",	"Damiens"),			"Roméro");

-- 2012
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "2012";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Danny",		"Glover"),			"président");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Thandie",	"Newton"),			"fille du président");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "John",		"Cusack"),			"...");

-- Expendables - unité spéciale
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Expendables - unité spéciale";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sylvester",	"Stallone"),		"Barney Ross");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jason",		"Statham"),			"Lee Christmas");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jet",		"Li"),				"Yin Yang");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Dolph",		"Lundgren"),		"Gunnar Jensen");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Eric",		"Roberts"),			"James Monroe");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Randy",		"Couture"),			"Toll Road");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Steve",		"Austin"),			"Paine");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "David",		"Zayas"),			"général Garza");

-- Expendables 2 - unité spéciale
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Expendables 2 - unité spéciale";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sylvester",	"Stallone"),		"Barney Ross");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jason",		"Statham"),			"Lee Christmas");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Jet",		"Li"),				"Yin Yang");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Dolph",		"Lundgren"),		"Gunnar Jensen");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Chuck",		"Norris"),			"Booker");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "JC",			"Van Damme"),		"Vilain");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Bruce",		"Willis"),			"Church");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Arnold",		"Schwarzenegger"),	"Trench");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Randy",		"Couture"),			"Toll Road");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Terry",		"Crews"),			"Hale Caesar");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Charisma",	"Carpenter"),		"Lacy");

-- Robin des bois
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Robin des bois";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Russel",		"Crowe"),			"Robin Longstride");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Cate",		"Blanchett"),		"Marianne Loxley");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Max",		"von Sydow"),		"Sire Walter Loxley");

-- Rocky Balboa
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Rocky Balboa";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sylvester",	"Stallone"),		"Rocky Balboa");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Burt",		"Young"),			"Paulie");

-- Salt
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Salt";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Angelina",	"Jolie"),			"Evelyn Salt");

-- 1492 - Christophe Colomb
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "1492 - Christophe Colomb";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Gerard",		"Depardieu"),		"Christophe Colomb");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sigourney",	"Weaver"),			"la reine Isabel");

-- Resident evil - afterlife
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Resident evil - afterlife";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Milla",		"Jovovich"),		"Alice");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Ali",		"Larter"),			"Claire Redfield");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Wentworth",	"Miller"),			"Chris Redfield");

-- Prometheus
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Prometheus";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Charlize",	"Theron"),			"Meredith Vickers");

-- Night and day
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Night and day";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Tom",		"Cruise"),			"Roy Miller");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Cameron",	"Diaz"),			"June Havens");

-- Abyss
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Abyss";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Ed",			"Harris"),			"Virgil 'Bud' Brigman");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Michael",	"Biehn"),			"Lieutenant Hiram Coffey");

-- Alien, le huitième passager
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Alien, le huitième passager";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sigourney",	"Weaver"),			"lieutenant Ellen L. Ripley");

-- Aliens le retour
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Aliens le retour";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Sigourney",	"Weaver"),			"lieutenant Ellen L. Ripley");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Michael",	"Biehn"),			"caporal Dwayne Hicks");

-- Bienvenue à bord
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Bienvenue à bord";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Franck",		"Dubosc"),			"Rémy Pasquier");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Valerie",	"Lemercier"),		"Isabelle");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Gerard",		"Darmon"),			"Richard Morena");

-- Crime d'amour
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Crime d'amour";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Ludivine",	"Sagnier"),			"Isabelle Guérin");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Kristin",	"Scott Thomas"),	"Christine");

-- Forrest gump
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Forrest gump";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Tom",		"Hanks"),			"Forrest Gump");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Gary",		"Sinise"),			"lieutenant Dan Taylor");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Robin",		"Wright"),			"Jennifer Curran");

-- Gladiator
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Gladiator";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Russel",		"Crowe"),			"Robin Longstride");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Joaquin",	"Phoenix"),			"Commodus");

-- Inception
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Inception";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Leonardo",	"DiCaprio"),		"Dom Cobb");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Marion",		"Cotillard"),		"Mal");

-- Titanic
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Titanic";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Leonardo",	"DiCaprio"),		"Jack Dawson");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Kate",		"Winslet"),			"Rose DeWitt Bukater");

-- Signes
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Signes";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Mel",		"Gibson"),			"Graham Hess");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Joaquin",	"Phoenix"),			"Merrill Hess");

-- Hors de controle
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Hors de controle";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Mel",		"Gibson"),			"Thomas Craven");

-- Incassable
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Incassable";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Bruce",		"Willis"),			"David Dunn");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Robin",		"Wright"),			"Audrey Dunn");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Samuel",		"L. Jackson"),		"Elijah Price");

-- Coup de foudre à Notting Hill
SELECT numFilm INTO @NumFilm FROM film WHERE titreFilm = "Coup de foudre à Notting Hill";
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Julia",		"Roberts"),			"Anna Scott");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Hugh",		"Grant"),			"William Thacker");
INSERT INTO participer VALUES (@NumFilm, getNumPersonne("Acteur", "Emily",		"Mortimer"),		"Perfect girl");


-- ===============================================================================================================
--   insertion des type d'utilisateurs
-- ===============================================================================================================
INSERT INTO typeUser(libelleTypeUser) VALUES ("administrateur"), ("membre"), ("visiteur");

-- ===============================================================================================================
--   insertion des utilisateurs
-- ===============================================================================================================
CALL ajoutUser("administrateur","Admin",	@defautMotDePasse, "Kevin",		"Beaugoss",			"1995-08-19", "H", "14 rue des fringues",		"58410", "Jmelapette",			"0452535455", "0611221128", "KevinBioutifull38@gmail.com", 	"general");
CALL ajoutUser("membre",		"x01",		@defautMotDePasse, "Nordine",	"Ateur",			"1952-06-21", "H", "7 rue verte",				"38190", "Villard-Bonnot",		"0424203090", "0614523344", "x01@yahoo.com", 				"mask");
CALL ajoutUser("membre",		"x02",		@defautMotDePasse, "Alain",		"Vairse",			"1989-05-17", "H", "10 Bd des Lilas",			"38420", "Domene",				"0420803435", "0617823344", "x02@yahoo.com",				"mask");
CALL ajoutUser("membre",		"x03",		@defautMotDePasse, "Alain",		"Proviste",			"1984-04-27", "H", "124 rue bleue",		   		"38420", "Domene",				"0427208430", "0624266344", "x03@yahoo.com", 				"mask");
CALL ajoutUser("membre",		"x04",		@defautMotDePasse, "Aline",		"Eha",				"1983-05-11", "F", "14bis avenue bobo",			"38190", "Villard-Bonnot",		"0420283040", "0675212344", "x04@yahoo.com", 				"mask");
CALL ajoutUser("membre",		"x05",		@defautMotDePasse, "Alonzo",	"Toilette",			"1989-05-10", "H", "10 rue des pensées",		"38000", "Grenoble",			"0423203032", "0688223344", "x05@free.fr", 					"logan");
CALL ajoutUser("membre",		"x06",		@defautMotDePasse, "Alphonse",	"Leclou",			"1988-03-24", "H", "12 Bd victor Hugo",			"38000", "Grenoble",			"0420204439", "0632223694", "x06@yahoo.com", 				"Ood");
CALL ajoutUser("membre",		"x07",		@defautMotDePasse, "Amar",		"Diprochain",		"1993-05-27", "H", "17 Bd victor Hugo",			"38000", "Grenoble",			"0480293539", "0617223474", "x07@yahoo.com", 				"?");
CALL ajoutUser("membre",		"x08",		@defautMotDePasse, "Amédée",	"Lunettepourlire",	"1978-11-22", "H", "14 avenue des fleurs",		"38420", "Domene",				"0430243037", "0661223114", "x08@netcourrier.com", 			"erreurNormalement!");
CALL ajoutUser("membre",		"x09",		@defautMotDePasse, "Andy",		"Vojambon",			"1975-05-27", "H", "10 rue rouge",				"59000", "Lille",				"0399283035", "0654229844", "x09@netcourrier.com", 			"?");
CALL ajoutUser("membre",		"x10",		@defautMotDePasse, "Angèle",	"Labha",			"1985-10-28", "F", "15 allée des poux",			"75000", "Paris",				"0150783544", "0685223366", "x10@yahoo.com", 				"shadowCat");
CALL ajoutUser("membre",		"x11",		@defautMotDePasse, "Anna",		"Conda",			"1986-05-22", "F", "18 rue des losanges",		"38190", "Villard-Bonnot",		"0458993034", "0669223332", "x11@netcourrier.com", 			"avengersBlackWidow");
CALL ajoutUser("membre",		"x12",		@defautMotDePasse, "Anne-Laure","Ondanse",			"1999-09-29", "F", "11 allée de l'empire",		"38190", "Villard-Bonnot",		"0455874458", "0610223315", "x12@yahoo.com", 				"spiderWoman");
CALL ajoutUser("membre",		"x13",		@defautMotDePasse, "Annie",		"Versaire",			"1996-05-25", "F", "120 rue verte",				"38000", "Grenoble",			"0474458874", "0624223321", "x13@yahoo.com", 				"?");
CALL ajoutUser("membre",		"x14",		@defautMotDePasse, "Annie",		"Male",				"1975-08-30", "F", "8 chemin du fort",			"38420", "Domene",				"0445552114", "0640223547", "x14@yahoo.com", 				"?");
CALL ajoutUser("membre",		"x15",		@defautMotDePasse, "Alphonse",	"Kelpeuve",			"1978-08-27", "H", "99 chemin vert",			"38190", "Villard-Bonnot",		"0445552121", "0608223658", "x15@cegetel.net", 				"smith");
CALL ajoutUser("membre",		"x16",		@defautMotDePasse, "Armelle",	"Couvert",			"1989-04-03", "F", "8 rue de l'horloger",		"38190", "Villard-Bonnot",		"0454546688", "0605223212", "x16@yahoo.com", 				"barretWallace");
CALL ajoutUser("membre",		"x17",		@defautMotDePasse, "Armelle",	"Lapendulaleur",	"1989-05-23", "F", "15 av françois Mitterrand", "38190", "Villard-Bonnot",		"0420256560", "0647223555", "x17@cegetel.net", 				"araignee");
CALL ajoutUser("membre",		"x18",		@defautMotDePasse, "Aude",		"Javel",			"1984-04-05", "F", "45 chemin du bosquet",		"38000", "Grenoble",			"0424544588", "0635223988", "x18@yahoo.com", 				"cochon");
CALL ajoutUser("membre",		"x19",		@defautMotDePasse, "Barack",	"Afritt",			"1989-05-06", "H", "105 rue du fleuve bleu",	"38000", "Grenoble",			"0420208877", "0648223988", "x19@netcourrier.com", 			"cochon");
CALL ajoutUser("membre",		"x20",		@defautMotDePasse, "Benny",		"Soitil",			"1984-03-27", "H", "50 allée de la Chine",		"38000", "Grenoble",			"0424555455", "0681223488", "x20@yahoo.com", 				"crabe");
CALL ajoutUser("membre",		"x21",		@defautMotDePasse, "Cali",		"Fourchon",			"1989-05-30", "H", "20 av du général Leclerc",	"38190", "Villard-Bonnot",		"0427744551", "0641823344", "x21@netcourrier.com", 			"crocodile");
CALL ajoutUser("membre",		"x22",		@defautMotDePasse, "Carla",		"Jumid",			"1979-08-27", "F", "54 rue noire",				"38000", "Grenoble",			"0487445444", "0656623344", "x22@yahoo.com", 				"elephant");
CALL ajoutUser("membre",		"x23",		@defautMotDePasse, "César",		"Ienne",			"1989-05-02", "H", "54 allée des cartouches",	"38190", "Villard-Bonnot",		"0428756984", "0623623344", "x23@yahoo.com", 				"hippopotame");
CALL ajoutUser("membre",		"x24",		@defautMotDePasse, "Chris",		"Entème",			"1979-07-30", "H", "17 rue Maupassant",			"75002", "Paris",				"0154874452", "0687723344", "x24@yahoo.com", 				"mouton");
CALL ajoutUser("membre",		"x25",		@defautMotDePasse, "Claire",	"Voyant",			"1989-05-20", "F", "14 rue des îles",			"75001", "Paris",				"0125656544", "0644423344", "x25@yahoo.com", 				"pingouin");
CALL ajoutUser("membre",		"x26",		@defautMotDePasse, "Daisy",		"Rable",			"1992-02-17", "F", "02 chemin des glaçons",		"38190", "Villard-Bonnot",		"0420774587", "0611265144", "x26@yahoo.com", 				"poulet");
CALL ajoutUser("membre",		"x27",		@defautMotDePasse, "Elie",		"Minet",			"1983-05-20", "H", "04bis rue de Paris",		"38420", "Domene",				"0445219412", "0611221544", "x27@free.fr", 					"devil");
CALL ajoutUser("membre",		"x28",		@defautMotDePasse, "Ella",		"Toutpourplaire",	"1989-02-10", "F", "10 rue d'Alger",			"69000", "Lyon",				"0452488752", "0611220044", "x28@free.fr", 					"logoBatman");
CALL ajoutUser("membre",		"x29",		@defautMotDePasse, "Emma",		"Toufécela",		"1985-05-27", "F", "18 rue du soleil ",			"62100", "Calais",				"0321554445", "0671205544", "x29@yahoo.com", 				"zombie1");
CALL ajoutUser("membre",		"x30",		@defautMotDePasse, "Eva",		"Afonlakess",		"1989-12-27", "F", "14 rue des nuages",			"62100", "Calais",				"0321544485", "0681069449", "x30@yahoo.com", 				"zombie2");
CALL ajoutUser("membre",		"x31",		@defautMotDePasse, "Firmin",	"Peutagueule",		"1984-05-22", "H", "27 rue de Paris",			"69000", "Lyon",				"0454411245", "0661488344", "x31@yahoo.com", 				"zangief");
CALL ajoutUser("visiteur",		"x32",		@defautMotDePasse, "Henri",		"Gole",				"1979-10-05", "H", "15 allée des ploucs",		"75000", "Paris",				"0152211452", "0617652344", "x32@free.fr", 					"?");
CALL ajoutUser("visiteur",		"x33",		@defautMotDePasse, "Ines",		"Tétic",			"1978-05-04", "F", "19 chemin des anges",		"38000", "Grenoble",			"0498774447", "0731328745", "x33@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x34",		@defautMotDePasse, "Jade",		"Orlapizza",		"1989-05-27", "F", "17 allée du diable",		"06000", "Nice",				"0422110001", "0614288346", "x34@free.fr", 					"?");
CALL ajoutUser("visiteur",		"x35",		@defautMotDePasse, "Jamie",		"Lepaquet",			"1989-11-30", "H", "174 rue de la mer",			"06000", "Nice",				"0487745521", "0615423548", "x35@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x36",		@defautMotDePasse, "Jean",		"Peuplu",			"1980-05-27", "H", "11 rue du lac",				"74000", "Annecy",				"0432145524", "0681223652", "x36@free.fr", 					"?");
CALL ajoutUser("visiteur",		"x37",		@defautMotDePasse, "Jean-Loup",	"Pahune",			"1989-03-24", "H", "14 avenue du Parmelan",		"74000", "Annecy",				"0445225411", "0611223233", "x37@cegetel.net", 				"?");
CALL ajoutUser("visiteur",		"x38",		@defautMotDePasse, "Jerry",		"Tméladanse",		"1980-02-20", "H", "21 rue des montagnes",		"74000", "Annecy",				"0499652144", "0661223477", "x38@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x39",		@defautMotDePasse, "John",		"Deuf",				"1989-05-07", "H", "19 chemin de la mer",		"62100", "Calais",				"0321998855", "0617223984", "x39@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x40",		@defautMotDePasse, "Justin",	"Ptipeu",			"1977-04-23", "H", "41 rue de la frite",		"59000", "Lille",				"0320002566", "0681223621", "x40@free.fr", 					"?");
CALL ajoutUser("visiteur",		"x41",		@defautMotDePasse, "Karl",		"Age",				"1989-05-24", "H", "20 rue de la lune",			"59000", "Lille",				"0320099544", "0614223020", "x41@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x42",		@defautMotDePasse, "Kelly",		"Vrogne",			"1978-03-23", "F", "74 av des diamants",		"38190", "Villard-Bonnot",		"0429885621", "0611223484", "x42@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x43",		@defautMotDePasse, "Lara",		"Caille",			"1980-05-22", "F", "12 rue des triangles",		"74000", "Annecy",				"0432125412", "0645223310", "x43@gmail.com", 				"?");
CALL ajoutUser("visiteur",		"x44",		@defautMotDePasse, "Laurie",	"Kulère",			"1975-12-27", "F", "18 avenue du coeur",		"59000", "Lille",				"0321554128", "0681223666", "x44@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x45",		@defautMotDePasse, "Line",		"Oxydable",			"1989-05-23", "F", "88 av mars",				"38190", "Villard-Bonnot",		"0422459547", "0651227845", "x45@yahoo.fr", 				"?");
CALL ajoutUser("visiteur",		"x46",		@defautMotDePasse, "Lorie",		"Zonlointain",		"1989-12-27", "F", "14 rue rose",				"59000", "Lille",				"0351001945", "0641224122", "x46@netcourrier.com", 			"?");
CALL ajoutUser("visiteur",		"x47",		@defautMotDePasse, "Marc",		"Assin",			"1987-05-17", "H", "27 rue Chaplin",			"73000", "Chambery",			"0478549478", "0619225448", "x47@gmail.com", 				"?");
CALL ajoutUser("visiteur",		"x48",		@defautMotDePasse, "Martial",	"Lacour",			"1989-12-27", "H", "12 bd de la nuit",			"38000", "Grenoble",			"0491949256", "0616221200", "x48@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x49",		@defautMotDePasse, "Médé",		"Capote",			"1979-04-10", "H", "44 rue des mimosas",		"73000", "Chambery",			"0422594524", "0655221598", "x49@gmail.com", 				"?");
CALL ajoutUser("visiteur",		"x50",		@defautMotDePasse, "Mélanie",	"Maldanlacage",		"1981-05-27", "F", "17 avenue Mermoz",			"73000", "Chambery",			"0491947854", "0666223206", "x50@yahoo.fr", 				"?");
CALL ajoutUser("visiteur",		"x51",		@defautMotDePasse, "Mike",		"Rosoft",			"1979-05-23", "H", "14 chemin des frelons",		"73000", "Chambery",			"0432925144", "0618224589", "x51@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x52",		@defautMotDePasse, "Nathan",	"Paskejelefasse",	"1988-04-28", "H", "18 rue des fraises",		"38190", "Villard-Bonnot",		"0425491234", "0671222125", "x52@yahoo.fr", 				"?");
CALL ajoutUser("visiteur",		"x53",		@defautMotDePasse, "Odette",	"Fairfasse",		"1989-05-27", "F", "10 rue des oranges",		"62100", "Calais",				"0321221948", "0615222266", "x53@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x54",		@defautMotDePasse, "Olga",		"Tokilébon",		"1989-01-24", "F", "17 bd des melons",			"62100", "Calais",				"0312105445", "6112265870", "x54@cegetel.net", 				"?");
CALL ajoutUser("visiteur",		"x55",		@defautMotDePasse, "Pat",		"Réloin",			"1984-05-27", "H", "10 rue des cerises",		"38190", "Villard-Bonnot",		"0420203030", "0601224215", "x55@gmail.com", 				"?");
CALL ajoutUser("visiteur",		"x56",		@defautMotDePasse, "Patrice",	"Tounet",			"1983-01-10", "H", "17bis rue du bronzage",		"62100", "Calais",				"0321225491", "0681248999", "x56@yahoo.com", 				"?");
CALL ajoutUser("visiteur",		"x57",		@defautMotDePasse, "Paul",		"Icevopapier",		"1985-05-12", "H", "10 rue des haricots",		"38420", "Domene",				"0425225419", "0614265221", "x57@netcourrier.com",			"?");
CALL ajoutUser("visiteur",		"x58",		@defautMotDePasse, "Rémi",		"Sion",				"1979-08-14", "H", "14 rue des courgettes",		"38190", "Villard-Bonnot",		"0454954214", "0641478521", "x58@gmail.com", 				"?");


-- ============================================================================
--   appel de la procédure permettant de générer un grain de sel aléatoire à tous les utilisateurs
-- ============================================================================
CALL majGrainDeSelUser();

-- ===============================================================================================================
--   insertion des couples de clés rsa (privées/publiques)
-- ===============================================================================================================
INSERT INTO rsa VALUES (null, 128,
"-----BEGIN RSA PRIVATE KEY-----
MGMCAQACEQDUEldEH3h7oYz3vYD0UnhNAgMBAAECECTcNzzI94kNPy18A5HMfoUC
CQD3acyef1lu2wIJANtuimcI2Xn3AgkAp4Xstbk2/hcCCQDHXosfjHnUBwIIck7+
Lu6dX/s=
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MCwwDQYJKoZIhvcNAQEBBQADGwAwGAIRANQSV0QfeHuhjPe9gPRSeE0CAwEAAQ==
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 128,
"-----BEGIN RSA PRIVATE KEY-----
MGMCAQACEQCMmuuM6gjAo5my9NdinDQTAgMBAAECEATlun5tTzVVqdNbU40mmckC
CQDG2aJp6UN8SwIJALUD68+31zpZAghjPEVDWbfmFQIJAKfLILYFxj7RAgkAokfS
gAIfGoY=
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MCwwDQYJKoZIhvcNAQEBBQADGwAwGAIRAIya64zqCMCjmbL012KcNBMCAwEAAQ==
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 256,
"-----BEGIN RSA PRIVATE KEY-----
MIGqAgEAAiEAlmj5JG8CQ5m9iqJZmMiz+FtO9xUbbhZaoTNUuITTr/MCAwEAAQIg
DQrWNm66eLJ/SThcYjoJF5OTsahQBwM4DFOu0fhiob0CEQDf3QKk1J3qjGfjlgS5
B6d/AhEArACNE2T5H6W7MHmbXQMRjQIQCzGU6UMMZmcA5ttgfxQH5wIRAJUESTVT
Vs6HXHzr7qGPxgUCEGSOeBjBaD5W9h5TCoVTg+c=
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MDwwDQYJKoZIhvcNAQEBBQADKwAwKAIhAJZo+SRvAkOZvYqiWZjIs/hbTvcVG24W
WqEzVLiE06/zAgMBAAE=
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 512,
"-----BEGIN RSA PRIVATE KEY-----
MIIBOwIBAAJBAKdoaos0Pcl+yz5pIr6KcucJ1jYr3F7YTZbfP7wbJ3uLTylgaW8n
wJORR49Z+Sd7OesXwSXA8P8N3la6iceBgcsCAwEAAQJAOwSoPyAxQjaVr5CAI72K
iaIhp2JqI/PM0sos3YOTNU3QjaND4/ipmdtu0Nj1GHcqy1o/2JwXqDPoncb4g83g
2QIhAPoAcuL+ZpDzNbzp0O9SQqb+u+9fmCrHOCu5OSSG0tHZAiEAq2ypllZ3bjv3
TbmkhIYLl2ZAEprxKneu3S7TUB1FhkMCIQDVtYKARsa4zB844YtouaIejQ1soAQ9
NVXwEoMllVcsaQIgYUJaiYhvZGSzcC7Wr7XZ18FUsvmjwMN8u9M4YyjobD8CIQDI
0dPQsu7XgV3NiVgoRTSUMhiXaMkjMfzhBQbHjEHWiQ==
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKdoaos0Pcl+yz5pIr6KcucJ1jYr3F7Y
TZbfP7wbJ3uLTylgaW8nwJORR49Z+Sd7OesXwSXA8P8N3la6iceBgcsCAwEAAQ==
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 512,
"-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBALjDC3tqISRmbHmgE6gJki+vssIEWoLNWJEw+4E0AvQOaWoWiif3
S9SgiMIFUinVEhlD1B6lg/tVIJfy/JyKB6kCAwEAAQJAYgjsEMIRb9UA/dAYXfMm
JDNf8F6LABihQ/jvmnDUmFYebv/I6afmS9KhLLNzwbkmF88I7chbf58NMewNKWeU
OQIhAN7j08GU9JlKZibER7B9jslt1SzT+DBc9jW1lDPUIX/XAiEA1DVDtjQJfEGE
ETjhigSjohRM6osVYkiWNqjhRaDtxH8CIB79XjvUEg4eIgXR1IXdbzTiaHlLH37Z
7gGZtXlfTSkRAiEAm+IcwWVsalh+OWB9XTOXOGKNNeXBaZdEsRZRlSJoRuUCIAbe
tRAQ0yMNCDCp6KPLF10ONPC1YJLc3Z45JQQ4qf1n
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALjDC3tqISRmbHmgE6gJki+vssIEWoLN
WJEw+4E0AvQOaWoWiif3S9SgiMIFUinVEhlD1B6lg/tVIJfy/JyKB6kCAwEAAQ==
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 1024,
"-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCPOQoG5EXP776sxUGp97FGZK8x0yH95Veh8nOspeWV2sqi1yY6
Yp8dmjd7dUxD8cn7fVKG9+B6lvL17aU4t4cfogLzLgq0B8BFT6ZOM7KNgv83+/td
AyDzhZOjiVF8iR0S3NaBmFmpLRw2rfU0amOglYb0uDUnJSbkN/AkAAzzBwIDAQAB
AoGAMDBGXeQ/UwO82X+zJL94r5Ef2zlJJhacwhoD7pKQ6TdI17phG+Lj239wbIMe
anv3dD0J3+yV5FlWnQVdAnTJqworeNqm3YWGUBU+O7C2vePGrMRMuR9rkXbGZHSh
saBsTw5hUNID/b5QMk7STjXUG8P3IMLaVpQijQL25J2gbq0CQQCkbSEnmsfYxgGn
KjqTy6GDQuz3/5sX6DnP4qOkygxUASzVGesTJMlUl4zISsFCt1nLqmGaXbkNQGNs
i4ZB9WmdAkEA3vzZvQVHkJmMXn+Dj283/XoHs+ZVKcXC9ukfwtX/jR3+jbVdSVHs
uSTHEndlTw+ep+GX3vfMeY9P/LHdxReP8wJBAJRPHs2jTclYaFtIusdesBM+hZH3
ywPYYnUBX0ufN1l6Kd8ZXrDIyJR1kfWDgChWSzdqOllLWkP6pPNeMj5CRv0CQHY4
5E/8zpZxciRfwqZ3Nt4ippbQlXJSMS2rJ3Wq85QjxOPotg67aqA2SX0W5BVomJs1
VcmW40fHnYbB3mwyM9UCQG8w49SPi4FDsLmBex0AaJmBCr+0Z/ZzSoArVUA2hOWx
rMuyRfT3OyevT71SdtdotMYSETCZXVBaIrkubOSM2ek=
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCPOQoG5EXP776sxUGp97FGZK8x
0yH95Veh8nOspeWV2sqi1yY6Yp8dmjd7dUxD8cn7fVKG9+B6lvL17aU4t4cfogLz
Lgq0B8BFT6ZOM7KNgv83+/tdAyDzhZOjiVF8iR0S3NaBmFmpLRw2rfU0amOglYb0
uDUnJSbkN/AkAAzzBwIDAQAB
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 2048,
"-----BEGIN RSA PRIVATE KEY-----
MIIEpgIBAAKCAQEAwWUJqw3C5KFmy65U7CnM9pxcOR+EYFTmKQb04QN4XOI/g1vx
EM8G5sh9ZkOCr+CL9UyIKXwE4BqSETPhEWhqBXjW4/OVFWpfR/oCDvFfjMfABzRc
QpwYPCi16TgfVPrehkBJw5sTYJG9Ylr3DFBneij09awjlVOeArAhdaeEF1q1WWq9
tGns9LlPKerQ4RFZmbFKo1ZBGxnoY1+mVOMmObIaTNj+Nu8ig33vZQFX/Q+gulyl
7eORacVYzGUtelndDYuAVhTgCDq1BQu29SYo/U3Z8TYgN/xGIxuaHJdEL5A5kclg
z1htvj1HiegsjVDChyQeoSEqK9L6XV1EVFx6JQIDAQABAoIBAQCx2KSndSRA9Fx/
+nWGKHqgXvJAZcdqfyiZmhgfxP0vDbCysB5kAr6qBL2tCXBpJOoQTqz42V/yZvzk
bP0Q8SBun82eGyaCZyvwGO1DqJzh7d+dwH0HlFyFFjsTmdTWZU21z/EFvNp4+A1d
IaIG5PoD0R5TvlWKwTaR6j8a304N2nOr17tafmNc1H/QQB/4ux2+Ond2sKegOWCT
PNLCm5wQWeQoYFq4APsN2G5jyJt01GHQLCHdGKvaW6sJByrdsRQJdJukL3V/o7L7
ay5XTvFjD3shsgRsFXJl/sgo4wkAw9ns16bfaBTLFicdTb8tQ80QNz8NA3mXZmL1
blwqQxWRAoGBAP/BXnODtqCw3cLdhjektyDJB5d7xujmDWiCWfyTfp3cs/HogesU
dRRPhOQMEWPFnLguOdoAOl73ShZJu5Nfry9vSs7c1LhfVL8QFV59Cg5d9Dtd6svV
pgQB2ziroP91v8dCB1n6PENNg+PtLTMYOY9BudB+84WKxFFXwa3EFHM3AoGBAMGU
ZcRCbm0pm4HP2dEmFNaNPhtnrsArh5x9JPf3ZXSwJ4LbsroRSIxhqcgHb9RrtpJI
a19efGNrMckoyfhHxwdI42jESSLJiFA/5j9yvDjbhxgsYFI7/3Eg9Sc/z6PxZ4i4
LTBPmdh/Ut/Z4GLWnzxLDgxlJSutNKzyko8rgyODAoGBALGgzoWyDAxM6qhljMtm
ph2qIZCvUfX9mYBlUDRhCEaBu6Se1GS9/5bMp8JvM0C1ReSRjnJ/SAse+yDBsvpn
MVfjlvRXYZJv+377n6vRckOKM49r6iAJ0dTkqSoR4a6rTDgK/uoaJvKjip+p4YOk
Jo39mx1Ynq+4MiNArO6PyZg/AoGBAKJqKcAypIe+YxTVGUGbm9wvgS5pHXtqiktH
zF6oGV1/9oaaYigvHBl8T4DejHtDLFkrnbrUgbTAWXMXX+2J+3knNHXQSjR/tnju
Q/Z0A2wI9B3aDa6xXC7EoiueJE6+2kkhjfh8sO2uVhAus076F3v01QKdUkSE/C8n
DsREk7CVAoGBAM3zt0qZQp/U+eBRr2ACvHm7mhsTqhGh7BCH/jBA/PkNi+Qh1vQQ
WpSun8ELXBCxDsufTuDgRdo8KJSY7egSpxB1rAbzpp82iq51znNNJeIfHnXzYE0h
yo+2DVdapj3mQsNZIGnKSNRvg6KqrrnexCDRKpDZFuC8LAkbLy1dm54x
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwWUJqw3C5KFmy65U7CnM
9pxcOR+EYFTmKQb04QN4XOI/g1vxEM8G5sh9ZkOCr+CL9UyIKXwE4BqSETPhEWhq
BXjW4/OVFWpfR/oCDvFfjMfABzRcQpwYPCi16TgfVPrehkBJw5sTYJG9Ylr3DFBn
eij09awjlVOeArAhdaeEF1q1WWq9tGns9LlPKerQ4RFZmbFKo1ZBGxnoY1+mVOMm
ObIaTNj+Nu8ig33vZQFX/Q+gulyl7eORacVYzGUtelndDYuAVhTgCDq1BQu29SYo
/U3Z8TYgN/xGIxuaHJdEL5A5kclgz1htvj1HiegsjVDChyQeoSEqK9L6XV1EVFx6
JQIDAQAB
-----END PUBLIC KEY-----");

INSERT INTO rsa VALUES (null, 4096,
"-----BEGIN RSA PRIVATE KEY-----
MIIJJgIBAAKCAgBghaDFmV3uO+obJS5JzTaQuapf9zAdCpvhenzqjeJBahAPD7k7
XsQWCiXe2NJ0yitvLECtqGqSZM+YJirZTGtvtlZ34vMuz/Wj7lyZploiFCi7VHAw
SQIoWIXj2gNuFC9fneRh7VskdfYDkFzYNe9XqaCC/UTQv7ARsIVXkaHs0jR0v8et
Kq8p6/gqqWCCy6Uq/RgB3KPlN83ROcXFMoHD75lRitnqfC5LKwrHw7qokmNbrQ96
7Jl7Uxw2Gnm/+hqlDNHq8L9QwkWDbSZaPIlfwS32N0w2xsaZmLeVM2dj9zqvVGOc
o2KwxrRj+Hvr6HVx6KNbORIjaksGZurXtehrZfDb3viE+tekcnMYzPGfg4/M99Lh
xvd1//V/pJv0AnE6RAJJKGx8MS75Oh8e2+cN7p/u3grgtfa6YYdv/Qe8phgHgBtL
/NlWQara41eEcsgJPJoeyg04CPMrFEG+J0TTlFSlFXTxt4zXfJ7sJzJ8+MmYFIV0
Sy9BOhVhPxIqTyUcTVWQzTaa9PKB8API2/bnMRtypwTy2M1Iv3C/lKS/BLn09aXS
2rct9M8AH7QKksVkMN7zYp3HcOp4q4E17nBRWczJkDh/AHQbW6K3+FdtlGa/MRi4
V1kyohQEAw4V/4QKlXRITENYPqA+7rsgTxEowDS9+7s4MQGMuXued1/3ZQIDAQAB
AoICABAaGsD8HdxhaGOQ51DuiBzKrG6H+SHPJEQQQAiNFOKexAEPOXJ7E7EtjjXH
7AwJsgdA1aVixCyZ3rveGiXYBtBDFde4J6N2k97+I7qKMt0eidD+fBzCATcj1Wo2
c34IpgKIf5IKm7rQZvMfQS3ciYoRRTK096bvY3r//K6oH+A3DQMw/ymXRlNzBxpu
2SfYuzwZrsiYu0rA7Xfq8GA+VcGPFf+xbzsb7kkh7BF5SIlYqnSfwUZbdBtLuRgZ
gJgTLCC+q8JK2U+qqRgMvGovUSeFPZqmjPNSY8052d5tDeFyW/rl1BxMcWlWLL/E
sz+erwEKsz3DnpAD6nIt9x13Pkd/3PeDU2pJ53rOiklc/wAggSJSFElATQcvSICb
3FN+8aKigzocxqxbPegSsjhL6H/TIHu5qMl7O3Ycei0s9qoTJP0DIOCL/Ymga171
tuisW6JtF6mabX62B5zchGWryCGxa9c+aisgOoUaLig7UsNNBKMYqtHk024XqT8R
cVCF+xQLkl8c+YyCOr6Xm4bDlAknviBFjKuHmZz1SM82GpgL7oqc8yYBzNFtJTc3
QDnaIoAPYUHR+ASmIzZJXyN2INvLPkPrwhzhmHipvrAsz3w5d/JS+LOae4KSjWXs
8Orfldzr3E3Q7c7sa0V1ICSxK6rYOry1we19uZgJ6HBXVA4BAoIBAQCldXOl3HHH
ho9IDu71ywI6Thc4127uIFlzcblslO8SNu9ly0Z3iOlLCnGoq8I/+jTb/ow9zKej
o2loWMzizn60CmrRgFNveNr52avuGSYnwQzYBERBJp5U6pTlSfgjppAsKMvguIY5
zQZil0EBRF085Cm/QngaNMx9CnanB5vSQMQMwhma9mMQmZxBWtjyZPcw0VosYtTJ
eNbDuF+M/xa1z23H2bKD3EqPldq1IRycJv2n5rO9zqfVMf8mAV0qVQziqXKTMhFL
v0Br5ZODPJiTrvh3+bYaZSNkd3NTAPI2crANexFPFzA4myEe8BjbbW6xdbk8v0s/
+npMufgFVe/lAoIBAQCVVw7FBJ8xfunMxkaoebxqsAwSy4J5iISrbioZqMOgbNUn
1gJu7tVgjU5NtAL+3By6fOJadA0w1kUyZw2FnDHAJ1GEG+1E54bfRIS/9A/2ZaLD
7jr1AdRGsx+I7G+hdzgDnP/P2mD96OcqfCB4oiBlDNYaTcQ2qSLsT2+fsGiGUHPp
+fBE2b3PPn0l3Vr9Am5bBG9Dj84FGBFBws6HZ+Jds2tBnMIR/p1iZfpkMdLdBHyk
VbfOWghCcO5Nts51AIFpxDkKIwzv5GfeT0GNEREobSILfueQTzDXGZGLztv7cLxj
7peAZqC/awvdwgq49sfaBkvYy9kX6ySbV4ColnGBAoIBAHVnhPsxFA83PN4tsoP4
XAlRNgsgWtdfXvmava79czJihradadAR9zBHJeVAkyJggTeFRK/pUx67KmVfdWqO
ibtpFOi5fPrBL+hP+z6E290jj+CMDn6IT5sDpUmZlhh97RlYjWpUpPHIuHomx3qF
rv8xCypqmNxHkL49OXpF3NxxFmvTIuYhZKP3y7dYJk7BM+GQ+8I5ErIvK31Pi4V5
z/yMRmKj55bHLqT5+WnDKBDpXd3QxsOtKswNoPWvzBLorK78+47U3Q75k1W8XlKm
IcHRSv+e0geisl1soQlJx5S5BpFaPSr40j+oW/Ue+xRgb0Y+uYUQW+325ucgoovu
sb0CggEAbOk/sTlsq9klwxx63VVirt/S/kYC0oVYU/mUpH/qo22bimDOB38QiEil
aY+1e46lOO/o2BS4pfwuHNMBDobZ1YwXK+R+BnlfaCZ9NcxVc9mteXyc7J+34xOx
FNdxlezvIdt2yGw3vhUDuX0q5S8/ttJEtowuY7q36GUKQAiUQhgcYO/RZTTy81hc
RqgHOmtyddhnGHugwSBLPY1Ht4JwmOtHdmNPOXZZ6y/6CuY3JM6n4+VLlicczO+1
K2H9cWC8AJmFC7qCLdWCVqOwZ6OhwrzMTlvvntPSB5zzA2YKEnamPa78OD0gUFlO
HxzrWvdGyt86o1IO8h2f5dZL0ydcgQKCAQA2IAHuZ/Eds0gFXeuw5+37mH8/n8kL
V51u1E5XEoI0Y+0lzgA1p50JbzWFDn7kTmSb0rfUQCDeJSG7aEn5+tQjyEQ/01pp
wkzyNbgEFzqpGy3PDTYEMl++OCZ3q9A5Q2KhC9hqh8Tcgw/0xm8NeDQGygcwXO/p
CTNSY35RltNk5/YB/bxp0GL884KPdVlw/4nezrOENsbGd6mL0TCfFXBuPfLPu8PB
na3KaznBDnm3Xvi7TXaqS8X+OaE4nmN7SwVEgtAitO+39rJsu2OmIIr8AFNqNvzs
UTS4a5HtEXF8YZx26r0mDgya051nM9uOLVwuNSevP2eX9QHdIc0eS2sx
-----END RSA PRIVATE KEY-----",
"-----BEGIN PUBLIC KEY-----
MIICITANBgkqhkiG9w0BAQEFAAOCAg4AMIICCQKCAgBghaDFmV3uO+obJS5JzTaQ
uapf9zAdCpvhenzqjeJBahAPD7k7XsQWCiXe2NJ0yitvLECtqGqSZM+YJirZTGtv
tlZ34vMuz/Wj7lyZploiFCi7VHAwSQIoWIXj2gNuFC9fneRh7VskdfYDkFzYNe9X
qaCC/UTQv7ARsIVXkaHs0jR0v8etKq8p6/gqqWCCy6Uq/RgB3KPlN83ROcXFMoHD
75lRitnqfC5LKwrHw7qokmNbrQ967Jl7Uxw2Gnm/+hqlDNHq8L9QwkWDbSZaPIlf
wS32N0w2xsaZmLeVM2dj9zqvVGOco2KwxrRj+Hvr6HVx6KNbORIjaksGZurXtehr
ZfDb3viE+tekcnMYzPGfg4/M99Lhxvd1//V/pJv0AnE6RAJJKGx8MS75Oh8e2+cN
7p/u3grgtfa6YYdv/Qe8phgHgBtL/NlWQara41eEcsgJPJoeyg04CPMrFEG+J0TT
lFSlFXTxt4zXfJ7sJzJ8+MmYFIV0Sy9BOhVhPxIqTyUcTVWQzTaa9PKB8API2/bn
MRtypwTy2M1Iv3C/lKS/BLn09aXS2rct9M8AH7QKksVkMN7zYp3HcOp4q4E17nBR
WczJkDh/AHQbW6K3+FdtlGa/MRi4V1kyohQEAw4V/4QKlXRITENYPqA+7rsgTxEo
wDS9+7s4MQGMuXued1/3ZQIDAQAB
-----END PUBLIC KEY-----");

-- END REGION


-- ===============================================================================================================
--   validation de la transaction
-- ===============================================================================================================
COMMIT;
