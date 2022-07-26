
<?php
/*================================================================================================================
	fichier				: class.vue.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: juin 2017
	date de modification:  
	rôle				: classe regroupant les services communs à toutes les vues.
  ================================================================================================================*/

/**
 * Classe regroupant les services communs à TOUTES les vues
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
class vue {

    
	private $fichier;		// le nom du fichier contenant la définition de la vue
	
	/**
	 * Le constructeur de la classe vue permet de définir le nom du fichier contenant la définition de la vue
	 * @param string $module : la valeur du paramètre module
	 * @param string $page : la valeur du paramètre page
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	public function __construct($module, $page = "") {
		if ($module == "erreur") {
			$this->fichier = "./mvc/vue/templates/erreur.inc.php";
		}else {
			$this->fichier = "./mvc/vue/" . $module . "/" . $page . ".inc.php";
		}
	}

	/**
	 * Génère et affiche la vue
	 * @param array $donnees : les informations à afficher
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */

	public function generer($donnees) {
		// ===============================================================================================================
		// génération de la page d'erreur complète
		// ===============================================================================================================
		if ($this->fichier == "./mvc/vue/templates/erreur.inc.php") {
			$vue = $this->genererFichier($this->fichier, $donnees);
		
		// ===============================================================================================================
		// génération d'une page "normale"
		// ===============================================================================================================
		}else {
			
			// ===============================================================================================================
			// génération de la partie spécifique de la vue
			// ===============================================================================================================
			$content1 = $this->genererFichier($this->fichier, $donnees, "content1");
			$content2 = $this->genererFichier($this->fichier, $donnees, "content2");
			
			
			// ===============================================================================================================
			// ajout des parties spécifiques de la vue au tableau $donnees
			// ===============================================================================================================
			if ($content1 != "") {
				$donnees['content1'] = $content1;
			}
			$donnees['content2'] = $content2;
			
			
			// ===============================================================================================================
			// génération du gabarit commun (qui utilise les parties spécifiques)
			// ===============================================================================================================
			$vue = $this->genererFichier('./mvc/vue/templates/layout.inc.php', $donnees);
		}
		// echo $vue;
		$_SESSION['page'] = $vue;
		 header('Location:./redirection.php');
		 exit;
	}

	/**
	 * Génère la vue et renvoie le résultat obtenu
	 * @param string $fichier : le fichier "vue" à générer
	 * @param array $donnees : les informations nécessaires à la vue afin de générer le contenu 
	 * @param string $id : le nom de l'id dont on veut récupérer le contenu du bloc <div>. null par défaut -> on récupère alors l'intégralité du contenu du fichier
	 * @return string : le code xhtml relatif à la vue
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 */
	private function genererFichier($fichier, $donnees, $id = null) {
		if (file_exists($fichier)) {
			extract($donnees);				// génération des variables à partir du tableau $donnees afin qu'elles puissent être utilisées par la vue
			ob_start();						// démarrage de la temporisation de sortie
			if (is_null($id)) {				// récupèration de l'INTEGRALITE du contenu du fichier $fichier
				require $fichier;
			}else {							// récupèration du contenu du bloc <div id='$id'> du fichier $fichier. Pour celà, on génère temporairement un fichier texte afin de pouvoir l'inclure 
				$temp = "./buffer/temp.php";// "." représente la racine du projet sur le serveur web, soit le dossier C:\wamp64\www\cinepassion38
				$handle = fopen($temp, "w");
				include_once "./framework/class.fs.inc.php";
				fwrite($handle, fs::getContenuFichier($fichier, $id));
				fclose($handle);
				require $temp;
				unlink($temp);				// suppression du fichier temporaire
			}
			return ob_get_clean();			// fin de la temporisation de sortie et retour du contenu courant du tampon
		}else {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le fichier '$fichier' est introuvable.");
		}
	}

	/**
	 * Nettoie la chaîne de caractères passée en paramètre
	 * @param string $chaine : la chaîne de caractères à nettoyer
	 * @return string : la chaîne de caractères nettoyée
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - juin 2017
	 * @deprecated
	 */
	private function nettoyerOLD($chaine) {
		return htmlspecialchars($chaine, ENT_QUOTES, 'UTF-8', false);
	}
	
} // class

?>
