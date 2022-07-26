<?php
/*=========== M O D E L E ========================================================================================
	fichier				: class.modele.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juillet 2012
	date de modification: juin 2017 : refactoring MVC objet 
	rôle				: la classe générique d'accès aux données. Joue le rôle du modèle dans l'architecture MVC.
  ================================================================================================================*/

/**
 * Classe d'accès aux données utilisant l'API PDO (Php Data Object) et implémentant le design pattern Singleton
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 2.0
 * @copyright Christophe Goidin - juin 2017
 */
abstract class modele {
	
	private static $bd = null;	// l'instance de la connexion à la base de données
	
	/**
	 * Renvoie l'instance de connexion à la base de données, en initialisant la connexion si nécessaire. Mise en oeuvre du patron de conception Singleton
	 * @param null
	 * @return L'instance de la connexion à la base de données
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 2.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	private static function getBd() {
		if (self::$bd === null) {
			// ===============================================================================================================
			// récupération des paramètres de configuration relatifs à la base de données
			// ===============================================================================================================
		    $serveur 	= configuration::get("dbserverName");
		    $base 		= configuration::get("dbBaseName");
		    $login 		= configuration::get("dbLogin");
		    $mdp 		= configuration::get("dbPassword");
			
			// ===============================================================================================================
			// création de la connexion à la base de données. PDO émettra une exception en cas de problème de connexion
			// ===============================================================================================================
			self::$bd = new PDO("mysql:host=" . $serveur . ";dbname=" . $base . ";charset=utf8", $login, $mdp, array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
		}
		return self::$bd;
	}
	
	/**
	 * Exécute une requête SQL. La requête SQL sera préparée si le second paramètre ne vaut pas null.
	 * @param string $sql : la requête SQL à exécuter
	 * @param array $params : un tableau associatif contenant les valeurs des marqueurs (les marqueurs peuvent être nommés ou interrogatifs)
	 * @return PDOStatement : le résultat de l'exécution de la requête SQL sous forme d'un objet PDOStatement
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 2.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	protected function executerRequete($sql, $params = null) {
		if ($params == null) {
			// ===============================================================================================================
			// exécution directe
			// ===============================================================================================================
			$resultat = self::getBd()->query($sql);

		}else {
			// ===============================================================================================================
			// exécution d'une requête préparée
			// ===============================================================================================================
			$resultat = self::getBd()->prepare($sql);
			$resultat->execute($params);
		}
		return $resultat;
	}

} // class

?>
