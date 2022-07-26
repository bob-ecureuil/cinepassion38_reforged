<?php
/*================================================================================================================
	fichier				: class.collection.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: mai 2013
	date de modification: décembre 2013
	                      novembre 2015	-> optimisation du code (changement des noms de variables, suppression d'une méthode, ...)
	                      juin 20117	-> respect de la numérotation "lower camel case"
	rôle				: décrit la classe collection qui permet de gérer une collection d'éléments
  ================================================================================================================*/

/**
 * La classe collection permet de gérer une collection d'éléments
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - mai 2013
 */
class collection {
	
	private $lesElements;		// le tableau où les éléments sont stockés
	private $tailleFixe;		// détermine si la collection possède un nombre fixe d'éléments
	private $tailleMax;			// le nombre d'éléments maximum gérés par la collection si la taille est fixe
	
	/**
	 * Le constructeur de la classe collection permet d'initialiser tous les attributs de la classe
	 * @param Boolean $tailleFixe : true si la taille est fixe, false sinon (false est la valeur par défaut)
	 * @param integer $tailleMax : le nombre maximum d'éléments qui sont gérés par la collection (valeur par défaut : 50)
	 * @return void
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function __construct($tailleFixe = false, $tailleMax = 50) {
		$this->lesElements = array();
		$this->tailleFixe = $tailleFixe;
		$this->tailleMax = $tailleMax;
	}

	/**
	 * Renvoie un booléen indiquant si la taille de la collection est fixe ou non.
	 * @param null 
	 * @return Boolean : true si la taille de la collection est fixe, false sinon.
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function estTailleFixe() {
		return $this->tailleFixe;
	}
	
	/**
	 * Renvoie le nombre maximum d'éléments qui sont gérés par la collection si sa taille est fixe
	 * @param null 
	 * @return integer : le nombre maximal d'éléments gérés par la collection si sa taille est fixe (false si la taille de la collection n'est pas fixe)
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function getTailleMax() {
		return ($this->estTailleFixe() ? $this->tailleMax : false);
	}
	
	/**
	 * Renvoie la clé correspondant à l'élément testé
	 * @param mixed $unElement : l'élément dont on veut récupérer la clé. Cet élément peut être de plusieurs types : string, object, ...
     * @throws Exception
     * @return mixed : La clé correspondant à l'élément passé en paramètre
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function getCle($unElement) {
		if (estPresent($unElement)) {
			return array_search($unElement, $this->lesElements);
		}else {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : l' élément '$unElement' n'a pas été trouvé dans la collection");
		}
	}
		
	/**
	 * Détermine si un élément est présent ou non dans la collection
	 * @param mixed $unElement : l'élément dont la présence est testée dans la collection. Cet élément peut être de plusieurs types : string, object, ... 
	 * @return boolean : true si l'élément est présent dans la collection, false sinon
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	private function estPresent($unElement) {
		if (!in_array($unElement, $this->lesElements)) {
			return false;
		}else {
			return true;
		}
	}
	
	/**
	 * Renvoie un booléen indiquant si la collection est pleine. La collection est considérée comme pleine si sa taille est fixe et si le nombre d'éléments la composant est égal au nombre maximal d'éléments
	 * @param null 
	 * @return Boolean : true si la collection est pleine, false sinon.
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function estPlein() {
		return !(!$this->estTailleFixe() or ($this->estTailleFixe() && $this->getTaille() < $this->getTailleMax()));
	}
	
	/**
	 * Renvoie le nombre d'éléments de la collection
	 * @param null 
	 * @return integer : le nombre d'éléments de la collection ou le booléen false s'il n'y a aucun élément
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function getTaille() {
		$taille = count($this->lesElements);
		return ($taille == 0 ? false : $taille);
	}
	
	/**
	 * Teste si la collection est vide
	 * @param null 
	 * @return Boolean : true si la collection est vide, false sinon
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - décembre 2013
	 */
	public function estVide() {
		return $this->getTaille() == 0;
	}
	
	/**
	 * Ajoute un élément à la collection
	 * @param mixed $unElement : l'élément à ajouter qui peut être de plusieurs types : string, object, ... 
	 * @throws Exception, ne exception est lancée si l'ajout d'un élément n'est pas possible en cas de collection pleine
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function ajouter($unElement) {
		if (!$this->estPlein()) {
			array_push($this->lesElements, $unElement);
		}else {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : impossible d'ajouter un élément à la collection car elle est pleine.");
		}
	}
		
	/**
	 * Supprime un élément de la collection
	 * @param mixed $unElement : l'élément à supprimer de la collection qui peut être de plusieurs types : string, object, ... 
	 * @throws Exception, une exception est lancée si l'élément qu'on essait de supprimer n'est pas présent dans la collection
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function supprimer($unElement) {
		if ($this->estPresent($unElement)) {
			unset($this->lesElements[$this->getCle($unElement)]);
		}else  {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : suppression impossible car l'élément n'est pas présent dans la collection");
		}
	}
	
	/**
	 * Renvoie tous les éléments de la collection sous forme d'une chaîne de caractères
	 * @param null 
	 * @return string : La liste des éléments sous forme d'une chaîne de caractères
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 * @deprecated
	 */
	public function getListeElements() {
		$Result = "";
		foreach ($this->GetArrayElements() as $Cle => $UnElement) {
			$Result .= $UnElement; //."<br/>";
		}
		return $Result;
	}
		
	/**
	 * Retourne l'élément de la collection à l'indice $indice. Si l'indice n'est pas précisé, on retourne l'élément à l'indice 0 avant de le supprimer
	 * @param integer $indice : la position dans la collection de l'élément à retourner. Valeur null par défaut
	 * @return mixed : l'élément de la collection à l'indice $indice s'il existe. false sinon
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juillet 2017
	 */
	public function getUnElement($indice = null) {
		if (is_null($indice)) {
			$unElement = array_shift($this->lesElements);
			return (is_null($unElement) ? false : $unElement);
		}else {		
			if (isset($this->lesElements[$indice])) {
				return $this->lesElements[$indice];
			}else {
				return false;
			}
		}
	}

} // fin class

?>
