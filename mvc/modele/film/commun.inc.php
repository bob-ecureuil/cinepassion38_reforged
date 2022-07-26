<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/commun.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model de requête des pages film du site
  ================================================================================================================*/


class modeleFilm extends modele
{

    /**
     * Get nb film, return interger count movie
     *
     * @throws Exception
     *
     * @return integer : le nombre de films
     */
    public function getNbFilm() {
        $result = false;
        try {
            $pdoRequest = parent::executerRequete('SELECT COUNT(*) as nb FROM film;');
            $result = $pdoRequest->fetchObject();
            $result = $result->nb;
        } catch (Exception $e) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
                . __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
            );
        }
        return (int) $result;
    }

}


