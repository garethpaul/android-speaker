package garethpaul.com.androidspeaker;

final class SpeechInput {
    private SpeechInput() {
    }

    static String normalize(String text) {
        if (text == null) {
            return "";
        }

        StringBuilder normalized = new StringBuilder(text.length());
        boolean previousWhitespace = true;
        for (int index = 0; index < text.length(); index++) {
            char character = text.charAt(index);
            boolean whitespace = Character.isWhitespace(character)
                    || Character.isSpaceChar(character)
                    || Character.isISOControl(character);
            if (whitespace) {
                if (!previousWhitespace) {
                    normalized.append(' ');
                }
            } else {
                normalized.append(character);
            }
            previousWhitespace = whitespace;
        }

        int length = normalized.length();
        if (length > 0 && normalized.charAt(length - 1) == ' ') {
            normalized.deleteCharAt(length - 1);
        }
        return hasSpeechContent(normalized) ? normalized.toString() : "";
    }

    private static boolean hasSpeechContent(CharSequence text) {
        for (int index = 0; index < text.length();) {
            int codePoint = Character.codePointAt(text, index);
            int type = Character.getType(codePoint);
            switch (type) {
                case Character.UPPERCASE_LETTER:
                case Character.LOWERCASE_LETTER:
                case Character.TITLECASE_LETTER:
                case Character.MODIFIER_LETTER:
                case Character.OTHER_LETTER:
                case Character.DECIMAL_DIGIT_NUMBER:
                case Character.LETTER_NUMBER:
                case Character.OTHER_NUMBER:
                case Character.CONNECTOR_PUNCTUATION:
                case Character.DASH_PUNCTUATION:
                case Character.START_PUNCTUATION:
                case Character.END_PUNCTUATION:
                case Character.INITIAL_QUOTE_PUNCTUATION:
                case Character.FINAL_QUOTE_PUNCTUATION:
                case Character.OTHER_PUNCTUATION:
                case Character.MATH_SYMBOL:
                case Character.CURRENCY_SYMBOL:
                case Character.MODIFIER_SYMBOL:
                case Character.OTHER_SYMBOL:
                    return true;
                default:
                    index += Character.charCount(codePoint);
            }
        }
        return false;
    }
}
