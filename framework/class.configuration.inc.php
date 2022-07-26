<?php
/*================================================================================================================
	fichier				: class.configuration.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:  
	rôle				: la classe configuration gère la configuration du site web.
  ================================================================================================================*/

/**
 * La classe configuration gère la configuration du site web
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */

class configuration {

	private static $parametres = null;	// Le tableau associatif contenant l'ensemble des paramètres du fichier de configuration

	/**
	 * Renvoie le tableau associatif contenant l'ensemble des paramètres en le chargeant si besoin. Une exception est déclenchée si aucun fichier de configuration n'a été trouvé.
	 * @static
	 * @param null
	 * @return array : le tableau associatif contenant l'ensemble des paramètres
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	private static function getParametres() {
		if (self::$parametres == null) {
			$cheminFichier = "./configuration/prod.ini";
			if (!file_exists($cheminFichier)) {
				$cheminFichier = "./configuration/dev.ini";
			}
			if (!file_exists($cheminFichier)) {
				throw new Exception("[" . __CLASS__ . "] Aucun fichier de configuration n'a été trouvé");
			}else {
				self::$parametres = parse_ini_file($cheminFichier);
			}
		}
		return self::$parametres;
	}

	/**
	 * Renvoie la valeur d'un paramètre de configuration (null si le paramètre n'existe pas)
	 * @static
	 * @param string $nom : le nom du paramètre de configuration
	 * @param string $valeurParDefaut : la valeur par défaut (null par défaut)
	 * @return string : la valeur du paramètre de configuration
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	public static function get($nom, $valeurParDefaut = null) {
		if (isset(self::getParametres()[$nom])) {
			$valeur = self::getParametres()[$nom];
		}else {
			$valeur = $valeurParDefaut;
		}
		return $valeur;
	}

} // class

?>
