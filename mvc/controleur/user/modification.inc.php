    <?php
/*======= C O N T R O L E U R ====================================================================================
 fichier				: ./mvc/controleur/user/modification.inc.php
 auteur				: Thomas Graulle
 date de création	: mars 2019
 date de modification:
 rôle				: le contrôleur de la page modification
 ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page de modification
 * @author thomas Graulle
 * @version 1.0
 * @date avril 2019
 */
class controleurUserModification extends controleur {

	public function __construct() {
		$this->db = new modeleUserAuthentification();
	}
	
	/**
	 * Met à jour le tableau $donnees de la classe mère avec les informations spécifiques de la page
	 * @param null
	 * @return null
	 * @author Thomas Graulle
	 * @version 1.1
	 * @date Mars 2019
	 */
	public function setDonnees() {
		// ===============================================================================================================
		// titres de la page
		// ===============================================================================================================
		$this->titreHeader = "Authentification";
		$this->titreMain = "Authentification";

		// ===============================================================================================================
		// encarts
		// ===============================================================================================================
		$this->encartsDroite = $this->getRandomEncartRight(4);
		$this->encartsGauche = $this->getRandomEncartLeft();
		
		// ===============================================================================================================
		// texte défilant
		// ===============================================================================================================
        $this->globalHeaderLink = $this->getEnteteLien('simpleSlideShow') . PHP_EOL;
        
		// ===============================================================================================================
		// alimentation des données COMMUNES à toutes les pages
		// ===============================================================================================================
		parent::setDonnees();
	}

	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
     * @author Thomas Graulle
	 * @date Mars 2019
     * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @param null|void
	 */
	public function modifyPassword() {
		// ==========================================
		// Get into the Database the private key
		// ==========================================
		$this->dbEncryption = new modeleRsa();
		$privatKay = $this->dbEncryption->getPrivateKeyRsa(configuration::get('rsaNumKey'));

		// ==========================================
		// Uncrypt information
		// ==========================================
		$uncryptCredential = $this->uncrypt(array($_POST['encryptyOldPassword'], $_POST['encryptyNewPassword']), $privatKay);

		$aLogin = $uncryptCredential[0];
		$aPassword = $uncryptCredential[1];
		
		// ==========================================
		// Check if the connexion is valid
		// ==========================================
		if ($this->db->userExist($aLogin)) {
			
			// ==========================================
			// Hash the password
			// ==========================================
			$aPasswordHashed = hash('sha512', $aPassword);
			$user = $this->db->getUserIfCorrectCredential($aLogin, $aPasswordHashed); // return false if the credential is wrong
			
			if ($user) {
				// ==========================================
				// Update the information of the user, number of connexion and the last connexion 
				// ==========================================
				$this->db->incrementNbEchecConnexion($aLogin, 'reset'); // increment the number of failed connexion
				$this->db->incrementNbConnexionReussite($aLogin); // increment the number of failed connexion
 				$this->db->updateTheDateOfLastConnexion($aLogin);

				// ==========================================
				// Stock the information of the user into a session
				// ==========================================
				$_SESSION['user'] = $user;				
				
				// ==========================================
				// Redirection
				// ==========================================
				header('Location:./index.php?module=user&page=authentification&action=connexionSuccessful');
				exit;

			} else {
				// ==========================================
				// Update the infromation of the user, number of connexion failed 
				// ==========================================
				$this->db->incrementNbEchecConnexion($aLogin, 'increment'); // increment the number of failed connexion

				// ==========================================
				// Redirection
				// ==========================================
				header('Location:./index.php?module=user&page=authentification&action=connexionFailed');
				exit;
			}

		} else {
			// ==========================================
			// Redirection
			// ==========================================
			header('Location:./index.php?module=user&page=authentification&action=connexionFailed');
			exit;
		}

        parent::genererVue();
	}

	
	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
	 * @author Thomas Graulle
	 * @date Mars 2019
	 * @version 2.1
	 * @throws Exception, used for database call
	 *
	 * @param null|void
	 */
	public function defaut() {
		$this->formulaire = fs::getContenuFichier("./formulaire/form.modificationUser.inc.php");
		parent::genererVue();
	}
	
	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
	 * @author Thomas Graulle
	 * @date Mars 2019
	 * @version 2.1
	 * @throws Exception, used for database call
	 *
	 * @param null|void
	 */
	public function modifySuccessful() {
		$this->show = $this->message = "Connexion réussit";
		parent::genererVue();
	}

	/**
	 * Génère l'affichage de la vue pour l'action par défaut de la page
	 *
	 * @author Thomas Graulle
	 * @date Mars 2019
	 * @version 2.1
	 * @throws Exception, used for database call
	 *
	 * @param null|void
	 */
	public function modifyFailed() {
		$this->show = $this->message = "Connexion RATE !";

		parent::genererVue();
	}

} // class

?>

