<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/film/liste.inc.php
	auteur				: Thomas GRAULLE
	date de création	: october 2018
	date de modification:
	rôle				: le contrôleur de la page liste des films
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page liste film du domaine cinepassion38
 * @author Thomas GRAULLE
 * @version 1.0
 * @date septembre 2018
 */
class controleurFilmListe extends controleur {

	public function __construct() {
		$this->db = new modeleFilmListe();
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
		$this->globalHeaderLink = $this->getEnteteLien('simpleSlideShow') . PHP_EOL
			. $this->getEnteteLien('tableau.css') . PHP_EOL
            . $this->getEnteteLien('navigation.css') . PHP_EOL;


        // ===============================================================================================================
		// Information of navigation
		// ===============================================================================================================
		$this->nbFilm = $this->db->getNbFilm();
		$this->nbElementBySection = configuration::get('nbElementBySection');
		$this->nbTotalSection = (int)$this->getNbSection($this->nbFilm, $this->nbElementBySection);
		
		$this->currentSection = $this->requete->getParametre('section', false);
		$this->currentSection = (int)$this->getValidSection($this->currentSection, $this->nbTotalSection);
		$this->firstSection = 1;
		$this->previousSection = $this->currentSection - 1;
		$this->nextSection = $this->currentSection + 1 ;
		$this->lastSection = $this->nbTotalSection;
	
		$this->donneNavigation();
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
		$this->listeFilms = $this->db->getListeFilm($this->nbElementBySection * ($this->currentSection - 1) , $this->nbElementBySection);
		$this->getXhtmlNumbers = $this->navigation->getXhtmlNumbers(intval(configuration::get('nbBetween2Numbers')), intval(configuration::get('styleNavigation')));
		$this->getXhtmlBoutons = $this->navigation->getXhtmlBoutons();
		
	    parent::genererVue();
	}
	
} // class

?>

