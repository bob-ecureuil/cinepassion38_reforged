<?php
/*================================================================================================================
	fichier				: class.routeur.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:  
	rôle				: la classe routeur permet d'aiguiller/router automatiquement vers le contrôleur et l'action à réaliser 
  ================================================================================================================*/

/**
 * Classe permettant d'aiguiller/router automatiquement vers le contrôleur et l'action à réaliser
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class routeur {

	/**
	 * Route une requête entrante et exécute l'action associée
	 * @param null
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	public function routerRequete() {
		try {
			$requete = new requete(array_merge($_GET, $_POST));
			$controleur = $this->creerControleur($requete);
			$controleur->executerAction();
		}catch (Exception $e) {
			$this->gererErreur($e);
		}
	}

	/**
	 * Créé le contrôleur approprié en fonction de la requête HTTP reçue
	 * @param requete RequeteHTTP $requete : la requête HTTP
	 * @return string le contrôleur créé
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
     * @throws Exception
     * @copyright Christophe Goidin - juin 2017
     * @update Thomas Graulle 06/12/2018, 
	 */
	private function creerControleur(requete $requete) {
		
		// ===============================================================================================================
		// Path of the controller
		// ===============================================================================================================		
		$fichierController = './mvc/controleur/';
		$extensionController = configuration::get('extensionController');
		
		// ===============================================================================================================
		// Default parameters
		// ===============================================================================================================
		$module = 'home';
		$page = 'accueil';
		$action = 'defaut'; // not using for the moment
		
		// ===============================================================================================================
		// gestion du paramètre module
		// ===============================================================================================================
		if ($requete->existeParametre("module") && $requete->valideParametre("module", $fichierController)) {
			$module = $requete->getParametre("module");
			
			// ===============================================================================================================
			// gestion du paramètre page
			// ===============================================================================================================
			if ($requete->existeParametre("page") && $requete->valideParametre("page", "$fichierController$module/" )) {
				$page = $requete->getParametre("page");
				
				// ===============================================================================================================
				// gestion du paramètre onglet
				// ===============================================================================================================
				if ($requete->existeParametre("action")) {
					$action = $requete->getParametre("action");
				}
			}		
		}
				
		// ===============================================================================================================
		// convertion de la valeur de certains paramètres en minuscule
		// ===============================================================================================================
		$module = strtolower($module);
		$page = strtolower($page);
	
		// ===============================================================================================================
		// définition du nom du fichier et du nom de la classe du contrôleur 
		// ===============================================================================================================
		$fichierControleur = "./mvc/controleur/" . $module . "/" . $page . $extensionController;
		$classeControleur = "controleur" . $this->reformater($module) . $this->reformater($page);

		// ===============================================================================================================
		// création du contrôleur avant de le retourner au programme appelant
		// ===============================================================================================================
		if (!file_exists($fichierControleur)) {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le fichier '$fichierControleur' est introuvable.");
		}else {
			try {
				require_once($fichierControleur);
				$controleur =  new $classeControleur();
				$controleur->setRequete($requete, $module, $page, $action);
				$controleur->setDonnees();
				return $controleur;
			}catch (Exception $e) {
				throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : impossible de créer le contrôleur '$classeControleur'. " . $e->getMessage() . "<br/>");
			}
			
		}
	}

	/**
	 * Reformate une chaîne de caractères en minuscule avec la première lettre en majuscule
	 * @param string $chaine : La chaîne à reformater
	 * @return string : La chaîne reformatée en minuscule avec la première lettre en majuscule
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */ 
	private function reformater($chaine) {
		return ucfirst(strtolower($chaine));
	}

	/**
	 * Gère les erreurs d'exécution en générant la vue "erreur"
	 * @param Exception $e : l'exception qui a été attrapé
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */ 
	private function gererErreur(Exception $e) {
		$vue = new vue("erreur");
		$vue->generer(array("messageErreur" => $e->getMessage()));
	}

} // class

?>
