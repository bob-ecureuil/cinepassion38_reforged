<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/accueil.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model de requête de la page film accueil du site
  ================================================================================================================*/


class modeleFilmStatistique extends modeleFilm {

    /**
     * Get nb films periode, Return the number of movie at the periode
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param int|string $startPeriode, at this format => 20181220 for the 20-12-2018
     * @param int|string $endPeriode, at this format => 20181220 for the 20-12-2018
     * @throws Exception
     *
     * @return int, number of movie into the database at this periode
     */
    public function getNbFilmsPeriode($startPeriode, $endPeriode) {
        $result = 0;
        try {
            $pdoRequest = $this->executerRequete("
            	SELECT COUNT(*) as nb
				FROM film
				WHERE dateSortieFilm > '$startPeriode'
				AND dateSortieFilm < '$endPeriode'
            ;");
            $result = $pdoRequest->fetchObject();
            $result = $result->nb;
        } catch (Exception $e) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
                . __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
            );
        }
        return (int)$result;
    }
    
    /**
     * Get nb films periode, Return the number of movie at this year
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param int|string $titreFilm, at this format => 2018
     * @throws Exception
     *
     * @return int, number of movie into the database at this year
     */
    public function getNbFilmAtYear($year) {
    	$result = 0;
    	$dateStart = $year . '0101';
    	$dateEnd = $year . '1231';
    	
    	try {
    		$pdoRequest = $this->executerRequete("
            	SELECT COUNT(*) as nb
				FROM film
				WHERE dateSortieFilm > '$dateStart'
				AND dateSortieFilm < '$dateEnd'
            ;");
    		$result = $pdoRequest->fetchObject();
    		$result = $result->nb;
    	} catch (Exception $e) {
    		throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
    				. __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
    				);
    	}
    	return (int)$result;
    }

    /**
     * Get nb films periode, Return the number of movie at the periode
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @throws Exception
     *
     * @return collection, return a object collection, with all the information to nbFilmsGenre
     */
    public function getNbFilmsGenre() {
        $listGenreFilm = new collection();

        try {
            $pdoRequest = $this->executerRequete("
                SELECT COUNT(numGenreFilm) AS nbFilmByGenre, numGenreFilm, libelleGenre  
                FROM film 
                RIGHT JOIN genre 
                ON film.numGenreFilm = genre.numGenre 
                GROUP BY numGenreFilm, libelleGenre
                ORDER BY nbFilmByGenre DESC
            ;");
            while ($value = $pdoRequest->fetchObject()) {
                $listGenreFilm->ajouter($value);
            }
        } catch (Exception $e) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
                . __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
            );
        }
        return $listGenreFilm;
    }

    /**
     * Get nb films periode, Return the number of movie at the periode
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @throws Exception
     *
     * @return int, return the number of genre
     */
    public function getNbGenre() {
        $result = 0;

        try {
            $pdoRequest = $this->executerRequete("
                SELECT COUNT(numGenre) AS nbGenre
                FROM genre
            ;");

            $result = $pdoRequest->fetchObject()->nbGenre ;

        } catch (Exception $e) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : "
                . __METHOD__ . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd  ''
                . " . $e->getMessage() . "<br/>"
            );
        }
        return $result;
    }


}// class
?>