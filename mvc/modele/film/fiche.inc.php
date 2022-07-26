<?php
/*================================================================================================================
	fichier				: ./mvc/modele/film/fiche.inc.php
	auteur				: Thomas GRAULLE
	date de création	: October 2018
	date de modification:
	rôle				: le model des requêtes de la page ficheFilm du site
  ================================================================================================================*/


class modeleFilmFiche extends modeleFilm
{

    /**
     * get histoire film, this function get into the database th synopsis of the film in parameters and return it
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param int $numFilm : le titre du film
     *
     * @return string : the history of the movie
     */
    public function getHistoireFilm($numFilm) {
        $histoire = '';
        try {
            $pdoRequest = $this->executerRequete("
                SELECT synopsisFilm AS synopsis
                FROM film 
                WHERE numFilm = '$numFilm'
            ;");
            $temp = $pdoRequest->fetchObject();
            $histoire = isset($temp->synopsis) && $temp->synopsis != null ? $temp->synopsis : 'Pas de synopsis';

        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $histoire;
    }
    


    /**
     * Get list acteurs, This function get into the database all the actors who have play into the film in parameters
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 22/11/18
     *
     * @throws Exception
     * @param int $numFilm : num of the movie
     *
     * @return collection : return a colletion with all information of the actor of a movie in parameters
     */
    public function getListActeurs($numFilm) {
    	$listActeur = new collection();
    	try {
    		$pdoRequest = $this->executerRequete("
    				SELECT numPersonne as num,
    				prenomPersonne as prenom,
    				nomPersonne as nom,
    				DATE_FORMAT(dateNaissancePersonne, '%d/%m/%Y') as dateNaissance,
    				TIMESTAMPDIFF(YEAR, dateNaissancePersonne, CURDATE()) AS age,
    				sexePersonne as sexe,
    				villeNaissancePersonne as ville,
    				libellePays as pays,
    				role,
    				TIMESTAMPDIFF(YEAR, dateNaissancePersonne, dateSortieFilm) AS ageSortie
    				FROM personne
    				INNER JOIN participer
    				ON personne.numPersonne = participer.numActeur
    				INNER JOIN pays
    				ON personne.numPaysPersonne = pays.numPays
    				INNER JOIN film
    				ON participer.numFilm = film.numFilm
    				WHERE film.numFilm = '$numFilm'
    				;
    				");
    
    		while ($value = $pdoRequest->fetchObject()) {
    			$listActeur->ajouter($value);
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
    	return $listActeur;
    }

    /**
     * get information film, this function get into the database th synopsis of the film in parameters and return it
     *
     * @author Axel Puglisi
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param  $num : le num du film
     *
     * @return object|bool 
     */
    public function getInformationsFilm($num) {
        try {
            $pdoRequest = $this->executerRequete("
                SELECT titreFilm as titreFilm, dureeFilm  as dureeFilm,DATE_FORMAT(dateSortieFilm,'%d %b %Y ')as dateSortieFilm, libelleGenre as genreFilm,  pays.libellePays as nationaliteFilm,paysRealisateur.libellePays as nationaliteRealisateur ,concat(personne.prenomPersonne,' ',personne.nomPersonne)as nomPrenomRealisateur
                FROM film
                join genre on genre.numGenre = film.numGenreFilm
                join pays ON genre.numGenre = pays.numPays
                join realisateur on realisateur.numRealisateur = film.numRealisateurFilm
                join personne ON personne.numPersonne = realisateur.numRealisateur
                join pays paysRealisateur on personne.numPaysPersonne = paysRealisateur.numPays
                WHERE numFilm = '$num';");
            $informations = $pdoRequest->fetchObject();
            
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
                );
        }
        return $informations;
    }
    
    /**
     * get nbFilmRealisateur film, this function get into the database th synopsis of the film in parameters and return it
     *
     * @author Axel Puglisi
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param  $numRealisateur : num of realisator
     *
     * @return collection
     */
    public function getFilmsRealisateur($numRealisateur){
        $listFilmRealisateur = new collection();
        
        try {
            $pdoRequest = $this->executerRequete("
            select *
            from film
            join realisateur on realisateur.numRealisateur = film.numRealisateurFilm
            join personne ON personne.numPersonne = realisateur.numRealisateur
            where numRealisateurFilm = $numRealisateur
            order by dateSortieFilm desc;
            ;");
            while ($value = $pdoRequest->fetchObject()) {
                $listFilmRealisateur->ajouter($value);
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
        return $listFilmRealisateur;
        
    }
    
    /**
     * get nbFilmRealisateur film, this function get into the database th synopsis of the film in parameters and return it
     *
     * @author Axel Puglisi
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param  $numRealisateur : num of realisator
     *
     * @return int
     */
    public function getRealisateurFilm($num){
        
        try {
            $pdoRequest = $this->executerRequete("
            SELECT DISTINCT numRealisateur
            FROM realisateur
            JOIN film
            ON film.numRealisateurFilm = realisateur.numRealisateur
            WHERE film.numFilm = $num");
            
            $numRealisateur = $pdoRequest->fetchObject()->numRealisateur;
            
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
                );
        }
        return $numRealisateur;
    }
    
    /**
     * get nbFilmRealisateur film, this function get into the database th synopsis of the film in parameters and return it
     *
     * @author Axel Puglisi
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param  $numRealisateur : le numéro du réalisateur courrant 
     * @param  $numFilm : le numéro du film courrant 
     *
     * @return bool|int, 
     */
    public function getNEmeFilmReal($numRealisateur, $numFilm){
        $resultFilmRealisateur = false;
        
        try {
            $pdoRequest = $this->executerRequete("
            select numFilm
            from film
            join realisateur 
            ON realisateur.numRealisateur = film.numRealisateurFilm
            join personne 
            ON personne.numPersonne = realisateur.numRealisateur
            where numRealisateurFilm = \"$numRealisateur\"
            order by dateSortieFilm desc;
            ;");
            
            $i = 1;
            $find = false;
			
            while ( !$find && $value = $pdoRequest->fetchObject() ) {
                if ($value->numFilm == $numFilm) {
                    $resultFilmRealisateur = $i;
                    $find = true;
                }
                $i++;
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
        
        return $resultFilmRealisateur;     
    }   
    
    
    /**
     * Return the information of the movie into anonymous object with numFilm given in parameter
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param string $titre : le titre du film
     *
     * @return int|boolean : Return the numero of the next film, or return false if the request fail
     */
    public function getNumeroOfNextFilm($titre) {
        $num = false;
        
        try {
            $pdoRequest = $this->executerRequete("
              	SELECT numFilm 
            	FROM film 
            	WHERE titreFilm > \"$titre\" 
            	ORDER BY titreFilm 
            	ASC LIMIT 1
            ;");
            $object = $pdoRequest->fetchObject();
            $num = isset($object->numFilm)? $object->numFilm : $this->getLastNumero();
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $num;
    }

    /**
     * Return the information of the movie into anonymous object with numFilm given in parameter
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param int $titre : le titre du film
     *
     * @return int|boolean : Return the number of the next film, and return null if it's the last
     */
    public function getNumeroOfPreviousFilm($titre) {
    	$num = false;
    
    	try {
    		$pdoRequest = $this->executerRequete("
    				SELECT numFilm as numFilm
    				FROM film
    				WHERE titreFilm < \"$titre\"
    				ORDER BY titreFilm
    				DESC LIMIT 1
    				;");
    		$object = $pdoRequest->fetchObject();
    		$num = isset($object->numFilm)? $object->numFilm : $this->getFirstNumero();
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    	return $num;
    }

    /**
     * Get titre film, Get into the database the title of the movie and return it with the num of film in parameters
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     * @param int $num : num of the movie
     *
     * @return boolean|string: return the title of the film, or return false if the request fail
     */
    public function getTitreFilm($num) {
    	$titre = '';
    	
    	try {
    		$pdoRequest = $this->executerRequete("
    				SELECT titreFilm
    				FROM film
    				WHERE numFilm = '$num'
    				ORDER BY titreFilm ASC
    			;"
    		);
    		$titre = $pdoRequest->fetchObject()->titreFilm;
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    	return $titre;
    }    
    
    /**
     * Get fist numero, take the first num of film into the database
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 19/11/18
     *
     * @throws Exception
     *
     * @return boolean|int: Return the numero of the first film, or return false if the request fail
     */
    public function getFirstNumero() {
    	$num = 0;
    	
    	try {
    		$pdoRequest = $this->executerRequete("
    				SELECT numFilm
    				FROM film
    				ORDER BY titreFilm ASC
    				LIMIT 1
    			;"
    		);
    		$num = $pdoRequest->fetchObject()->numFilm;
    	} catch (Exception $e) {
    		throw new Exception(
    				"[fichier] : " . __FILE__
    				. "<br/>[classe] : " . __CLASS__
    				. "<br/>[méthode] : " . __METHOD__
    				. "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
    				. "<br/>"
    				);
    	}
    	return $num;
    }


    /**
     * Get Last numero, return the last numero of movie
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 25/11/18
     *
     * @throws Exception
     *
     * @return int|boolean: Return the last number, or return false if the request fail
     */
    public function getLastNumero() {
        $num = 0;

        try {
            $pdoRequest = $this->executerRequete("
    				SELECT numFilm
    				FROM film
    				ORDER BY titreFilm DESC
    				LIMIT 1
    			;"
            );
            $num = $pdoRequest->fetchObject()->numFilm;
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $num;
    }

    /**
     * Get num film at position, return the numFilm at the position in parameters
     *
     * @author Thomas Graulle
     * @version 1.1
     * @date 25/11/18
     *
     * @throws Exception
     *
     * @return int|boolean: Return the numFilm, or return false if the request fail
     */
    public function getNumFilmAtPosition($position) {
        $num = 0;

        try {
            $pdoRequest = $this->executerRequete("
    				SELECT numFilm
    				FROM film
    				ORDER BY titreFilm DESC
    				LIMIT 1
    				OFFSET $position 
    			;"
            );
            $num = $pdoRequest->fetchObject()->numFilm;
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $num;
    }

    /**
     * Get highest number, this function get in the database the highest number in all the database for the numFilm
     *
     * @return int
     * @throws Exception
     */
    public function getHighestNumber() {
        $num = 0;

        try {
            $pdoRequest = $this->executerRequete("
    				SELECT MAX(numFilm) as numFilm
    				FROM film
    			;"
            );
            $num = $pdoRequest->fetchObject()->numFilm;
        } catch (Exception $e) {
            throw new Exception(
                "[fichier] : " . __FILE__
                . "<br/>[classe] : " . __CLASS__
                . "<br/>[méthode] : " . __METHOD__
                . "<br/>[message] : \"Erreur lors de la récurération de données dans la bdd \" . " . $e->getMessage()
                . "<br/>"
            );
        }
        return $num;
    }


}

