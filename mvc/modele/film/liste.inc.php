<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/liste.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model des requêtes de la page listeFilm du site
  ================================================================================================================*/


class modeleFilmListe extends modeleFilm
{
    /**
     * Get liste film, return film information of the table film
     *
     * @throws Exception
     * @param int $nbForStartSection
	 * @param int $nbElementBySection
     *
     * @return collection, return collection of anonymous class  with all information or return false if the request failed
     */
    public function getListeFilm($nbForStartSection, $nbElementBySection) {
        $listFilm = new collection();
        try {
            $pdoRequest = $this->executerRequete("
					SELECT numFilm AS num,
					titreFilm AS titre,
					dureeFilm AS duree,
					DATE_FORMAT(dateSortieFilm, '%Y') AS anneeSortie,
					nomPersonne AS nomRealisateur,
					prenomPersonne AS prenomRealisateur,
					libelleGenre AS libelleGenre
					FROM film 
					INNER JOIN genre ON film.numGenreFilm = genre.numGenre 
					INNER JOIN realisateur ON film.numRealisateurFilm = realisateur.numRealisateur
					INNER JOIN personne ON realisateur.numRealisateur = personne.numPersonne
					ORDER BY titre ASC
            		LIMIT $nbElementBySection
            		OFFSET $nbForStartSection
				;")
            ;
            while ($value = $pdoRequest->fetchObject()) {
            	$listFilm->ajouter($value);
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
        return $listFilm;
    }

}

