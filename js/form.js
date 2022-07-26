/* ======================================================================================================
 * feuille de style		: includeFile.js
 * objectif(s)			: gérer le js des formulaires
 * auteur				: Thomas GRAULLE
 * date de création		: 13/03/19
 * date de création		: decembre 2018
 * date de modification : date	-> comment faire -- qui à fait
 * ======================================================================================================
 */

/**
 * class form, this class manage the form, the sumbit, the validation of form.
 *
 * @date 13/02/19
 * @author Thomas GRAULLE
 */
class Form {

    /**
     * constructor, this constructor, This form recup all input into the form
     *
     * @author Thomas Graulle
     * @date 15/03/2019
     *
     * @param _form, it's anonymous class form , (<form></form>)
     */
    constructor(_form) {
        this.typeInputAccepted = ['text', 'password'];
        // this.typeInputAccepted = ['text', 'password', 'number', 'email', 'tel', 'url', 'search', 'date', 'datetime', 'datetime-local', 'time', 'month', 'week'];

        // propriety useful, needed in all
        this.form =  _form;
        this.nbInput = _form.length;
        this.arrayInput = [];
        this.arrayInputHidden = [];

        // Check if the form have input and save it if is right
        for (let i = 0; i < this.nbInput; i++) {
            if (this.typeInputAccepted.includes(this.form[i].type)) {
                if (this.form[i].hidden) { // This case it's for receive the hidden input (it's use for the encryption)
                    this.arrayInputHidden.push(this.form[i]);

                } else { // it's a normal case
                    this.arrayInput.push(this.form[i]);

                }
            }
        }

        this.nbInput = this.arrayInput.length; // change by the right input
        this.nbInputHidden = this.arrayInputHidden.length; // change by the right input
    }

    /**
     * isValid, this function check if the form is valid, and also change the color and empty the invalid input
     *   Also this function go to the encryption if the form is valid.
     *   The encryption go include the library, and use it for use the input hidden.
     *   The name of input hidden is changed manually and stock the encryption.
     *
     * @author Thomas Graulle
     * @date 15/03/2019
     *
     * @returns {boolean}, return true or false if the forms is valid or not
     */
    isValid() {
        let result = true;

        // Check the condition for all input
        for (let i = 0; i < this.nbInput; i++) {
            if (Form.validInput(this.arrayInput[i])) { // the condition of the
                Form.changeColor(this.arrayInput[i], "white");
                // the input is good

            } else {
                // forms is NOT valid
                result = false;
                Form.changeColor(this.arrayInput[i], "#f009");
                this.emptyForm(this.arrayInput[i]);
            }
        }

        if (result) { // Do the encryption of the information of the form

            // Instance jsencrypt
            let encryption = new JSEncrypt();
            encryption.setPublicKey(rsaPublicKey);

            for (let i = 0; i < this.nbInput; i++) {
                this.arrayInputHidden[i].value = encryption.encrypt(this.arrayInput[i].value);
            }

        }

        return result;
    }

    /**
     * changeColor, this function change the color or input in the array of input
     *
     * @author Thomas Graulle
     * @date 15/03/2019
     *
     * @param input, input
     * @param {string} color, color of the background of input
     */
    static changeColor(input, color) {
        input.style.backgroundColor = color;
    }

    /**
     * emptyForm, this function remove the content of input in array of input
     *
     * @author Thomas Graulle
     * @date 15/03/2019
     *
     * @param input, it is the element
     */
    emptyForm(input) {
        input.value = "";
    }

    /**
     * validValue, this function is used for
     *
     * @author Thomas Graulle
     * @date 15/03/2019
     *
     * @param input, input to check
     * @returns {boolean}, return true if the forms is valid
     */
    static validInput(input) {
        return input.value !== ''
            && input.value.length > 2
            && !Form.haveSpecialCaractere(input.value, Form.arrayOfSpecialChar())
            ;
    }

    /**
     * haveSpecialCaractere, this function check if have a special char into the string
     *
     * @author Axel Puglisi & Thomas Graulle
     * @date 15/03/2019
     *
     * @param myString, the value to the string
     * @param {array} specialChar, array of char

     * @returns {boolean}, return true if the forms is valid
     */
    static haveSpecialCaractere(myString, specialChar) {
        let result = false;

        for (let i = 0; i < specialChar.length; i++) {
            if (myString.includes(specialChar[i])) {
                result = true;
            }
        }

        return result;
    }

    /**
     * KeyBoard, this function envent to keyboard
     *
     * @author Axel Puglisi & Thomas GRAULLE
     * @date 15/03/2019
     *
     * @param input, input to check
     * @returns {boolean}, return true if the forms is valid
     */
    static onkeydown(input, hiddenString) {

        if (Form.haveSpecialCaractere(input.value, Form.arrayOfSpecialChar())) {

            // Remove the bad char into the input value
            input.value = Form.reformString(input.value, Form.arrayOfSpecialChar());

            // Show the little message during certain time
            const message = "Vous utilisé un caractère qui n'existe pas, veuillez en saisir un autre.";
            Form.showTextDuring(hiddenString, message, 7);

        }
    }

    /**
     * showTextDuring, Show the text during a time into the element (span, div)...
     *
     * @author Thomas Graulle
     * @date 25/03/2019
     *
     * @param element
     * @param {string} textToShowing
     * @param {int} during, the time when the element while be visible
     * @param {string} color
     */

    static showTextDuring(element, textToShowing, during = 2, color = "red") {
        // Convert during to second to milliseconds
        during *= 1000;

        // Replace the text to the element by the right text
        element.innerHTML = textToShowing;
        // Show the element
        element.style.visibility = "visible";
        element.style.color = color;

        // hide the element
        setTimeout(function () {
            element.style.visibility = "hidden";
        }, during)
    }

    /**
     *
     * @returns {string[]}
     */
    static arrayOfSpecialChar() {
        return arraySpecialChar.split('');
    }

    /**
     *
     * @param oldString
     * @param arrayOfspecialChar
     * @returns {string}
     */
    static reformString(oldString, arrayOfspecialChar) {
        let newString = oldString;

        for (let i = 0; i < arrayOfspecialChar.length; i++) {
            // console.log(new RegExp(arrayOfspecialChar[i], "g"));
            newString = newString.replace(new RegExp(arrayOfspecialChar[i], "g") , "");
        }

        return newString;
    }

}
