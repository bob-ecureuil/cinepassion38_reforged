-- ===============================================================================================================
-- bd			: cinepassion38
-- type			: MySql V5.7.21 (WampServer 3.1.3)
-- auteur		: Christophe Goidin <christophe.goidin@ac-grenoble.fr> (lycée louise Michel - Grenoble)
-- rôle			: prise en compte du grain de sel lors du chiffrement rsa
-- création 	:
-- 		septembre 2016  prise en compte du grain de sel des utilisateurs  
-- modification	:
--      octobre 2018    modification du cartouche
--						exécution du script SQL sans avoir besoin de modifier le script initial de création de la base de données cinepassion38
-- ===============================================================================================================

-- ===============================================================================================================
--   début de la transaction
-- ===============================================================================================================
START TRANSACTION;

-- ============================================================================
--   mot de passe par défaut
-- ============================================================================
SET @defautMotDePasse = "x";

-- ============================================================================
--   suppression de la procédure stockée ajoutUser et de la fonction stockée getUnCaractereAleatoire
-- ============================================================================
DROP PROCEDURE IF EXISTS ajoutUser;
DROP FUNCTION  IF EXISTS getUnCaractereAleatoire;

-- ============================================================================
--   ajout du champ dans la table des utilisateurs afin de gérer le grain de sel
-- ============================================================================
ALTER TABLE user
ADD grainDeSelUser VARCHAR(20) NOT NULL	COMMENT "Le grain de sel associé à l'utilisateur pour le chiffrement de son mot de passe";

-- ============================================================================
--   autorisation de création des routines
-- ============================================================================
SET GLOBAL log_bin_trust_function_creators = 1;

-- ============================================================================
--   modification du délimiter
-- ============================================================================
DELIMITER //

-- ============================================================================
--   procédure stockée permettant l'ajout des utilisateurs en leur associant un grain de sel aléatoire
-- ============================================================================
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
    INSERT INTO user VALUES (pLoginUser,
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

-- ============================================================================
--   repositionnement du délimiteur à sa valeur initiale
-- ============================================================================
DELIMITER ;

-- ============================================================================
--   appel de la procédure permettant de générer un grain de sel aléatoire à tous les utilisateurs
-- ============================================================================
CALL majGrainDeSelUser();

-- ===============================================================================================================
--   validation de la transaction
-- ===============================================================================================================
COMMIT;
