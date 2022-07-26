<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/film/statistique.inc.php
	auteur				: Thomas GRAULLE
	date de création	: october 2018
	date de modification:
	rôle				: le contrôleur des statistiques des films
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page liste film du domaine cinepassion38
 * @author Thomas GRAULLE
 * @version 1.0
 * @date septembre 2018
 */
class controleurFilmStatistique extends controleur {

	public function __construct() {
		$this->db = new modeleFilmStatistique();
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
		$this->titreHeader = "les statistique des films";
		$this->titreMain = "les statistique des films";

		// ===============================================================================================================
		// encarts
		// ==================================================================== ===========================================
 		$this->encartsDroite = $this->getRandomEncartRight(4);
//		$this->encartsGauche = "lesStatistiques.txt";

		
		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
		$this->globalHeaderLink = $this->getEnteteLien('simpleSlideShow') . PHP_EOL
			. $this->getEnteteLien('onglet.css') . PHP_EOL
			. $this->getEnteteLien('navigation.css') . PHP_EOL
			. $this->getEnteteLien('statistique.css') . PHP_EOL
		;


        // ===============================================================================================================
		// Information of navigation
		// ===============================================================================================================
// 		$this->nbTotalSection = (int)$this->getNbSection($this->nbFilm, $this->nbElementBySection);
		
// 		$this->currentSection = $this->requete->getParametre('section', false);
// 		$this->currentSection = (int)$this->getValidSection($this->currentSection, $this->nbTotalSection);

		// All information about the period
		$this->firstPeriode = $this->changeFormatDate(configuration::get('firstPeriodeStatistique'));
		$this->today = date("Ymd");
		$this->yearToday = date("Y");
		$this->firstYearFirstPeriod = substr($this->firstPeriode, 0, 4);
		$this->nbAnneePeriode = (int)configuration::get('nbAnneePeriodeStatistique');
		$this->nbTotalYearToStartYearAtToday = (int)$this->yearToday - (int)$this->firstYearFirstPeriod;

		// Section
		$this->nbTotalSection = (int)$this->getNbSection($this->nbTotalYearToStartYearAtToday, $this->nbAnneePeriode);
		$this->currentSection = $this->requete->getParametre('section', false);
		$this->currentSection = (int)$this->getValidSection($this->currentSection, $this->nbTotalSection);

		// start of period
		$this->startPeriode = (int)$this->firstYearFirstPeriod + ($this->nbAnneePeriode * ($this->currentSection  - 1));
		$this->startPeriode =  (int)$this->startPeriode > (int)substr($this->today, 0, 4) ? substr($this->today, 0, 4) : $this->startPeriode;
		// end of current period
		$this->endPeriode = (int)$this->firstYearFirstPeriod + ($this->nbAnneePeriode * ($this->currentSection ));
		$this->endPeriode =  (int)$this->endPeriode > (int)substr($this->today, 0, 4) ? substr($this->today, 0, 4) : $this->endPeriode;

		$this->nbFilmsPeriode = (int)$this->db->getNbFilmsPeriode($this->startPeriode, $this->endPeriode);

		$this->firstSection = 1;
		$this->previousSection = $this->currentSection - 1;
		$this->nextSection = $this->currentSection + 1 ;
		$this->lastSection = ceil($this->nbTotalYearToStartYearAtToday / $this->nbAnneePeriode);
	
		$this->donneNavigation();
//		$this->section =
		// ===============================================================================================================
		// Manage all case of the "action" property
		// ===============================================================================================================
		switch ($this->action) {
			case "defaut":
				$this->action = 'nbFilmAnnee'; // change the action of default
				break;
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
	
	/**
	 * Acteurs, this function show all data for the onglet "acteur"
	 *
	 * @author Thomas Graulle
	 * @date 13/12/18
	 *
	 * @throws Exception
	 */
	public function nbFilmGenre() {
		$nbFilm = $this->db->getNbFilm();
		$nbGenre = $this->db->getNbGenre();
		$this->phrase = "$nbFilm film" . ( $nbFilm > 1 ? 's' : '' ) . " répartis en $nbGenre genre" . ( $nbGenre > 1 ? 's' : '' );

		$this->affichage = true;
		$collectionOfGenre = $this->db->getNbFilmsGenre();
		$this->statistiquesCollection = new collection();

		while (($jeu = $collectionOfGenre->getUnElement())) // the calculed year is not > at now
		{
					$this->statistiquesCollection->ajouter(new statistique("$jeu->libelleGenre" , "$jeu->nbFilmByGenre film" . ( $jeu->nbFilmByGenre > 1 ? 's' : '')));
		}
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
	public function nbFilmAnnee() {
		$this->phrase = "$this->nbFilmsPeriode film" . ( $this->nbFilmsPeriode > 1 ? 's' : '' ) . " pour la période $this->firstYearFirstPeriod - $this->endPeriode";

		$this->getXhtmlBoutons = $this->navigation->getXhtmlBoutons();
		$this->getXhtmlNumbers = $this->navigation->getXhtmlNumbers(intval(configuration::get('nbBetween2Numbers')), intval(configuration::get('styleNavigation')));

		$this->affichage = true;
		$i = (int)substr($this->startPeriode, 0, 4);
		$this->statistiquesCollection = new collection();

		while (($i < $this->endPeriode) // the calculed year is not > at now
		) {
			$nbFilm = $this->db->getNbFilmAtYear($i);
			$this->statistiquesCollection->ajouter(new statistique("année $i" , "$nbFilm film" . ( $nbFilm > 1 ? 's' : '')));
			$i++;
		}
		
		parent::genererVue();
	}
	
} // class

?>

