<?php
/*=============================================================================================================
	fichier				: class.statistique.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: novembre 2013
	date de modification:  
	rôle				: décrit la classe statistique qui permet de gérer les statistiques
===============================================================================================================*/

/**
 * La classe statistique permet de gérer les statistiques des films
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - Novembre 2013
 */
class statistique {
	
	// =====================================================================================================================================================
	// les attributs
	// =====================================================================================================================================================
	private $titre;					// le titre de la statistique
	private $infos;					// l'information de la statistique
	private $selecteurCss;			// le sélection CSS utilisé pour la mise en forme de la statistique
	private $visibilite;			// la visibilité de la statistique. true => visible. false => invisible
	
	
	// =====================================================================================================================================================
	// le constructeur
	// =====================================================================================================================================================
	/**
	 * Le constructeur permet d'hydrater tous les attributs de la classe statistique en appelant les setteurs appropriés
	 * @param string $titre : le titre 
	 * @param string $infos : l'information
	 * @param boolean $visibilite : true si la statistique est visible (valeur par défaut). false sinon.
	 * @param string $selecteurCss : le sélecteur CSS relatif à la statistique (valeur par défaut : "stat").
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.1
	 * @copyright Christophe Goidin - décembre 2013
	 */	
	public function __construct($titre, $infos, $visibilite = true, $selecteurCss = "stat") {
		$this->setTitre($titre);
		$this->setInfos($infos);
		$this->setVisibilite($visibilite);
		$this->setSelecteurCss($selecteurCss);
	}
	
	
	// =====================================================================================================================================================
	// les accesseurs (ou getter)
	// =====================================================================================================================================================
	/**
	 * Renvoie le titre de la statistique
	 * @param null 
	 * @return string : le titre de la statistique
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	private function getTitre(){
		return $this->titre;
	}
	
	/**
	 * Renvoie l'information de la statistique
	 * @param null 
	 * @return string : l'information de la statistique
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	private function getInfos() {
		return $this->infos;
	}
	
	/**
	 * Renvoie la visibilité de la statistique
	 * @param null 
	 * @return boolean : la visibilité de la statistique
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - novembre 2014
	 */
	private function getVisibilite() {
		return $this->visibilite;
	}
	
	/**
	 * Renvoie le sélecteur CSS relatif à la statistique
	 * @param null 
	 * @return string : le sélecteur CSS relatif à la statistique
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - novembre 2013
	 */
	private function getSelecteurCss() {
		return $this->selecteurCss;
	}
		
	// =====================================================================================================================================================
	// les mutateurs (ou setter)
	// =====================================================================================================================================================
	/**
	 * Positionne le titre de la statistique
	 * @param string $value : le titre de la statistique
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	private function setTitre($value) {
		$this->titre = $value;
	}
	
	/**
	 * Positionne l'information de la statistique
	 * @param string $value : l'information de la statistique
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	private function setInfos($value) {
		$this->infos = $value;
	}
	
	/**
	 * Positionne la visibilité de la statistique
	 * @param boolean $value : la visibilité de la statistique
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - novembre 2014
	 */
	private function setVisibilite($value) {
		$this->visibilite = $value;
	}
	
	/**
	 * Positionne le sélecteur CSS relatif à la statistique
	 * @param string $value : le sélecteur Css relatif à la statistique
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - novembre 2013
	 */
	private function setSelecteurCss($value) {
		$this->selecteurCss = $value;
	}
	
	// =====================================================================================================================================================
	// les autres méthodes
	// =====================================================================================================================================================
	/**
	 * Détermine si la statistique est visible ou non
	 * @return boolean : true si la statistique est visible. false sinon.
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - novembre 2014
	 */
	private function estVisible() {
		return $this->visibilite;
	}
	
	/**
	 * Renvoie le bloc xhtml relatif à la statistique
	 * @param null
	 * @return string : le bloc xhtml relatif à la statistique 
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	public function getXhtmlStatistique() {
		$result = '';
		
		if ($this->visibilite) {
			$result .= '<div class="statistiqueElement">';
			$result .= '<div class="titre">' . $this->titre . '</div>';
			$result .= '<br/>';
			$result .= '<div class="infos">' . $this->infos . '</div>';
			$result .= '</div>';
		}
		
		return $result;
	}
		
	/**
 	 * Méthode MAGIQUE appelée automatiquement lorsque l'utilisateur essaie d'afficher un objet de la classe. La méthode getXhtmlStatistique() est alors appelée.
 	 * @param null
 	 * @return string : le bloc xhtml relatif à la statistique
 	 * @author : Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 	 * @version : 1.0
 	 * @copyright Christophe Goidin - novembre 2013
 	 */
 	public function __toString() {
		return $this->getXhtmlStatistique();
	}

} // class

?>
