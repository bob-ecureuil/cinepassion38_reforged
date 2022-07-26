<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/inscription.inc.php
	auteur				: Thomas GRAULLE
	date de création	: 19/11/2019
	date de modification:
	rôle				: le model de requête des pages film du site
  ================================================================================================================*/


class modeleUserInscription extends modele
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
    public function userExist($loginUser, $password) {
        $result = false;

        try {


            $request = "
                INSERT INTO user(motDePasseUser, loginUser, prenomUser, nomUser, dateNaissanceUser, sexeUser, mailUser, dateHeureCreationUser, typeUser) 
                VALUES(?, ?, ?, ?, '1984-04-27', 'F', ?, NOW(), 2);
            ";
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
}


