<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/accueil.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model de requête de la page film accueil du site
  ================================================================================================================*/


class modeleFilmAccueil extends modeleFilm {

    /**
     * get num film, return numFilm with titreFilm in parametre
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param string $titreFilm
     * @throws Exception
     *
     * @return number, number of movie into the database
     */
    public function getNumFilm($titreFilm) {
        $result = 0;
        try {
            $pdoRequest = $this->executerRequete("SELECT numFilm as nb FROM film WHERE titreFilm=\"$titreFilm\"");
            $result = $pdoRequest->fetch(PDO::FETCH_OBJ);
            $result = $result->nb;
        } catch (Exception $e) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
                . __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
            );
        }
        return (int)$result;
    }

}// class
?>