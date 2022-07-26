<?php
/*================================================================================================================
	fichier				: class.encart.inc.php
	auteur				: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
	date de création	: mai 2013
	date de modification: juin 2017	-> respect de la numérotation "lower camel case" 
	rôle				: décrit la classe encart qui permet de gérer les encarts d'une page web
  ================================================================================================================*/

/**
 * La classe encart permet de gérer les encarts du site
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - mai 2013
 */
class encart {
	
	private $titre;					// Le titre de l'encart
	private $contenu;				// Le contenu de l'encart
	
	/**
	 * Le constructeur permet d'hydrater tous les attributs de la classe encart en appelant les setteurs appropriés
	 * @param string $fichier : l'adresse du fichier texte concenant les informations de l'encart
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.1
	 * @copyright Christophe Goidin - Juin 2017
	 */	
	public function __construct($fichier) {
		$this->setEncart($fichier);
	}
	
	/**
	 * Renvoie le titre de l'encart
	 * @param null 
	 * @return string : le titre de l'encart 
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function getTitre() {
		return $this->titre;
	}
	
	/**
	 * Renvoie le contenu de l'encart
	 * @param null 
	 * @return string : le contenu de l'encart 
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function getContenu() {
		return $this->contenu;
	}
	
	/**
	 * Positionne le titre de l'encart
	 * @param string $titre : le titre de l'encart
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function setTitre($titre) {
		$this->titre = $titre;
	}
	
	/**
	 * Positionne le contenu de l'encart
	 * @param string $contenu : le contenu de l'encart
	 * @return null
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function setContenu($contenu) {
		$this->contenu = $contenu;
	}
	
	/**
	 * Positionne le titre et le contenu de l'encart à partir du fichier texte passé en paramètre
	 * 
	 * La structure du fichier texte doit obligatoirement être la suivante :
	 * ======================================================
	 *    Titre : xxx
	 * ======================================================
	 * UneLigne
	 * #UneLigne	si une ligne commence par le caractère #, alors le contenu de la ligne sera centré
	 * *UneLigne	si une ligne commence par le caractère *, alors une image sera insérée avant le contenu de la ligne
	 * 
	 * @param string $fichier : l'adresse du fichier texte à analyser
	 * @return null
	 * @throws Exception, une exception est lancée si le fichier texte est introuvable
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	private function setEncart($fichier) {
		if (($refFichier = fopen($fichier, "r")) !== False) {
			
			// =====================================================================================================================================================
			// lecture du titre : on ignore les lignes n°1 et n°3 et on lit le contenu de la ligne n°2 à partir du caractère n°12
			// =====================================================================================================================================================
			fgets($refFichier);
			for ($i = 1; $i <= 11; $i++) {
				fgetc($refFichier);
			}
			$titre = fgets($refFichier);
			fgets($refFichier);
				
			$contenu = "";
			$i = 0;
			$saut = true;
			while (!feof($refFichier)) {
				// =====================================================================================================================================================
				// insertion d'un saut de ligne XHTML
				// =====================================================================================================================================================
				if ($i <> 0 && $saut) {
					$contenu .= "<br/>";
				}else {
					$i++;
				}
				
				// =====================================================================================================================================================
				// lecture d'une ligne
				// =====================================================================================================================================================
				$debutLigne = fgetc($refFichier);			// on lit le premier caractère de la ligne
				switch($debutLigne) {
					case "#" :
						$saut = false; 						// on lit le reste de la ligne, c'est-à-dire à partir du second caractère puisque le premier caractère a déjà été lu avec la fonction fgetc
						$contenu .= "<span class='centrer'>" . fgets($refFichier) . "</span>";
						break;
					case "*" :
						$saut = true;
						$contenu .= "* "; 					//<img alt='' src=\"".DIR_IMAGE_DIVERS."Boule.png\" /> ";
						$contenu .= fgets($refFichier);		// on lit le reste de la ligne, c'est-à-dire à partir du second caractère puisque le premier caractère a déjà été lu avec la fonction fgetc
						break;
					default :
						$saut = true;
						fseek($refFichier, -1, SEEK_CUR);	// on déplace le curseur de position d'un caractère en arrière afin de ne pas "oublier" le caractère lu précédemment avec la fonction fgetc     
						$contenu .= fgets($refFichier);		// on lit la ligne entière, y compris le premier caractère
						break;
				}
			}
			fclose($refFichier);
			$this->setTitre(preg_replace("/(\r\n|\n|\r|\t)/", "", $titre));
			$this->setContenu(preg_replace("/(\r\n|\n|\r|\t)/", "", $contenu));
		}else {
			throw new Exception("[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le fichier texte '$fichier' est introuvable");
		}
	}
	
	/**
	 * Renvoie le bloc xhtml relatif à l'encart
	 * @param null
	 * @return string : le bloc xhtml relatif à l'encart 
	 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function getXhtml() {
		return "<div class='unEncart'>\n
					<span class='titre'>" . $this->getTitre() . "</span>\n" .
					$this->getContenu() . "\n" .
			   "</div><!-- unEncart -->\n";
	}
		
	/**
	 * Méthode MAGIQUE appelée AUTOMATIQUEMENT lorsque l'utilisateur essaie d'afficher un objet de la classe. La méthode getXhtmlEncart() est alors appelée.
	 * @param null
	 * @return string : le bloc xhtml relatif à l'encart 
	 * @author : Christophe Goidin <christophe.goidin@ac-grenoble.fr>
	 * @version : 1.0
	 * @copyright Christophe Goidin - mai 2013
	 */
	public function __toString() {
		return $this->getXhtmlEncart();
	}

} // fin class

?>
