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
        return normalized.toString();
    }
}
