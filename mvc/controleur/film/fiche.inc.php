<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/film/fiche.inc.php
	auteur				: Thomas GRAULLE
	date de création	: october 2018
	date de modification:
	rôle				: le contrôleur de la page liste des films
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page fiche film du domaine cinepassion38
 * @author Thomas GRAULLE
 * @version 1.0
 * @date septembre 2018
 */
class controleurFilmFiche extends controleur {

	public function __construct() {
		$this->db = new modeleFilmFiche();
	}
	
	/**
	 * Met à jour le tableau $donnees de la classe mère avec les informations spécifiques de la page
	 * @param null
	 * @author Thomas GRAULLE
	 * @version 1.1
	 * @date October 2018
     * @throws Exception
	 */
	public function setDonnees() {
		// ===============================================================================================================
		// Main information
		// ===============================================================================================================
        $this->nbFilm = $this->db->getNbFilm();
        $this->nbElementBySection = configuration::get('nbElementBySection');
        $this->nbTotalSection = (int)$this->getNbSection($this->nbFilm, $this->nbElementBySection);

		$this->currentMovie = $this->requete->getParametre('section');
        $this->currentMovie = (int)$this->getValidSection($this->currentMovie, $this->db->getHighestNumber(), $this->getNumberOfRandomFilm($this->nbFilm));
        $this->currentSection = $this->currentMovie;
        $this->titre = $this->db->getTitreFilm($this->currentMovie);

		// ===============================================================================================================
		// titres de la page
		// ===============================================================================================================
        $this->titreHeader = "Fiche film";
		$this->titreMain = "Fiche du film: $this->titre";

		// ===============================================================================================================
		// encarts
		// ===============================================================================================================
		$this->encartsDroite = $this->getRandomEncartRight(4);

		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
		$this->globalHeaderLink = $this->getEnteteLien('simpleSlideShow') . PHP_EOL
			. $this->getEnteteLien('tableau.css') . PHP_EOL
			. $this->getEnteteLien('onglet.css') . PHP_EOL
			. $this->getEnteteLien('ficheFilm.css') . PHP_EOL
			. $this->getEnteteLien('lightbox') . PHP_EOL
		;

        // ===============================================================================================================
		// Information of navigation
		// ===============================================================================================================
		$this->firstSection = (int)$this->db->getFirstNumero();
		$this->previousSection = (int)$this->db->getNumeroOfPreviousFilm($this->titre);
		$this->nextSection = (int)$this->db->getNumeroOfNextFilm($this->titre);
		$this->lastSection = (int)$this->db->getLastNumero();

			// ===============================================================================================================
		// Classic information
		// ===============================================================================================================
		$this->titreFilm = $this->db->getTitreFilm($this->currentMovie);
		
		// ===============================================================================================================
		// Manage the navigation bar
		// ===============================================================================================================
        $this->donneNavigation(); // Call the function, what's instance the navigation
        $this->getXhtmlBoutons = $this->navigation->getXhtmlBoutons(array('action' => $this->action));

        // ===============================================================================================================
		// Manage of image and the navigation
		// ===============================================================================================================
       $this->affiche = $this->getAfficheOfMovie($this->titreFilm);
        $this->imagesFilm =  $this->getImageFilm($this->titreFilm);

        // ===============================================================================================================
        // Manage all case of the "action" property
        // ===============================================================================================================
        switch ($this->action) {
			case "defaut":
				$this->action = 'informations'; // change the action of default
		}

		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
	}

	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
     * @author Thomas GRAULLE
	 * @date november 2018
     * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @param null
	 */
	public function defaut() {
		parent::genererVue();
    }
	
	public function informations() {
	    $this->data = true;
        $this->informations = $this->db->getInformationsFilm($this->currentSection);
        $this->nEmeFilmReal = $this->db->getNEmeFilmReal($this->db->getRealisateurFilm($this->currentSection), $this->currentSection);
		parent::genererVue();
	}

    /**
     * Acteurs, this function show all data for the onglet "acteur"
     * 
     * @author Thomas Graulle
     * @date 13/12/18
     * 
     * @throws Exception
     */
	public function acteurs() {
	    $this->data = true; // just for view use part
		$this->acteurs = $this->db->getListActeurs($this->currentMovie);
        $this->pathOfImageActor = configuration::get('pathOfImageActor');
        $this->withoutImage = configuration::get('fullPathWithoutImagePersonne');
		parent::genererVue();
	}
	
	public function notations() {
		parent::genererVue();
	}
	
	public function commentaires() {
		parent::genererVue();
	}

    /**
     * Histoire, show the history of the movie
     *
     * @author Thomas Graulle
     * @date 13/12/18
     *
     * @throws Exception
     */
    public function histoire() {
        $this->data = true;
        $this->synopsis = $this->db->getHistoireFilm($this->currentMovie);
        parent::genererVue();
    }

    /**
	 * Get number of random film, this function return a numFilm of random film
     *
     * @author Thomas Graulle
     * @date 13/12/18
     *
     * @throws Exception, come to the request.
     * @param int $nbTotalFilm
	 *
	 * @return int|boolean, return the numFilm, or return false if the result of the request fail
     */
	private function getNumberOfRandomFilm($nbTotalFilm) {
		$randomPosition = rand(1, $nbTotalFilm - 1) ;

		return $this->db->getNumFilmAtPosition($randomPosition);
	}

    /**
	 * Get affiche of movie, get the right path of file with parameters into the dev.ini file
     *
     * @author Thomas Graulle
     * @date 10/12/18
     *
     * @param string $titreFilm
	 *
     * @return string, return the path of affiche of movie
     */
	private function getAfficheOfMovie($titreFilm) {
		$pathOfFolder = configuration::get('pathOfAfficheFolder');
		$defaultAffiche = $pathOfFolder . '/' . configuration::get('fileAfficheRefused');
		$affiche = $pathOfFolder . '/' . $titreFilm . '.jpg';
		
		return file_exists ($affiche) ? $affiche : $defaultAffiche ;
	}

    /**
	 * $nameOfFolder, this function get all the images to the movie if this image exist
     *
     * @author Thomas Graulle
     * @date 15/12/18
     *
     * @param string $nameOfFolder
     * @return array
     */
	private function getImageFilm($nameOfFolder) {
		$pathFolder = configuration::get('pathOfImageOfMovie');
		$extensionAuthorized = explode(';', configuration::get('extensionAuthorizedImageMovie'));
		$extensionUnauthorized = explode(';', configuration::get('extensionUnauthorizedImageMovie'));

        return $this->getContentIntoFolder($pathFolder, $nameOfFolder, $extensionAuthorized, $extensionUnauthorized);

	}


} // class

?>

