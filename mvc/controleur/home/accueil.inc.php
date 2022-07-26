<?php
/*======= C O N T R O L E U R ====================================================================================
	fichier				: ./mvc/controleur/home/accueil.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:
	rôle				: le contrôleur de la page d'accueil du site
  ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page d'accueil du site
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class controleurHomeAccueil extends controleur {
		
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
		$this->titreHeader = "accueil du site";
		$this->titreMain = "page d'accueil du site de notre association";
		
		// ===============================================================================================================
		// encarts
		// ===============================================================================================================
		// rien
		
		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
		$this->texteDefilant = parent::getTexteDefilant("derniereMinute.txt");
		
		// ===============================================================================================================
		// liens à intéger dans l'entête de la page
		// ===============================================================================================================
 		$this->enteteLien = $this->getEnteteLien('slidesjs') .
			$this->getEnteteLien('liscroll')
		;

				
		// ===============================================================================================================
		// galerie photos slidesjs
		// ===============================================================================================================
		$this->slidejs = $this->getGalerie();
		
		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
	}
	
	/**
	 * Renvoie un tableau composé des images et des textes utiles pour la génération de la galerie photos slidesjs 
	 * @param null
	 * @return array : un tableau composé des images et des textes utiles pour la génération de la galerie slidesjs
	 * @throws
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	private function getGalerie() {
		$dossier = "./image/pageAccueil";
		if (($ptrDossier = opendir($dossier)) !== false) {
			$tabCaption = parent::getContentFile('./texte/slidejs.txt');
			$i = 0;
			while (($fichier = readdir($ptrDossier)) !== false) {
				if (($fichier != ".") and ($fichier != "..") and ((pathinfo($fichier, PATHINFO_EXTENSION) == "jpg") or (pathinfo($fichier, PATHINFO_EXTENSION) == "jpeg") or (pathinfo($fichier, PATHINFO_EXTENSION) == "png"))) {
					$result[$i]['caption'] = $tabCaption[$i];
					$result[$i]['image'] = $dossier . "/" . $fichier;
					$i += 1;
				}
			}
			closedir($ptrDossier);
			return $result;
		}else {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le dossier " . $dossier . " n'existe pas.");
		}
	}
	
	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page 
	 * @param null
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - Juin 2017
	 */
	public function defaut() {
		parent::genererVue();
	}

} // class
 
?>

