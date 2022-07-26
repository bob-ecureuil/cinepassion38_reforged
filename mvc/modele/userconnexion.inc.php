<?php
/*================================================================================================================
 fichier				: ./mvc/modele/userconnexion.inc.php
 auteur				: Thomas GRAULLE & Axel Puglisi
 date de création	: Mars 2019
 date de modification:
 rôle				: le model des requêtes du chiffrement Rsa de l'authentification du formulaire.
 ================================================================================================================*/
class modeleUserconnexion extends modele {

    /**
     * user Exist, check if the user exist
     *
     * @author Thomas GRAULLE
     * @date 19/11/2019
     *
     * @param $login, login of the user
     * @param $password, password hashed of the user
     *
     * @return bool
     * @throws Exception
     */
	public function userExist($login, $password) {
		$result = false;

        try {

            $request = "
            	SELECT loginUser AS login,
            	motDePasseUser AS password
	            FROM user 
	            WHERE loginUser = ? 
	            AND motDePasseUser = ?
            ";
            
            $param = array($login, $password);

            $pdoRequest = $this->executerRequete($request, $param);
            $pdoObject = $pdoRequest->fetchObject();
            if ($pdoObject != false) {
                $loginDb = $pdoObject->login;
                $passwordDb = $pdoObject->password;
                if ($login == $loginDb && $password == $passwordDb) {
                    $result = true;
                }
            }

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

}