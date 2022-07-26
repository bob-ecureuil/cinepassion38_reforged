<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/cinepassion38/partenaire.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:
	rôle				: le contrôleur de la page présentant les partenaires de l'association
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page présentant les partenaires du domaine Cinepassion38
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class controleurCinepassion38Partenaire extends controleur {
	
	/**
	 * Met à jour le tableau $donnees de la classe mère avec les informations spécifiques de la page
	 * @param null
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.1
	 * @copyright Christophe Goidin - juin 2017
	 */
	public function setDonnees() {
		// ===============================================================================================================
		// titres de la page
		// ===============================================================================================================
		$this->titreHeader = "nos différents partenaires";
		$this->titreMain = "les différents partenaires de notre association";
		
		// ===============================================================================================================
		// encarts
		// ===============================================================================================================
		$this->encartsDroite = $this->getRandomEncartRight(1);
		$this->encartsGauche = $this->getRandomEncartLeft(1);
		
		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
		// rien
		
		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
	}
	
	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page 
	 * @param null
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	public function defaut() {
		parent::genererVue();
	}

} // class

?>

