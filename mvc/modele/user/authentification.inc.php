<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/authentification.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model des requêtes de la page ficheFilm du site
  ================================================================================================================*/


class modeleUserAuthentification extends modeleUser
{

    /**
     * User exist, check into the database if the user exist and return true or false
     *
     * @author Thomas Graulle 
     * @date 27/03/2019
     *
     * @throws Exception
     * 
     * @param string $loginUser
     *
     * @return bool, return true if the loginUserExist
     */
    public function userExist($loginUser) {
        $result = false;

        try {

            $request = "SELECT (EXISTS (SELECT 1 FROM user WHERE loginUser LIKE ?)) AS isExist";
            $param = array($loginUser);

            $pdoRequest = $this->executerRequete($request, $param);
            $result = $pdoRequest->fetchObject()->isExist;

        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $result;
    }

    /**
     * Get user if correct credential, this function get the user information if the credential is right
     *
     * @author Thomas Graulle 
     * @date 27/03/2019
     *
     * @throws Exception
     *
     * @param string $loginUser
     * @param string $password
     *
     * @return bool|object, return false if the login and the password is wrong
     */
    public function getUserIfCorrectCredential($loginUser, $password) {
        $result = false;

        try {

            $request = "
                SELECT loginUser, motDePasseUser, PrenomUser, NomUser, dateNaissanceUser, sexeUser, adresseUser, codePostalUser,
                  villeUser, telephoneFixeUser, telephonePortableUser, mailUser, avatarUser, nbTotalConnexionUser, nbEchecConnexionUser, 
                  dateHeureCreationUser, dateHeureDerniereConnexionUser, libelleTypeUser
                FROM user 
                INNER JOIN typeUser
                ON numTypeUser = typeUser
                WHERE loginUser LIKE ?
                AND motDePasseUser LIKE ?
            ";
            $param = array($loginUser, $password);

            $pdoRequest = $this->executerRequete($request, $param);
            $result = $pdoRequest->fetchObject();

        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $result;
    }

    /**
     * Get user if correct credential, this function get the user information if the credential is right
     *
     * @author Thomas Graulle
     * @date 27/03/2019
     *
     * @throws Exception
     *
     * @param int $loginUser
     * @param string $action, this param change this action of the function, the function increment or reset the nbEchecConnexionUser.
     *   The action is : ('increment' || 'reset')
     */
    public function incrementNbEchecConnexion($loginUser, $action = 'increment') {
    
    	try {
    		$changement = ( $action === 'reset' ? '0' : 'nbEchecConnexionUser + 1' );
    
    		$request = "
	    		UPDATE user
	    		SET nbEchecConnexionUser = $changement
	    		WHERE loginUser LIKE ?
    		";
    		$param = array($loginUser);
    
    		$pdoRequest = $this->executerRequete($request, $param);
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    }
    
    /**
     * Get user if correct credential, this function get the user information if the credential is right
     *
     * @author Thomas Graulle
     * @date 27/03/2019
     *
     * @throws Exception
     *
     * @param int $loginUser
     *
     */
    public function incrementNbConnexionReussite($loginUser) {
    
    	try {
    		$request = "
	    		UPDATE user
	    		SET nbTotalConnexionUser = nbTotalConnexionUser + 1
	    		WHERE loginUser LIKE ?
    		";
    		$param = array($loginUser);
    
    		$pdoRequest = $this->executerRequete($request, $param);
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    }
    
    /**
     * Change the date of last connexion, this function change the date of the last connexion into the database.
     *
     * @author Thomas Graulle
     * @date 04/04/2019
     *
     * @throws Exception
     *
     * @param dateTime date
     *
     */
    public function updateTheDateOfLastConnexion($loginUser) {
    
    	try {
    		$request = "
	    		UPDATE user
	    		SET dateHeureDerniereConnexionUser = NOW()
	    		WHERE loginUser LIKE ?
    		";
    		$param = array($loginUser);
    
    		$pdoRequest = $this->executerRequete($request, $param);
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    }

    /**
     * Get date last connexion, this function return the date of the last connexion for a user
     * 
     * @author Thomas Graulle
     * @date 04/04/2019
     * 
     * @param $loginUser
     *
     * @return bool
     *
     * @throws Exception
     */
    public function getDateLastConnexion($loginUser) {
    	$result = false;
    	try {
    		$request = "
    				SELECT dateheureDerniereConnexionUser AS date 
    				FROM user
    				WHERE loginUser = ?
    		";

    		$param = array($loginUser);
    		$pdoRequest = $this->executerRequete($request, $param);
    		
    		$result = $pdoRequest->fetchObject()->date;
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    
    	return $result;
    }
    /**
     * Get date last connexion, this function return the date of the last connexion for a user
     *
     * @author Thomas Graulle
     *
     * @param $loginUser
     *
     * @return string|bool, return the "grain de sel" or false if the connexion failed
     *
     * @throws Exception
     */
    public function getGrainDeSelUser($loginUser) {
    	$result = false;
    	try {
    		$request = "
    				SELECT grainDeSelUser AS sel
    				FROM user
    				WHERE loginUser = ?
    		";
    
    		$param = array($loginUser);
    		$pdoRequest = $this->executerRequete($request, $param);
    
    		$result = $pdoRequest->fetchObject()->sel;
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    
    	return $result;
    }
    
    

    /**
     * Update grain sel, update new grain dsel
     * 
     * @author Thomas Graulle
     * 
     * @param unknown $loginUser
     * @param unknown $myGrainDSel
     * 
     * @throws Exception
     */
    public function updateGrainSel($loginUser) {
    
    	try {
    		$request = "
	    		UPDATE user
	    		SET grainDeSelUser = getGrainDeSel()
	    		WHERE loginUser LIKE ?
    		";
    		$param = array($loginUser);
    
    		$pdoRequest = $this->executerRequete($request, $param);
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    
    }
    
    /**
     * Update password User, update the password of the current user
     * 
     * @author Thomas Graulle
     * 
     * @param unknown $loginUser
     * @param unknown $newPassword
     * 
     * @throws Exception
     */
    public function updatePasswordUser($loginUser, $newPassword) {
    
    	try {
    		$request = "
	    		UPDATE user
	    		SET motDePasseUser = ?
	    		WHERE loginUser LIKE ?
    		";
    		$param = array($newPassword, $loginUser);
    
    		$pdoRequest = $this->executerRequete($request, $param);
    
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    
    }
    
}

