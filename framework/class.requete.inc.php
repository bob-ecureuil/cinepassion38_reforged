<?php
/*================================================================================================================
	fichier				: class.requete.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:  
	rôle				: modéliser la requête HTTP
  ================================================================================================================*/

/**
 * Classe permettant de modéliser la requête HTTP
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class requete {

	private $parametres;	// le tableau associatif rassemblant les paramètres de la requête HTTP
	private $charProhibited;

	/**
	 * Le constructeur de la classe
	 * @param array $parametres : Un tableau associatif contenant les paramètres de la requêtes HTTP
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 * @update Thomas GRAULLE - 17/10/2019
	 */
	public function __construct($parametres) {
		$this->parametres = $parametres;
		$this->charProhibited = str_split(configuration::get('requetCharProhibited'));
	}

	/**
	 * Renvoie le booléan vrai si le paramètre existe dans la requête HTTP et qu'il ne continent pas de caractère non voulu.
	 *
	 * @param string $nom : le nom du paramètre dont on veut tester l'existence
	 * @return boolean : true si le paramètre existe et qu'il ne vaut pas "" dans la requete HTTP. False sinon
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 3.0
	 * @copyright Christophe Goidin - juin 2017
	 * @update by Thomas GRAULLE - 17/10/2019
	 */
	public function existeParametre($nom) {
		return (isset($this->parametres[$nom]) && ($this->parametres[$nom] != "" && $this->validModuleName($nom)));
	}

	/**
	 * @author Thomas GRAULLE
	 * @date 17/10/2019
	 * @version 3.0
	 *
	 * @param string $nom: Name of module who want test
	 * @return bool: return if is prohibided or not
	 */
	public function validModuleName($nom) {
		$result = true;
		foreach ($this->charProhibited as $value) {
			if (strpos($nom, $value)) {
				$result = false;
			}
		}
		return $result;
	}

	/**
	 * Renvoie la valeur du paramètre demandé. Une exception est levée si le paramètre est introuvable
	 *
	 * @param string $nom : le nom du paramètre dont on veut récupérer la valeur
	 * @param bool $exception : le nom du paramètre dont on veut récupérer la valeur
	 *
	 * @return string|null : la valeur du paramètre ou si le paramètre $exception = false, retourne null
	 *
	 * @throws Exception
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 * @update by Thomas Graulle 15/12/18
	 */
	public function getParametre($nom, $exception = true) {
		if ($this->existeParametre($nom)) {
			return $this->parametres[$nom];
		} elseif ( $exception) {
            throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le paramètre '$nom' est absent de la requête HTTP");
		}

		return null;
	}
	
	/**
	 * Valide parameter, this function check if the file or folder exist. 
	 * 
	 * @param string $key, this param is the key of the 
	 * @param string $path
	 * 
	 * @return bool, return true if the file or folder exist, with the parameters
	 */
	public function valideParametre($key, $path) {
		return file_exists($path . $this->parametres[$key]) || file_exists($path . $this->parametres[$key] . '.inc.php');
	}

} // class

?>
