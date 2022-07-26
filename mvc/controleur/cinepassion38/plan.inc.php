<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/cinepassion38/plan.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:
	rôle				: le contrôleur de la page présentant le plan de l'association
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page présentant le plan de l'association
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class controleurCinepassion38Plan extends controleur {
	
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
		$this->titreHeader = "où nous trouver ?";
		$this->titreMain = "la situation géographique de notre association";
		
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
		// divers
		// ===============================================================================================================
		$this->plan = '<iframe width="940" height="450" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.fr/maps?q=45.168726,5.708328&amp;num=1&amp;hl=fr&amp;ie=UTF8&amp;t=m&amp;ll=45.165942,5.717783&amp;spn=0.027232,0.080681&amp;z=14&amp;output=embed"></iframe>';
		$this->lienGoogleMaps = "https://maps.google.fr/maps?q=45.168726,5.708328&amp;num=1&amp;hl=fr&amp;ie=UTF8&amp;t=m&amp;ll=45.165942,5.717783&amp;spn=0.027232,0.080681&amp;z=14&amp;source=embed";
		
		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
		
		// ===============================================================================================================
		// écrasement de la valeur définie dans la classe mère (doctype strict 1.0)
		// ===============================================================================================================
		$this->doctype = configuration::get("doctypeTransitional");
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

