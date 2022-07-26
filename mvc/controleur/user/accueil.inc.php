    <?php
/*======= C O N T R O L E U R ====================================================================================
 fichier				: ./mvc/controleur/user/accueil.inc.php
 auteur				: Axel PUGLISI
 date de création	: mars 2019
 date de modification:
 rôle				: le contrôleur de la page d'accueil de user
 ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page user du domaine cinepassion38
 * @author Axel PUGLISI
 * @version 1.0
 * @date mars 2019
 */
class controleurUserAccueil extends controleur {

	public function __construct() {
	}
	
	/**
	 * Met à jour le tableau $donnees de la classe mère avec les informations spécifiques de la page
	 * @param null
	 * @return null
	 * @author Axel PUGLISI
	 * @version 1.1
	 * @date Mars 2019
	 */
	public function setDonnees() {
		// ===============================================================================================================
		// titres de la page
		// ===============================================================================================================
		$this->titreHeader = "présentation de User";
		$this->titreMain = "User";

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
     * @author Axel PUGLISI
	 * @date Mars 2019
     * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @param null|void
	 */
	public function defaut() {

        parent::genererVue();
	}

} // class

?>

