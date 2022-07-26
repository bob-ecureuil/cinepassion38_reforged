<?php
/*======= XHTML ====================================================================================
	fichier				: ./formulaire/authentificationUser.inc.php
	auteur				: Axel PUGLISI 
	date de création	: Mars 2019
	date de modification:
	rôle				: Code XHTML du formulaire
  ================================================================================================================*/

echo '
		<form action="./index.php?module=user&amp;page=authentification&amp;action=defaut" method="post" name="formConnexion" onsubmit="let formConnexion = new Form(this); return formConnexion.isValid()">
        	<span class="spanForm">Formulaire de connexion.</span> <br/>
        	<input type="text" placeholder="Identifiant"  onkeyup="Form.onkeydown(this, document.getElementById(&#034;hiddenString&#034;))" name="identifiant" autocomplete="off"/>
        	<input type="password" placeholder="Mot de passe" onkeyup="Form.onkeydown(this, document.getElementById(&#034;hiddenString&#034;))" name="passWord"/>
            <input type="text" placeholder="Identifiant" hidden name="encryptyId" style="display: none;" />
        	<input type="password" placeholder="Mot de passe" hidden name="encryptyPassword" style="display: none;" />
        	<br/>
        	<input type="submit" value="Envoyer"  />
        	<br/>
        	<span id="hiddenString" class="hidden">message texte</span>
		</form>
	';
