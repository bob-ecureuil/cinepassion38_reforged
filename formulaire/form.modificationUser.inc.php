<?php
/*======= XHTML ====================================================================================
	fichier				: ./formulaire/authentificationUser.inc.php
	auteur				: Axel PUGLISI 
	date de création	: Mars 2019
	date de modification:
	rôle				: Code XHTML du formulaire
  ================================================================================================================*/

echo '
		<form action="./index.php?module=user&amp;page=modification&amp;action=modifyPassword" method="post" name="formConnexion" onsubmit="alert(\'Partie pas fini, tant pis\');let formConnexion = new Form(this); return formConnexion.isValid()">
        	<input type="password" placeholder="Ancien mot de pass"  onkeyup="Form.onkeydown(this, document.getElementById(&#034;hiddenString&#034;))" name="oldPassword"/>
        	<input type="password" placeholder="Nouveau mot de passe" onkeyup="Form.onkeydown(this, document.getElementById(&#034;hiddenString&#034;))" name="newPassword"/>
            <input type="text" placeholder="Identifiant" hidden name="encryptyOldPassword" style="display: none;" />
        	<input type="password" placeholder="Mot de passe" hidden name="encryptyNewPassword" style="display: none;" />
        	<br/>
        	<input type="submit" value="Envoyer"  />
        	<br/>
        	<span id="hiddenString" class="hidden">message texte</span>
		</form>
	';
