    <?php
/*======= C O N T R O L E U R ====================================================================================
 fichier				: ./mvc/controleur/user/authentification.inc.php
 auteur				: Thomas Graulle
 date de création	: mars 2019
 date de modification:
 rôle				: le contrôleur de la page d'authentification
 ================================================================================================================*/

/**
 * Classe relative au contrôleur de la page d'authentification
 * @author thomas Graulle
 * @version 1.0
 * @date mars 2019
 */
class controleurUserAuthentification extends controleur {

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
	 * In this function, I check is the connexion is valid. And I update the database for save the action (failed connexion for example)
	 *
     * @author Thomas Graulle
	 * @date Mars 2019
     * @version 2.1
	 * @throws Exception, used for database call
	 *
     * @param null|void
	 */
	public function defaut() {
		// ==========================================
		// Get into the Database the private key
		// ==========================================
		$this->dbEncryption = new modeleRsa();
		$privatKay = $this->dbEncryption->getPrivateKeyRsa(configuration::get('rsaNumKey'));

		// ==========================================
		// Uncrypt information
		// ==========================================
		$uncryptCredential = $this->uncrypt(array($_POST['encryptyId'], $_POST['encryptyPassword']), $privatKay);

		$aLogin = $uncryptCredential[0];
		$aPassword = $uncryptCredential[1];

		$arraySpecialChar = explode(';',$this->arraySpecialChar);
		// ==========================================
		// Check if the connexion is valid
		// ==========================================
		if ( !$this->charInString($arraySpecialChar, $aLogin) && !$this->charInString($arraySpecialChar, $aPassword) && $this->db->userExist($aLogin)) {
			// ==========================================
			// Recept the "grain de sel" and hash the password 
			// ==========================================
			$grainDeSel = $this->db->getGrainDeSelUser($aLogin);
			$aPasswordHashed = $this->hashStringWithGrainSel($aPassword, $grainDeSel);
			$user = $this->db->getUserIfCorrectCredential($aLogin, $aPasswordHashed); // return false if the credential is wrong
			
			if ($user) {
				// ==========================================
				// Update the information of the user, number of connexion and the last connexion 
				// ==========================================
				$this->db->incrementNbEchecConnexion($aLogin, 'reset'); // increment the number of failed connexion
				$this->db->incrementNbConnexionReussite($aLogin); // increment the number of failed connexion
 				$this->db->updateTheDateOfLastConnexion($aLogin); // increment the date about a last connexion
 				
 				// ==========================================
 				// Update the credential and the 'grain de sel'
 				// ==========================================
 				$this->db->updateGrainSel($aLogin);
 				$newGrainDeSel = $this->db->getGrainDeSelUser($aLogin);
 				$newPassword = $this->hashStringWithGrainSel($aPassword, $newGrainDeSel);
 				$this->db->updatePasswordUser($aLogin, $newPassword);
 				$user->motDePasseUser = $newPassword;

				// ==========================================
				// Add and stock the information of the user into a session
				// ==========================================
                $user->classicPassword = $user->motDePasseUser == $this->hashStringWithGrainSel(configuration::get('classicPassword'), $newGrainDeSel); // Check if the password is automatic password
                $user->avatarUser = $this->getAvatarUser($user);
				$_SESSION['user'] = $user;				
				
				// ==========================================
				// Redirection
				// ==========================================
				header('Location:./index.php?module=user&page=authentification&action=connexionSuccessful');
				exit;

			} else {
				// ==========================================
				// Update the information of the user, number of connexion failed
				// ==========================================
				$this->db->incrementNbEchecConnexion($aLogin, 'increment'); // increment the number of failed connexion

				// ==========================================
				// Redirection, connexion failed
				// ==========================================
				$this->connexionFailedRedirection();
			}

		} else {
			// ==========================================
			// Redirection, connexion failed
			// ==========================================
			$this->connexionFailedRedirection();
		}

        parent::genererVue();
	}

	/**
	 * Deconnexion, this function disconnects the user. For do it, I remove the session.
	 *
	 * @author Thomas Graulle
	 * @date Mars 2019
	 * @version 2.1
	 * @throws Exception, used for database call
	 *
	 * @param null|void
	 */
	public function deconnexion() {
		// ==========================================
		// Calculate the time of the connexion
		// ==========================================
		$this->timeConnexion = $this->timeDiff(
				new DateTime($this->db->getDateLastConnexion($_SESSION['user']->loginUser),
					new DateTimeZone('Europe/Paris')
				),
					new DateTime('now', new DateTimeZone('Europe/Paris'))
			)
		;
		
		// ==========================================
		// Destroy the session for disconnect user
		// ==========================================
		unset($_SESSION['user']);
		
		parent::genererVue();
	}

	/**
	 * Get avatar user, this function return the image of the user for this avatar
	 *
	 * @author Thomas Graulle
	 * @date 11/04/19
	 *
	 * @param object $user
	 * @param string $path
	 *
	 * @return string, return the full path of the image
	 */
	public function getAvatarUser($user , $path = './image/user') {
		// ==========================================
		// Get the image and initial default value
		// ==========================================
	    $allImages = $this->getContentIntoFolder($path, '', array('png', 'jpg'), array(), array(), 2);
		$result = ($user->sexeUser === 'H' ? "$path/homme.png" : "$path/femme.png" ); // default value if nothing is find

		// ==========================================
		// Take the right image
		// ==========================================
	    foreach	($allImages as $image) {
			$nameImage = explode('/', $image);
			$nameImage = end($nameImage);
			$nameImage = explode('.', $nameImage);
			$nameImage = $nameImage[0];
			$nameImage = strtolower($nameImage);
			if ($nameImage == strtolower($user->avatarUser)) {
				$result = $image;
				break;
			}
		}

	    return $result;
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
	public function connexionSuccessful() {
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
	public function connexionFailedPage() {
		parent::genererVue();
	}

	/**
	 * Connexion failed redirection, this function protect to the brut force when the connexion failed.
	 * 		And this function make a redirection
	 *
	 * @author Thomas GRAULLE
	 * @date 19/10/2019
	 * @version 3.0
	 *
	 * @param void
	 * @return void
	 *
	 */
	public function connexionFailedRedirection() {
		// protect attack by brut force
		sleep(1);
		// ==========================================
		// Redirection, connexion failed
		// ==========================================
		header('Location:./index.php?module=user&page=authentification&action=connexionFailedPage');
		exit;
	}

} // class

?>

