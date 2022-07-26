<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/film/accueil.inc.php
	auteur				: Thomas GRAULLE
	date de création	: semptembre 2018
	date de modification:
	rôle				: le contrôleur de la page d'accueil de des films
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page film du domaine cinepassion38
 * @author Thomas GRAULLE
 * @version 1.0
 * @date septembre 2018
 */
class controleurFilmAccueil extends controleur {

	public function __construct() {
		$this->db = new modeleFilmAccueil();
	}
	
	/**
	 * Met à jour le tableau $donnees de la classe mère avec les informations spécifiques de la page
	 * @param null
	 * @return null
	 * @author Thomas GRAULLE
	 * @version 1.1
	 * @date Semptembre 2018
	 */
	public function setDonnees() {
		// ===============================================================================================================
		// titres de la page
		// ===============================================================================================================
		$this->titreHeader = "présentation de l'association";
		$this->titreMain = "présentation des films";

		// ===============================================================================================================
		// encarts
		// ==================================================================== ===========================================
		$this->encartsDroite = $this->getRandomEncartRight(4);
		$this->encartsGauche = $this->getRandomEncartLeft();
		
		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
        $this->globalHeaderLink = $this->getEnteteLien('simpleSlideShow') . PHP_EOL;

		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
	}

	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
     * @author Thomas GRAULLE
	 * @date Semptembre 2018
     * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @param null|void
	 */
	public function defaut() {
        $this->nbFilm = $this->db->getNbFilm();
        $this->galerie = $this->getRandomImage();
        parent::genererVue();
	}

    /**
	 * Get random image, this function get random image with the number in dev.ini.
	 * This function get also every time unique image. You can choose if you want in folder indicated some exceptions.
	 * You can also indicate the extension of the file needed.
	 *
	 * @author Thomas GRAULLE
	 * @date October 2018
	 * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @return array, return array of all image
     */
	protected function getRandomImage() {
		$result = array();
        $fileExtension = explode(';', configuration::get('extensionAffichePermitted'));
        $pathOfFolder = configuration::get('pathOfAfficheFolder');
        $listOfException = explode(';', configuration::get('fileAfficheRefused'));
        $numberOfFile = intval(configuration::get('nbAfficheMax'));
        $tableOfLink = $this->getRandomFileOfFolder($pathOfFolder, $fileExtension, $listOfException, $numberOfFile);

        foreach ($tableOfLink as $key => $linkImage ) {
        	$pathArray = explode('/', $linkImage);
        	$nameFilm = end($pathArray);
        	$nameFilm = substr($nameFilm, 0, strlen($nameFilm) - 4);
			$result[$key] = array(
				'affiche' => $linkImage,
				'numFilm' => $this->db->getNumFilm($nameFilm), // This is fake number, they are changes with db number
			);
		}

		return $result;
	}
	

} // class

?>

